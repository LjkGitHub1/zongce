<template>
  <div class="statistics-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>数据统计</span>
          <div>
            <el-button 
              v-if="userStore.userInfo?.is_staff" 
              type="primary" 
              @click="handleDownloadAll"
              :loading="downloading"
            >
              一键下载
            </el-button>
            <el-button @click="loadStatistics">刷新</el-button>
          </div>
        </div>
      </template>
      
      <!-- 第一行：统计卡片 -->
      <el-row :gutter="15">
        <el-col :xs="12" :sm="12" :md="6" :lg="6" :xl="6">
          <el-card>
            <el-statistic title="材料总数" :value="stats.total" />
          </el-card>
        </el-col>
        <el-col :xs="12" :sm="12" :md="6" :lg="6" :xl="6">
          <el-card>
            <el-statistic title="待审核" :value="stats.by_status.pending" />
          </el-card>
        </el-col>
        <el-col :xs="12" :sm="12" :md="6" :lg="6" :xl="6">
          <el-card>
            <el-statistic title="已通过" :value="stats.by_status.approved" />
          </el-card>
        </el-col>
        <el-col :xs="12" :sm="12" :md="6" :lg="6" :xl="6">
          <el-card>
            <el-statistic title="已驳回" :value="stats.by_status.rejected" />
          </el-card>
        </el-col>
      </el-row>
      
      <!-- 第二行：班级提交情况 -->
      <el-row :gutter="15" style="margin-top: 15px" v-if="userStore.userInfo?.is_staff">
        <el-col :span="24">
          <el-card>
            <template #header>
              <span>班级提交情况</span>
            </template>
            <div class="table-wrapper">
              <el-table :data="classStatistics" stripe style="width: 100%">
                <el-table-column prop="class_name" label="班级名称" align="center" />
                <el-table-column label="提交情况" align="center">
                  <template #default="{ row }">
                    <el-link 
                      type="primary" 
                      class="ratio-link"
                      @click="showUnsubmittedStudents(row)"
                    >
                      {{ row.ratio }}
                    </el-link>
                  </template>
                </el-table-column>
              </el-table>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 第三行：科技竞赛获奖情况（仅管理员） -->
      <el-row :gutter="15" style="margin-top: 15px" v-if="userStore.userInfo?.is_staff">
        <el-col :span="24">
          <el-card>
            <template #header>
              <div class="award-header">
                <span>科技竞赛获奖情况</span>
                <el-radio-group v-model="awardIdentityFilter" size="small" @change="loadAwardStatistics">
                  <el-radio-button label="">全部</el-radio-button>
                  <el-radio-button label="undergraduate">本科生</el-radio-button>
                  <el-radio-button label="graduate">研究生</el-radio-button>
                </el-radio-group>
              </div>
            </template>
            <div v-loading="loadingAwardStats" class="award-statistics">
              <div class="award-summary">
                <el-statistic title="总获奖数" :value="awardStats.total_awards" />
              </div>

              <div class="award-section" style="margin-top: 20px">
                <h4>级别 × 获奖等级交叉统计</h4>
                <div class="level-grade-table">
                  <el-table :data="levelGradeTableData" border stripe style="width: 100%">
                    <el-table-column prop="level" label="级别" width="120" align="center" />
                    <el-table-column prop="一等奖" label="一等奖" width="100" align="center" />
                    <el-table-column prop="二等奖" label="二等奖" width="100" align="center" />
                    <el-table-column prop="三等奖" label="三等奖" width="100" align="center" />
                    <el-table-column prop="优秀奖" label="优秀奖" width="100" align="center" />
                    <el-table-column prop="小计" label="小计" width="100" align="center" />
                  </el-table>
                </div>
              </div>
              
              <el-row :gutter="20" style="margin-top: 20px">
                <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
                  <div class="award-section">
                    <h4>按级别统计</h4>
                    <div class="level-chart">
                      <div v-for="(value, key) in awardStats.by_level" :key="key" class="level-item">
                        <div class="level-info">
                          <span class="level-name">{{ getLevelName(key) }}</span>
                          <span class="level-value">{{ value }}</span>
                        </div>
                        <el-progress
                          :percentage="awardStats.total_awards > 0 ? parseFloat((value / awardStats.total_awards * 100).toFixed(1)) : 0"
                          :stroke-width="8"
                        />
                      </div>
                    </div>
                  </div>
                </el-col>
                
                <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
                  <div class="award-section">
                    <h4>按获奖等级统计</h4>
                    <div class="grade-chart">
                      <div v-for="(value, key) in awardStats.by_grade" :key="key" class="grade-item">
                        <div class="grade-info">
                          <span class="grade-name">{{ key }}</span>
                          <span class="grade-value">{{ value }}</span>
                        </div>
                        <el-progress
                          :percentage="awardStats.total_awards > 0 ? parseFloat((value / awardStats.total_awards * 100).toFixed(1)) : 0"
                          :stroke-width="8"
                        />
                      </div>
                    </div>
                  </div>
                </el-col>
              </el-row>
              
              
            </div>
          </el-card>
        </el-col>
      </el-row>
      
      <!-- 第四行：材料类型分布和状态分布 -->
      <el-row :gutter="15" style="margin-top: 15px">
        <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
          <el-card>
            <template #header>
              <span>材料类型分布</span>
            </template>
            <div class="type-chart">
              <div v-for="(value, key) in stats.by_type" :key="key" class="type-item">
                <div class="type-info">
                  <span class="type-name">{{ getTypeName(key) }}</span>
                  <span class="type-value">{{ value }}</span>
                </div>
                <el-progress
                  :percentage="stats.total > 0 ? parseFloat((value / stats.total * 100).toFixed(1)) : 0"
                  :stroke-width="8"
                />
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
          <el-card>
            <template #header>
              <span>状态分布</span>
            </template>
            <div class="status-chart">
              <div v-for="(value, key) in stats.by_status" :key="key" class="status-item">
                <span class="status-name">{{ getStatusName(key) }}</span>
                <span class="status-value">{{ value }}</span>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
      
      
      
      <!-- 未提交人员弹窗 -->
      <el-dialog
        v-model="unsubmittedDialogVisible"
        :title="`${currentClassName} - 未提交人员`"
        width="600px"
      >
        <el-empty v-if="unsubmittedStudents.length === 0" description="该班级所有学生均已提交" />
        <el-table v-else :data="unsubmittedStudents" stripe style="width: 100%">
          <el-table-column prop="student_id" label="学号" align="center" />
          <el-table-column prop="name" label="姓名" align="center" />
        </el-table>
        <template #footer>
          <el-button @click="unsubmittedDialogVisible = false">关闭</el-button>
        </template>
      </el-dialog>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getUserStatistics, getAdminStatistics, downloadAllByClass, getTechnologyCompetitionAwardStatistics } from '@/api/materials'
