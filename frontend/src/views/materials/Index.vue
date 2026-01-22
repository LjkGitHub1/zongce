<template>
  <div class="materials-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>我的材料</span>
          <div class="header-actions">
            <el-button @click="handleRefresh" size="small">刷新</el-button>
            <el-button type="primary" @click="handleAdd" size="small">添加材料</el-button>
          </div>
        </div>
      </template>
      
      <el-form :inline="true" class="filter-form">
        <el-form-item label="状态">
          <el-select v-model="filters.status" placeholder="全部" clearable class="filter-select" @change="loadMaterials">
            <el-option label="待审核" value="pending" />
            <el-option label="审核中" value="auditing" />
            <el-option label="已通过" value="approved" />
            <el-option label="已驳回" value="rejected" />
            <el-option label="已撤回" value="withdrawn" />
          </el-select>
        </el-form-item>
        <el-form-item label="类型">
          <el-select v-model="filters.type" placeholder="全部" clearable class="filter-select" @change="handleTypeChange">
            <el-option v-if="hasPermission('research_project')" label="课题项目" value="research_project" />
            <el-option v-if="hasPermission('monograph')" label="专著" value="monograph" />
            <el-option v-if="hasPermission('paper')" label="论文" value="paper" />
            <el-option v-if="hasPermission('other_academic')" label="其他学术成果" value="other_academic" />
            <el-option v-if="hasPermission('technology_competition')" label="科技竞赛" value="technology_competition" />
            <el-option v-if="hasPermission('social_practice')" label="社会实践调研" value="social_practice" />
            <el-option v-if="hasPermission('social_service')" label="服务社会" value="social_service" />
            <el-option v-if="hasPermission('other_practice')" label="其他实践活动" value="other_practice" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="filters.type === 'technology_competition'" label="获奖等级">
          <el-select v-model="filters.grade" placeholder="全部" clearable class="filter-select" @change="loadMaterials">
            <el-option label="一等奖" value="一等奖" />
            <el-option label="二等奖" value="二等奖" />
            <el-option label="三等奖" value="三等奖" />
            <el-option label="优秀奖" value="优秀奖" />
          </el-select>
        </el-form-item>
      </el-form>
      
      <!-- 桌面端表格 -->
      <el-table 
        :data="materials" 
        style="width: 100%" 
        v-loading="loading"
        class="desktop-table"
      >
        <el-table-column prop="type" label="类型" width="120" align="center" />
        <el-table-column prop="title" label="标题" align="center" />
        <el-table-column prop="status" label="状态" width="100" align="center">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.status)">
              {{ getStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="提交时间" width="180" align="center">
          <template #default="scope">
            {{ formatDateTime(scope.row.created_at) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" align="center">
          <template #default="scope">
            <el-button link type="primary" @click="handleView(scope.row)">查看</el-button>
            <el-button
              v-if="scope.row.status === 'pending'"
              link
              type="primary"
              @click="handleEdit(scope.row)"
            >
              编辑
            </el-button>
            <el-button
              v-if="scope.row.status === 'pending'"
              link
              type="danger"
              @click="handleDelete(scope.row)"
            >
              删除
            </el-button>
            <el-button
              v-if="scope.row.status === 'pending' || scope.row.status === 'rejected'"
              link
              type="warning"
              @click="handleWithdraw(scope.row)"
            >
              撤回
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <!-- 移动端卡片列表 -->
      <div class="mobile-list" v-loading="loading">
        <div v-for="item in materials" :key="item.id" class="mobile-card">
          <div class="card-title">
            <span class="type-tag">{{ item.type }}</span>
            <el-tag :type="getStatusType(item.status)" size="small">
              {{ getStatusText(item.status) }}
            </el-tag>
          </div>
          <div class="card-content">
            <div class="content-item">
              <span class="label">标题：</span>
              <span class="value">{{ item.title }}</span>
            </div>
            <div class="content-item">
              <span class="label">提交时间：</span>
              <span class="value">{{ formatDateTime(item.created_at) }}</span>
            </div>
          </div>
          <div class="card-actions">
            <el-button link type="primary" @click="handleView(item)" size="small">查看</el-button>
            <el-button
              v-if="item.status === 'pending'"
              link
              type="primary"
              @click="handleEdit(item)"
              size="small"
            >
              编辑
            </el-button>
            <el-button
              v-if="item.status === 'pending'"
              link
              type="danger"
              @click="handleDelete(item)"
              size="small"
            >
              删除
            </el-button>
            <el-button
              v-if="item.status === 'pending' || item.status === 'rejected'"
              link
              type="warning"
              @click="handleWithdraw(item)"
              size="small"
            >
              撤回
            </el-button>
          </div>
        </div>
        <div v-if="materials.length === 0 && !loading" class="empty-tip">
          暂无数据
        </div>
      </div>
      
      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.size"
        :total="pagination.total"
        :layout="paginationLayout"
        @size-change="loadMaterials"
        @current-change="loadMaterials"
        class="pagination"
      />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { formatDateTime } from '@/utils/date'
import { usePermissionStore } from '@/stores/permission'

// 响应式分页布局
const paginationLayout = computed(() => {
  const isMobile = window.innerWidth < 768
  return isMobile ? 'prev, pager, next' : 'total, sizes, prev, pager, next, jumper'
})
import {
  getTechnologyCompetitions, deleteTechnologyCompetition,
  getResearchProjects, deleteResearchProject,
  getMonographs, deleteMonograph,
  getPapers, deletePaper,
  getOtherAcademics, deleteOtherAcademic,
  getSocialPractices, deleteSocialPractice,
  getSocialServices, deleteSocialService,
  getOtherPractices, deleteOtherPractice,
  getMaterialByType
} from '@/api/materials'
import request from '@/api/request'

const router = useRouter()
const permissionStore = usePermissionStore()

const hasPermission = (materialType) => {
  return permissionStore.hasMaterialTypePermission(materialType)
}

const materials = ref([])
const loading = ref(false)
const filters = reactive({
  status: '',
  type: '',
  grade: ''
})
const pagination = reactive({
  page: 1,
  size: 20,
  total: 0
})

const getStatusType = (status) => {
  const types = {
    pending: 'warning',
    auditing: 'info',
    approved: 'success',
    rejected: 'danger',
    withdrawn: 'info'
  }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    pending: '待审核',
    auditing: '审核中',
    approved: '已通过',
    rejected: '已驳回',
    withdrawn: '已撤回'
  }
  return texts[status] || status
}

const getTypeName = (type) => {
  const typeMap = {
    research_project: '课题项目',
    monograph: '专著',
    paper: '论文',
    other_academic: '其他学术成果',
    technology_competition: '科技竞赛',
    social_practice: '社会实践调研',
    social_service: '服务社会',
    other_practice: '其他实践活动'
  }
  return typeMap[type] || type
}

const getTitleField = (type, item) => {
  const fieldMap = {
    research_project: 'project_name',
    monograph: 'title',
    paper: 'title',
    other_academic: 'content',
    technology_competition: 'competition',
    social_practice: 'title',
    social_service: 'title',
    other_practice: 'title'
  }
  const field = fieldMap[type]
  return item[field] || item.title || '无标题'
}

const loadMaterials = async () => {
  loading.value = true
  try {
    const allTypes = [
      'research_project', 'monograph', 'paper', 'other_academic',
      'technology_competition', 'social_practice', 'social_service', 'other_practice'
    ]
    
    // 如果选择了类型，只加载该类型；否则加载所有有权限的类型
    const typesToLoad = filters.type 
      ? [filters.type] 
      : allTypes.filter(t => hasPermission(t))
    
    if (typesToLoad.length === 0) {
      materials.value = []
      pagination.total = 0
      return
    }
    
    // 如果只选择了一种类型，使用后端分页
    if (typesToLoad.length === 1) {
      const type = typesToLoad[0]
      const params = {
        page: pagination.page,
        page_size: pagination.size,
        status: filters.status || undefined
      }
      
      // 如果是科技竞赛且选择了获奖等级，添加 grade 筛选
      if (type === 'technology_competition' && filters.grade) {
        params.grade = filters.grade
      }
      
      const response = await getMaterialByType(type, params)
      
      materials.value = response.data.results.map(item => ({
        ...item,
        materialType: type,
        type: getTypeName(type),
        title: getTitleField(type, item)
      }))
      pagination.total = response.data.count || 0
      return
    }
    
    // 如果选择了多种类型或全部，需要合并显示
    // 为了性能，每个类型最多加载前100条，然后合并排序分页
    const allMaterials = []
    for (const type of typesToLoad) {
      try {
        const params = {
          page: 1,
          page_size: 100, // 每个类型最多加载100条
          status: filters.status || undefined
        }
        
        // 如果是科技竞赛且选择了获奖等级，添加 grade 筛选
        if (type === 'technology_competition' && filters.grade) {
          params.grade = filters.grade
        }
        
        const response = await getMaterialByType(type, params)
        
        const items = response.data.results || []
        allMaterials.push(...items.map(item => ({
          ...item,
          materialType: type,
          type: getTypeName(type),
          title: getTitleField(type, item)
        })))
      } catch (error) {
        console.error(`加载${getTypeName(type)}失败:`, error)
      }
    }
    
    // 按提交时间排序（最新的在前）
    allMaterials.sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
    
    // 前端分页处理
    const start = (pagination.page - 1) * pagination.size
    const end = start + pagination.size
    materials.value = allMaterials.slice(start, end)
    pagination.total = allMaterials.length
  } catch (error) {
    console.error('加载材料列表失败:', error)
    ElMessage.error('加载材料列表失败')
  } finally {
    loading.value = false
  }
}

const handleTypeChange = () => {
  // 当类型改变时，如果不是科技竞赛，清空获奖等级筛选
  if (filters.type !== 'technology_competition') {
    filters.grade = ''
  }
  loadMaterials()
}

const handleAdd = () => {
  // 根据权限决定跳转到哪个页面
  if (hasPermission('technology_competition') || 
      hasPermission('social_practice') || 
      hasPermission('social_service') || 
      hasPermission('other_practice')) {
    router.push('/materials/practice')
  } else if (hasPermission('research_project') || 
             hasPermission('monograph') || 
             hasPermission('paper') || 
             hasPermission('other_academic')) {
    router.push('/materials/academic')
  }
}

const handleView = (row) => {
  const typeMap = {
    research_project: 'research-project',
    monograph: 'monograph',
    paper: 'paper',
    other_academic: 'other-academic',
    technology_competition: 'technology-competition',
    social_practice: 'social-practice',
    social_service: 'social-service',
    other_practice: 'other-practice'
  }
  const routeType = typeMap[row.materialType] || row.materialType
  router.push(`/materials/detail/${routeType}/${row.id}`)
}

const handleEdit = (row) => {
  const typeMap = {
    research_project: 'research-project',
    monograph: 'monograph',
    paper: 'paper',
    other_academic: 'other-academic',
    technology_competition: 'technology-competition',
    social_practice: 'social-practice',
    social_service: 'social-service',
    other_practice: 'other-practice'
  }
  const routeType = typeMap[row.materialType] || row.materialType
  router.push(`/materials/edit/${routeType}/${row.id}`)
}

const getDeleteFunction = (type) => {
  const funcMap = {
    research_project: deleteResearchProject,
    monograph: deleteMonograph,
    paper: deletePaper,
    other_academic: deleteOtherAcademic,
    technology_competition: deleteTechnologyCompetition,
    social_practice: deleteSocialPractice,
    social_service: deleteSocialService,
    other_practice: deleteOtherPractice
  }
  return funcMap[type] || deleteTechnologyCompetition
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('確定要刪除這條材料嗎？', '提示', {
      confirmButtonText: '確定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const deleteFunc = getDeleteFunction(row.materialType)
    await deleteFunc(row.id)
    ElMessage.success('删除成功')
    loadMaterials()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleWithdraw = async (row) => {
  try {
    await ElMessageBox.confirm('确定要撤回这条材料吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const typeMap = {
      research_project: 'research-projects',
      monograph: 'monographs',
      paper: 'papers',
      other_academic: 'other-academics',
      technology_competition: 'technology-competitions',
      social_practice: 'social-practices',
      social_service: 'social-services',
      other_practice: 'other-practices'
    }
    const urlType = typeMap[row.materialType] || 'technology-competitions'
    
    await request({
      url: `/materials/${urlType}/${row.id}/withdraw/`,
      method: 'post'
    })
    
    ElMessage.success('撤回成功')
    loadMaterials()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('撤回失败')
    }
  }
}

const handleRefresh = () => {
  loadMaterials()
}

onMounted(() => {
  loadMaterials()
})
</script>

<style scoped>
.materials-page {
  padding: 0;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
}

.header-actions {
  display: flex;
  gap: 8px;
}

.filter-form {
  margin-bottom: 20px;
}

.filter-select {
  width: 150px;
}

.desktop-table {
  display: block;
}

.mobile-list {
  display: none;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.empty-tip {
  text-align: center;
  color: #909399;
  padding: 40px 0;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .materials-page {
    padding: 0;
  }
  
  .card-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .header-actions {
    width: 100%;
    justify-content: flex-end;
  }
  
  .filter-form {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }
  
  .filter-form .el-form-item {
    margin-bottom: 0;
    width: 100%;
  }
  
  .filter-select {
    width: 100%;
  }
  
  .desktop-table {
    display: none;
  }
  
  .mobile-list {
    display: block;
  }
  
  .mobile-card {
    background: #fff;
    border: 1px solid #e4e7ed;
    border-radius: 4px;
    padding: 15px;
    margin-bottom: 12px;
  }
  
  .card-title {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
    padding-bottom: 10px;
    border-bottom: 1px solid #f0f0f0;
  }
  
  .type-tag {
    font-weight: bold;
    color: #409eff;
    font-size: 14px;
  }
  
  .card-content {
    margin-bottom: 12px;
  }
  
  .content-item {
    display: flex;
    margin-bottom: 8px;
    font-size: 13px;
  }
  
  .content-item .label {
    color: #909399;
    min-width: 70px;
  }
  
  .content-item .value {
    color: #606266;
    flex: 1;
    word-break: break-all;
  }
  
  .card-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    padding-top: 10px;
    border-top: 1px solid #f0f0f0;
  }
  
  .pagination {
    justify-content: center;
    margin-top: 15px;
  }
}

@media (max-width: 480px) {
  .card-header span {
    font-size: 16px;
  }
  
  .mobile-card {
    padding: 12px;
  }
  
  .content-item {
    font-size: 12px;
  }
  
  .content-item .label {
    min-width: 60px;
  }
}
</style>

