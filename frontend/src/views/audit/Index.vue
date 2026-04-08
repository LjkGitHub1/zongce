<template>
  <div class="audit-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>材料审核</span>
          <el-button @click="handleRefresh">刷新</el-button>
        </div>
      </template>
      
      <el-tabs v-model="activeTab">
        <el-tab-pane label="提交情况" name="all">
          <!-- 筛选表单 -->
          <el-form :inline="true" class="filter-form" style="margin-bottom: 20px">
            <el-form-item label="状态">
              <el-select v-model="filters.status" placeholder="全部" clearable style="width: 150px" @change="handleFilterChange">
                <el-option label="待审核" value="pending" />
                <el-option label="审核中" value="auditing" />
                <el-option label="已通过" value="approved" />
                <el-option label="已驳回" value="rejected" />
                <el-option label="已撤回" value="withdrawn" />
              </el-select>
            </el-form-item>
            <el-form-item label="类型">
              <el-select v-model="filters.type" placeholder="全部" clearable style="width: 180px" @change="handleTypeChange">
                <el-option label="课题项目" value="research_project" />
                <el-option label="专著" value="monograph" />
                <el-option label="论文" value="paper" />
                <el-option label="其他学术成果" value="other_academic" />
                <el-option label="科技竞赛" value="technology_competition" />
                <el-option label="社会实践调研" value="social_practice" />
                <el-option label="服务社会" value="social_service" />
                <el-option label="其他实践活动" value="other_practice" />
              </el-select>
            </el-form-item>
            <el-form-item v-if="filters.type === 'technology_competition'" label="级别">
              <el-select v-model="filters.level" placeholder="全部" clearable style="width: 150px" @change="handleFilterChange">
                <el-option label="国家级" value="national" />
                <el-option label="省级" value="provincial" />
                <el-option label="校级" value="school" />
                <el-option label="院级" value="college" />
              </el-select>
            </el-form-item>
            <el-form-item v-if="filters.type === 'technology_competition'" label="获奖等级">
              <el-select v-model="filters.grade" placeholder="全部" clearable style="width: 150px" @change="handleFilterChange">
                <el-option label="一等奖" value="一等奖" />
                <el-option label="二等奖" value="二等奖" />
                <el-option label="三等奖" value="三等奖" />
                <el-option label="优秀奖" value="优秀奖" />
              </el-select>
            </el-form-item>
            <el-form-item label="身份">
              <el-select v-model="filters.identity" placeholder="全部" clearable style="width: 120px" @change="handleFilterChange">
                <el-option label="老师" value="teacher" />
                <el-option label="研究生" value="graduate" />
                <el-option label="本科生" value="undergraduate" />
              </el-select>
            </el-form-item>
            <el-form-item label="班级">
              <el-select v-model="filters.class_name" placeholder="全部" clearable style="width: 150px" @change="handleFilterChange">
                <el-option v-for="cls in classList" :key="cls" :label="cls" :value="cls" />
              </el-select>
            </el-form-item>
            <el-form-item label="学号/姓名">
              <el-input
                v-model="filters.search"
                placeholder="搜索学号或姓名"
                clearable
                style="width: 200px"
                @keyup.enter="loadAllMaterials"
              />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="loadAllMaterials">搜索</el-button>
              <el-button @click="handleResetFilters">重置</el-button>
            </el-form-item>
          </el-form>
          
          <!-- 提交统计 -->
          <div v-if="filters.class_name" class="statistics-info" style="margin-bottom: 20px">
            <el-alert
              :title="`班级：${filters.class_name} | 提交情况：${classStats.ratio || '0/0'}`"
              type="info"
              :closable="false"
            >
              <template #default>
                <div style="display: flex; gap: 20px; align-items: center">
                  <span>总人数：{{ classStats.total_students || 0 }}</span>
                  <span>已提交人数：{{ classStats.submitted_students || 0 }}</span>
                  <span>提交份数：{{ classStats.submitted_count || 0 }}</span>
                  <span style="font-weight: bold; color: #409eff">提交率：{{ classStats.ratio || '0/0' }}</span>
                </div>
              </template>
            </el-alert>
          </div>
          
          <!-- 材料列表 -->
          <el-table :data="allMaterials" v-loading="loadingAll" style="width: 100%">
            <el-table-column prop="student_id" label="学号" width="120" align="center" />
            <el-table-column prop="name" label="姓名" width="100" align="center" />
            <el-table-column prop="identity" label="身份" width="100" align="center">
              <template #default="scope">
                <el-tag :type="getIdentityType(scope.row.identity)">
                  {{ getIdentityText(scope.row.identity) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="type" label="类型" width="120" align="center" />
            <el-table-column v-if="filters.type === 'technology_competition'" prop="level" label="级别" width="100" align="center">
              <template #default="scope">
                {{ getLevelText(scope.row.level) }}
              </template>
            </el-table-column>
            <el-table-column v-if="filters.type === 'technology_competition'" prop="grade" label="获奖等级" width="120" align="center" />
            <el-table-column prop="title" label="标题" min-width="200" align="center" />
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
            <el-table-column label="操作" width="250" fixed="right" align="center">
              <template #default="scope">
                <el-button link type="primary" @click="handleView(scope.row)">查看</el-button>
                <el-button
                  v-if="scope.row.status === 'pending'"
                  link
                  type="success"
                  @click="handleApprove(scope.row)"
                >
                  通过
                </el-button>
                <el-button
                  v-if="scope.row.status === 'pending'"
                  link
                  type="danger"
                  @click="handleReject(scope.row)"
                >
                  驳回
                </el-button>
              </template>
            </el-table-column>
          </el-table>
          
          <!-- 分页 -->
          <el-pagination
            v-model:current-page="pagination.page"
            v-model:page-size="pagination.size"
            :total="pagination.total"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="loadAllMaterials"
            @current-change="loadAllMaterials"
            style="margin-top: 20px; justify-content: flex-end"
          />
        </el-tab-pane>
        
        <el-tab-pane label="待审核" name="pending">
          <el-table :data="pendingMaterials" v-loading="loading" style="width: 100%">
            <el-table-column prop="student_id" label="学号" width="120" align="center" />
            <el-table-column prop="name" label="姓名" width="100" align="center" />
            <el-table-column prop="type" label="类型" width="120" align="center" />
            <el-table-column prop="title" label="标题" align="center" />
            <el-table-column prop="created_at" label="提交时间" width="180" align="center">
              <template #default="scope">
                {{ formatDateTime(scope.row.created_at) }}
              </template>
            </el-table-column>
            <el-table-column label="操作" width="200" fixed="right" align="center">
              <template #default="scope">
                <el-button link type="primary" @click="handleView(scope.row)">查看</el-button>
                <el-button link type="success" @click="handleApprove(scope.row)">通过</el-button>
                <el-button link type="danger" @click="handleReject(scope.row)">驳回</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
        
        <el-tab-pane label="审核统计" name="statistics">
          <el-row :gutter="20">
            <el-col :span="6">
              <el-statistic title="待审核" :value="auditStats.pending_count" />
            </el-col>
            <el-col :span="6">
              <el-statistic title="已通过" :value="auditStats.approved_count" />
            </el-col>
            <el-col :span="6">
              <el-statistic title="已驳回" :value="auditStats.rejected_count" />
            </el-col>
            <el-col :span="6">
              <el-statistic title="通过率" :value="auditStats.approval_rate" suffix="%" />
            </el-col>
          </el-row>
        </el-tab-pane>
      </el-tabs>
    </el-card>
    
    <!-- 审核对话框 -->
    <el-dialog
      v-model="auditDialog.visible"
      :title="auditDialog.title"
      width="500px"
    >
      <el-form :model="auditForm" label-width="100px">
        <el-form-item label="审核结果">
          <el-radio-group v-model="auditForm.result">
            <el-radio label="approved">通过</el-radio>
            <el-radio label="rejected">驳回</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="审核意见" v-if="auditForm.result === 'rejected'">
          <el-input
            v-model="auditForm.comment"
            type="textarea"
            :rows="4"
            placeholder="请输入审核意见（驳回时必填）"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="auditDialog.visible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmitAudit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { auditMaterial, getAuditStatistics, getClassList, getClassStatistics } from '@/api/system'
import { getMaterialByType } from '@/api/materials'
import request from '@/api/request'
import { formatDateTime } from '@/utils/date'

const router = useRouter()

const activeTab = ref('all')
const loading = ref(false)
const loadingAll = ref(false)
const pendingMaterials = ref([])
const allMaterials = ref([])
const auditStats = ref({
  pending_count: 0,
  approved_count: 0,
  rejected_count: 0,
  approval_rate: 0
})

const filters = reactive({
  status: '',
  type: '',
  level: '',
  grade: '',
  identity: '',
  class_name: '',
  search: ''
})

const classList = ref([])
const classStats = ref({
  total_students: 0,
  submitted_students: 0,
  submitted_count: 0,
  ratio: '0/0'
})

const pagination = reactive({
  page: 1,
  size: 20,
  total: 0
})

const auditDialog = reactive({
  visible: false,
  title: '审核材料',
  material: null
})

const auditForm = reactive({
  result: 'approved',
  comment: ''
})

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

const getIdentityType = (identity) => {
  const types = {
    teacher: 'warning',
    graduate: 'success',
    undergraduate: 'info'
  }
  return types[identity] || 'info'
}

const getIdentityText = (identity) => {
  const texts = {
    teacher: '老师',
    graduate: '研究生',
    undergraduate: '本科生'
  }
  return texts[identity] || identity
}

const getLevelText = (level) => {
  const texts = {
    national: '国家级',
    provincial: '省级',
    school: '校级',
    college: '院级'
  }
  return texts[level] || level || '-'
}

const loadPendingMaterials = async () => {
  loading.value = true
  try {
    // 加载所有类型的待审核材料
    const allPending = []
    const types = [
      'research_project', 'monograph', 'paper', 'other_academic',
      'technology_competition', 'social_practice', 'social_service', 'other_practice'
    ]
    
    for (const type of types) {
      try {
        const response = await getMaterialByType(type, { status: 'pending' })
        const items = response.data.results || []
        allPending.push(...items.map(item => ({
          ...item,
          materialType: type,
          type: typeMap[type],
          title: getTitleField(type, item)
        })))
      } catch (error) {
        console.error(`加载${typeMap[type]}失败:`, error)
      }
    }
    
    // 按提交时间排序
    allPending.sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
    pendingMaterials.value = allPending
  } catch (error) {
    ElMessage.error('加载待审核材料失败')
  } finally {
    loading.value = false
  }
}

const loadAllMaterials = async () => {
  loadingAll.value = true
  try {
    const allItems = []
    const types = filters.type
      ? [filters.type]
      : [
          'research_project', 'monograph', 'paper', 'other_academic',
          'technology_competition', 'social_practice', 'social_service', 'other_practice'
        ]
    
    for (const type of types) {
      try {
        const params = {
          page: pagination.page,
          page_size: pagination.size
        }
        
        if (filters.status) params.status = filters.status
        if (filters.identity) params.identity = filters.identity
        if (filters.class_name) params.class_name = filters.class_name
        if (filters.search) params.search = filters.search
        // 如果是科技竞赛，添加级别和获奖等级筛选
        if (type === 'technology_competition') {
          if (filters.level) params.level = filters.level
          if (filters.grade) params.grade = filters.grade
        }
        
        const response = await getMaterialByType(type, params)
        const items = response.data.results || []
        allItems.push(...items.map(item => ({
          ...item,
          materialType: type,
          type: typeMap[type],
          title: getTitleField(type, item)
        })))
      } catch (error) {
        console.error(`加载${typeMap[type]}失败:`, error)
      }
    }
    
    // 按提交时间排序
    allItems.sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
    allMaterials.value = allItems
    
    // 如果只查询一种类型，使用该类型的分页信息
    if (filters.type && types.length === 1) {
      try {
        const params = {
          page: pagination.page,
          page_size: pagination.size
        }
        if (filters.status) params.status = filters.status
        if (filters.identity) params.identity = filters.identity
        if (filters.class_name) params.class_name = filters.class_name
        if (filters.search) params.search = filters.search
        // 如果是科技竞赛，添加级别和获奖等级筛选
        if (filters.type === 'technology_competition') {
          if (filters.level) params.level = filters.level
          if (filters.grade) params.grade = filters.grade
        }
        
        const response = await getMaterialByType(filters.type, params)
        pagination.total = response.data.count || allItems.length
      } catch (error) {
        pagination.total = allItems.length
      }
    } else {
      pagination.total = allItems.length
    }
    
    // 如果选择了班级，加载班级统计
    if (filters.class_name) {
      await loadClassStatistics()
    }
  } catch (error) {
    ElMessage.error('加载材料列表失败')
  } finally {
    loadingAll.value = false
  }
}

const loadClassList = async () => {
  try {
    const response = await getClassList()
    classList.value = response.data.classes || []
  } catch (error) {
    console.error('加载班级列表失败:', error)
  }
}

const loadClassStatistics = async () => {
  if (!filters.class_name) {
    classStats.value = {
      total_students: 0,
      submitted_students: 0,
      submitted_count: 0,
      ratio: '0/0'
    }
    return
  }
  
  try {
    const params = {
      class_name: filters.class_name
    }
    if (filters.type) {
      params.type = filters.type
    }
    
    const response = await getClassStatistics(params)
    classStats.value = response.data
  } catch (error) {
    console.error('加载班级统计失败:', error)
  }
}

const handleTypeChange = () => {
  // 当类型改变时，如果不是科技竞赛，清空级别和获奖等级筛选
  if (filters.type !== 'technology_competition') {
    filters.level = ''
    filters.grade = ''
  }
  handleFilterChange()
}

const handleFilterChange = () => {
  pagination.page = 1
  loadAllMaterials()
}

const handleResetFilters = () => {
  filters.status = ''
  filters.type = ''
  filters.level = ''
  filters.grade = ''
  filters.identity = ''
  filters.class_name = ''
  filters.search = ''
  pagination.page = 1
  classStats.value = {
    total_students: 0,
    submitted_students: 0,
    submitted_count: 0,
    ratio: '0/0'
  }
  loadAllMaterials()
}

const handleRefresh = () => {
  if (activeTab.value === 'pending') {
    loadPendingMaterials()
  } else if (activeTab.value === 'all') {
    loadAllMaterials()
  } else {
    loadAuditStatistics()
  }
}

const loadAuditStatistics = async () => {
  try {
    const response = await getAuditStatistics()
    auditStats.value = response.data
  } catch (error) {
    ElMessage.error('加载审核统计失败')
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

const handleApprove = (row) => {
  auditDialog.material = row
  auditDialog.title = '审核通过'
  auditForm.result = 'approved'
  auditForm.comment = ''
  auditDialog.visible = true
}

const handleReject = (row) => {
  auditDialog.material = row
  auditDialog.title = '审核驳回'
  auditForm.result = 'rejected'
  auditForm.comment = ''
  auditDialog.visible = true
}

const handleSubmitAudit = async () => {
  if (auditForm.result === 'rejected' && !auditForm.comment) {
    ElMessage.warning('驳回时必须填写审核意见')
    return
  }
  
  try {
    await auditMaterial({
      material_type: auditDialog.material.materialType,
      material_id: auditDialog.material.id,
      result: auditForm.result,
      comment: auditForm.comment
    })
    
    ElMessage.success('审核成功')
    auditDialog.visible = false
    loadPendingMaterials()
    loadAllMaterials()
    loadAuditStatistics()
  } catch (error) {
    ElMessage.error(error.response?.data?.error || '审核失败')
  }
}

onMounted(() => {
  // 默认加载提交情况（所有材料）
  loadAllMaterials()
  loadAuditStatistics()
  loadClassList()
})

// 监听tab切换
watch(() => activeTab.value, (newTab) => {
  if (newTab === 'pending') {
    loadPendingMaterials()
  } else if (newTab === 'all') {
    loadAllMaterials()
  } else if (newTab === 'statistics') {
    loadAuditStatistics()
  }
})

// 监听班级变化，自动加载统计
watch(() => filters.class_name, (newVal) => {
  if (newVal) {
    loadClassStatistics()
  } else {
    classStats.value = {
      total_students: 0,
      submitted_students: 0,
      submitted_count: 0,
      ratio: '0/0'
    }
  }
})
</script>

<style scoped>
.audit-page {
  padding: 0px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.filter-form {
  margin-bottom: 20px;
}

.statistics-info {
  margin-bottom: 20px;
}
</style>