import { getAllClassStatistics, getUnsubmittedStudents } from '@/api/system'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()
const downloading = ref(false)

const stats = reactive({
  total: 0,
  by_type: {
    research_project: 0,
    monograph: 0,
    paper: 0,
    other_academic: 0,
    technology_competition: 0,
    social_practice: 0,
    social_service: 0,
    other_practice: 0
  },
  by_status: {
    pending: 0,
    auditing: 0,
    approved: 0,
    rejected: 0,
    withdrawn: 0
  }
})

const classStatistics = ref([])
const unsubmittedDialogVisible = ref(false)
const unsubmittedStudents = ref([])
const currentClassName = ref('')

const awardIdentityFilter = ref('')
const loadingAwardStats = ref(false)
const awardStats = reactive({
  total_awards: 0,
  by_level: {
    national: 0,
    provincial: 0,
    school: 0,
    college: 0
  },
  by_grade: {
    '一等奖': 0,
    '二等奖': 0,
    '三等奖': 0,
    '优秀奖': 0
  },
  by_level_grade: {}
})

const getTypeName = (key) => {
  const names = {
    'research_project': '课题项目',
    'monograph': '专著',
    'paper': '论文',
    'other_academic': '其他学术成果',
    'technology_competition': '科技竞赛',
    'social_practice': '社会实践调研',
    'social_service': '服务社会',
    'other_practice': '其他实践活动'
  }
  return names[key] || key
}

const getStatusName = (key) => {
  const names = {
    'pending': '待审核',
    'auditing': '审核中',
    'approved': '已通过',
    'rejected': '已驳回',
    'withdrawn': '已撤回'
  }
  return names[key] || key
}

const getLevelName = (key) => {
  const names = {
    'national': '国家级',
    'provincial': '省级',
    'school': '校级',
    'college': '院级'
  }
  return names[key] || key
}

const levelGradeTableData = computed(() => {
  const levels = ['national', 'provincial', 'school', 'college']
  const grades = ['一等奖', '二等奖', '三等奖', '优秀奖']
  
  return levels.map(level => {
    const row = {
      level: getLevelName(level),
      '一等奖': awardStats.by_level_grade[level]?.['一等奖'] || 0,
      '二等奖': awardStats.by_level_grade[level]?.['二等奖'] || 0,
      '三等奖': awardStats.by_level_grade[level]?.['三等奖'] || 0,
      '优秀奖': awardStats.by_level_grade[level]?.['优秀奖'] || 0,
      '小计': 0
    }
    row['小计'] = row['一等奖'] + row['二等奖'] + row['三等奖'] + row['优秀奖']
    return row
  })
})

const loadStatistics = async () => {
  try {
    // 根据用户角色调用不同的统计API
    let response
    if (userStore.userInfo?.is_staff) {
      // 管理员调用管理员统计API，获取所有用户的统计数据
      response = await getAdminStatistics()
      
      // 管理员同时加载班级统计
      try {
        const classResponse = await getAllClassStatistics()
        classStatistics.value = classResponse.data || []
      } catch (classError) {
        console.error('加载班级统计失败:', classError)
        // 班级统计失败不影响主统计数据的显示
      }
    } else {
      // 普通用户调用用户统计API，获取当前用户的统计数据
      response = await getUserStatistics()
    }
    
    // 更新统计数据
    if (response.data) {
      stats.total = response.data.total || 0
      
      // 更新材料类型统计，保留所有类型
      if (response.data.by_type) {
        Object.keys(stats.by_type).forEach(key => {
          stats.by_type[key] = response.data.by_type[key] || 0
        })
      }
      
      // 更新状态统计
      if (response.data.by_status) {
        stats.by_status.pending = response.data.by_status.pending || 0
        stats.by_status.auditing = response.data.by_status.auditing || 0
        stats.by_status.approved = response.data.by_status.approved || 0
        stats.by_status.rejected = response.data.by_status.rejected || 0
        stats.by_status.withdrawn = response.data.by_status.withdrawn || 0
      }
    }
  } catch (error) {
    console.error('加载统计数据失败:', error)
    ElMessage.error('加载统计数据失败: ' + (error.response?.data?.detail || error.message || '未知错误'))
  }
}

const showUnsubmittedStudents = async (row) => {
  try {
    currentClassName.value = row.class_name
    const response = await getUnsubmittedStudents({ class_name: row.class_name })
    unsubmittedStudents.value = response.data.unsubmitted_students || []
    unsubmittedDialogVisible.value = true
  } catch (error) {
    console.error('加载未提交人员失败:', error)
    ElMessage.error('加载未提交人员失败: ' + (error.response?.data?.detail || error.message || '未知错误'))
  }
}

const handleDownloadAll = async () => {
  downloading.value = true
  try {
    const response = await downloadAllByClass()
    
    // 创建下载链接
    const blob = new Blob([response.data], { type: 'application/zip' })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    
    // 从响应头获取文件名，支持 filename*=UTF-8'' 格式
    const contentDisposition = response.headers['content-disposition'] || response.headers['Content-Disposition']
    let filename = '材料汇总.zip'
    if (contentDisposition) {
      // 尝试匹配 filename*=UTF-8'' 格式
      const utf8Match = contentDisposition.match(/filename\*=UTF-8''(.+)/i)
      if (utf8Match) {
        filename = decodeURIComponent(utf8Match[1])
      } else {
        // 尝试匹配普通 filename="..." 格式
        const filenameMatch = contentDisposition.match(/filename="(.+)"/)
        if (filenameMatch) {
          filename = decodeURIComponent(filenameMatch[1])
        }
      }
    }
    
    // 如果没有从响应头获取到文件名，使用当前日期生成
    if (filename === '材料汇总.zip') {
      const now = new Date()
      const year = now.getFullYear()
      const month = String(now.getMonth() + 1).padStart(2, '0')
      const day = String(now.getDate()).padStart(2, '0')
      filename = `${year}年${month}月${day}日_材料汇总.zip`
    }
    
    link.download = filename
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
    
    ElMessage.success('下载成功')
  } catch (error) {
    console.error('下载失败:', error)
    ElMessage.error('下载失败: ' + (error.response?.data?.detail || error.message || '未知错误'))
  } finally {
    downloading.value = false
  }
}

const loadAwardStatistics = async () => {
  if (!userStore.userInfo?.is_staff) {
    return
  }
  
  loadingAwardStats.value = true
  try {
    const params = {}
    if (awardIdentityFilter.value) {
      params.identity = awardIdentityFilter.value
    }
    
    const response = await getTechnologyCompetitionAwardStatistics(params)
    console.log('科技竞赛获奖统计响应:', response.data)
    
    if (response.data) {
      awardStats.total_awards = response.data.total_awards || 0
      
      // 更新级别统计
      if (response.data.by_level) {
        Object.keys(awardStats.by_level).forEach(key => {
          awardStats.by_level[key] = response.data.by_level[key] || 0
        })
      }
      
      // 更新获奖等级统计
      if (response.data.by_grade) {
        Object.keys(awardStats.by_grade).forEach(key => {
          awardStats.by_grade[key] = response.data.by_grade[key] || 0
        })
      }
      
      // 更新交叉统计
      if (response.data.by_level_grade) {
        awardStats.by_level_grade = response.data.by_level_grade
      }
      
      console.log('更新后的awardStats:', awardStats)
    }
  } catch (error) {
    console.error('加载科技竞赛获奖统计失败:', error)
    ElMessage.error('加载科技竞赛获奖统计失败: ' + (error.response?.data?.detail || error.message || '未知错误'))
  } finally {
    loadingAwardStats.value = false
  }
}

onMounted(async () => {
  // 确保用户信息已加载
  if (!userStore.userInfo) {
    await userStore.fetchUserInfo()
  }
  await loadStatistics()
  // 如果是管理员，加载科技竞赛获奖统计
  if (userStore.userInfo?.is_staff) {
    await loadAwardStatistics()
  }
})
</script>

<style scoped>
.statistics-page {
  padding: 0;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
}

.table-wrapper {
  overflow-x: auto;
}

.type-chart {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.type-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.type-info {
  display: flex;
  justify-content: space-between;
}

.type-name {
  color: #606266;
}

.type-value {
  font-weight: bold;
  color: #409eff;
}

.status-chart {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.status-item {
  display: flex;
  justify-content: space-between;
  padding: 10px;
  background: #f5f7fa;
  border-radius: 4px;
}

.status-name {
  color: #606266;
}

.status-value {
  font-weight: bold;
  color: #409eff;
}

.ratio-link {
  font-weight: bold;
  font-size: 16px;
  cursor: pointer;
}

.award-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
}

.award-statistics {
  min-height: 200px;
}

.award-summary {
  text-align: center;
  padding: 20px 0;
  border-bottom: 1px solid #ebeef5;
  margin-bottom: 20px;
}

.award-section {
  margin-bottom: 20px;
}

.award-section h4 {
  margin: 0 0 15px 0;
  color: #303133;
  font-size: 16px;
  font-weight: 600;
}

.level-chart,
.grade-chart {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.level-item,
.grade-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.level-info,
.grade-info {
  display: flex;
  justify-content: space-between;
}

.level-name,
.grade-name {
  color: #606266;
}

.level-value,
.grade-value {
  font-weight: bold;
  color: #409eff;
}

.level-grade-table {
  margin-top: 15px;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .card-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .card-header > div {
    width: 100%;
    display: flex;
    justify-content: flex-end;
    gap: 8px;
  }
  
  .table-wrapper {
    -webkit-overflow-scrolling: touch;
  }
  
  .type-name,
  .status-name {
    font-size: 13px;
  }
  
  .type-value,
  .status-value {
    font-size: 14px;
  }
  
  .award-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .award-header .el-radio-group {
    width: 100%;
    display: flex;
  }
  
  .award-section h4 {
    font-size: 14px;
  }
}

@media (max-width: 480px) {
  .ratio-link {
    font-size: 14px;
  }
}
</style>

