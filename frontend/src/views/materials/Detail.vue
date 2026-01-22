<template>
  <div class="detail-page">
    <el-card v-loading="loading" class="detail-card">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <el-button circle @click="handleBack" style="margin-right: 10px;">
              <el-icon><ArrowLeft /></el-icon>
            </el-button>
            <span class="page-title">材料详情</span>
          </div>
          <div class="header-right">
            <el-button v-if="material && material.status === 'pending'" @click="handleEdit">编辑</el-button>
            <el-button type="primary" @click="handleBack">返回</el-button>
          </div>
        </div>
      </template>
      
      <div v-if="material" class="material-detail">
        <!-- 基本信息卡片 -->
        <el-card class="info-card" shadow="never">
          <template #header>
            <div class="card-title">
              <el-icon><InfoFilled /></el-icon>
              <span>基本信息</span>
            </div>
          </template>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="材料类型">
              <el-tag type="info">{{ materialTypeName }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="审核状态">
              <el-tag :type="getStatusType(material.status)">
                {{ getStatusText(material.status) }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="提交人">{{ material.name || '-' }}</el-descriptions-item>
            <el-descriptions-item label="学号">{{ material.student_id || '-' }}</el-descriptions-item>
            <el-descriptions-item label="班级">{{ material.class_name || '-' }}</el-descriptions-item>
            <el-descriptions-item label="提交时间">{{ formatDateTime(material.created_at) }}</el-descriptions-item>
          </el-descriptions>
        </el-card>
        
        <!-- 详细信息卡片 -->
        <el-card class="info-card" shadow="never" style="margin-top: 20px;" v-if="hasDetailFields">
          <template #header>
            <div class="card-title">
              <el-icon><Document /></el-icon>
              <span>详细信息</span>
            </div>
          </template>
          <div class="material-content">
            <el-descriptions :column="1" border>
              <el-descriptions-item 
                v-for="(value, key) in detailFields" 
                :key="key" 
                :label="getFieldLabel(key)"
              >
                <span class="field-value">{{ formatValue(value) }}</span>
              </el-descriptions-item>
            </el-descriptions>
          </div>
        </el-card>
        
        <!-- 证明材料卡片 -->
        <el-card v-if="files.length > 0" class="info-card" shadow="never" style="margin-top: 20px;">
          <template #header>
            <div class="card-title">
              <el-icon><FolderOpened /></el-icon>
              <span>证明材料 ({{ files.length }})</span>
            </div>
          </template>
          <el-table :data="files" style="width: 100%" stripe>
            <el-table-column prop="original_name" label="文件名" min-width="200" align="center">
              <template #default="scope">
                <div class="file-name">
                  <el-icon><Document /></el-icon>
                  <span>{{ scope.row.original_name }}</span>
                </div>
              </template>
            </el-table-column>
            <el-table-column prop="file_size" label="文件大小" width="120" align="center">
              <template #default="scope">
                {{ formatFileSize(scope.row) }}
              </template>
            </el-table-column>
            <el-table-column prop="created_at" label="上传时间" width="180" align="center">
              <template #default="scope">
                {{ formatDateTime(scope.row.created_at) }}
              </template>
            </el-table-column>
            <el-table-column label="操作" width="180" fixed="right" align="center">
              <template #default="scope">
                <el-button link type="primary" @click="handlePreview(scope.row)">
                  <el-icon><View /></el-icon>
                  预览
                </el-button>
                <el-button link type="primary" @click="handleDownload(scope.row)">
                  <el-icon><Download /></el-icon>
                  下载
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
        
        <!-- 空状态 -->
        <el-empty v-if="files.length === 0" description="暂无证明材料" style="margin-top: 20px;" />
      </div>
    </el-card>
    
    <!-- 文件预览弹窗 -->
    <el-dialog
      v-model="previewVisible"
      :title="previewFile?.original_name"
      width="90%"
      :close-on-click-modal="false"
      class="preview-dialog"
      destroy-on-close
    >
      <div class="preview-content">
        <!-- PDF预览 -->
        <iframe
          v-if="previewType === 'pdf'"
          :src="previewUrl"
          frameborder="0"
          class="preview-iframe"
        ></iframe>
        
        <!-- 图片预览 -->
        <div v-else-if="previewType === 'image'" class="image-preview">
          <img 
            :src="previewUrl" 
            alt="预览图片" 
            class="preview-image"
            @error="handleImageError"
            @load="handleImageLoad"
          />
        </div>
        
        <!-- Word文档预览（使用Office Online Viewer） -->
        <iframe
          v-else-if="previewType === 'word'"
          :src="wordPreviewUrl"
          frameborder="0"
          class="preview-iframe"
        ></iframe>
        
        <!-- 不支持预览的文件类型 -->
        <div v-else class="preview-not-supported">
          <el-icon class="preview-icon"><Document /></el-icon>
          <p>该文件类型不支持在线预览</p>
          <p class="preview-tip">支持预览的格式：PDF、Word文档（.doc/.docx）、图片（.jpg/.jpeg/.png/.gif）</p>
          <el-button type="primary" @click="handleDownload(previewFile)">
            <el-icon><Download /></el-icon>
            下载文件
          </el-button>
        </div>
      </div>
      
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="previewVisible = false">关闭</el-button>
          <el-button type="primary" @click="handleDownload(previewFile)">
            <el-icon><Download /></el-icon>
            下载文件
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, InfoFilled, Document, FolderOpened, View, Download } from '@element-plus/icons-vue'
import {
  getResearchProjects, getMonographs, getPapers, getOtherAcademics,
  getTechnologyCompetitions, getSocialPractices, getSocialServices, getOtherPractices
} from '@/api/materials'
import request from '@/api/request'
import { formatDateTime } from '@/utils/date'
import { getToken } from '@/utils/auth'

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const material = ref(null)
const files = ref([])
const previewVisible = ref(false)
const previewFile = ref(null)
const previewUrl = ref('')
const previewType = ref('')

const materialType = computed(() => {
  // 处理路由参数中的连字符和下划线
  const type = route.params.type
  const typeMap = {
    'research-project': 'research_project',
    'other-academic': 'other_academic',
    'technology-competition': 'technology_competition',
    'social-practice': 'social_practice',
    'social-service': 'social_service',
    'other-practice': 'other_practice'
  }
  return typeMap[type] || type
})

const materialTypeName = computed(() => {
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
  return typeMap[materialType.value] || materialType.value
})

const shouldShowField = (key) => {
  const hiddenFields = ['id', 'student_id', 'name', 'identity', 'status', 'created_at', 'updated_at', 'files']
  const value = material.value[key]
  // 排除隐藏字段、空值、空字符串、空数组
  if (hiddenFields.includes(key)) return false
  if (value === null || value === undefined) return false
  if (value === '') return false
  if (Array.isArray(value) && value.length === 0) return false
  return true
}

// 计算详细信息字段
const detailFields = computed(() => {
  if (!material.value) return {}
  const fields = {}
  for (const key in material.value) {
    if (shouldShowField(key)) {
      fields[key] = material.value[key]
    }
  }
  return fields
})

// 是否有详细信息字段
const hasDetailFields = computed(() => {
  return Object.keys(detailFields.value).length > 0
})

const getFieldLabel = (key) => {
  const labelMap = {
    project_name: '项目名称',
    level: '项目级别',
    start_date: '立项时间',
    end_date: '结题时间',
    funds: '项目经费',
    number: '项目编号',
    personnel: '主持人、参与人员及顺序',
    title: '标题',
    publish: '出版社',
    publish_date: '出版时间',
    supervisor: '导师姓名',
    word_count: '撰写字数',
    author: '作者及顺序',
    content: '内容',
    competition: '赛事名称',
    is_whitelist: '是否白名单赛事',
    award_date: '获奖时间',
    grade: '获奖等级',
    organization: '组织单位名称',
    group: '团体/个人',
    date: '活动时间',
    remark: '备注',
    publication: '刊物名称',
    category: '类别',
    publication_number: '刊号',
    journal_status: '期刊收录情况',
    partition: '中科院分区',
    first_unit: '是否第一单位',
    communication: '导师是否通讯',
    monograph_name: '专著名称',
    achievement_name: '成果名称'
  }
  return labelMap[key] || key
}

const formatValue = (value) => {
  if (typeof value === 'boolean') {
    return value ? '是' : '否'
  }
  if (typeof value === 'number') {
    // 如果是金额，添加单位
    if (value.toString().includes('.')) {
      return value.toFixed(2)
    }
    return value.toString()
  }
  if (value && typeof value === 'string' && value.length > 0) {
    return value
  }
  return value || '-'
}

const formatFileSize = (row) => {
  const size = row.file_size || 0
  if (size < 1024) return size + ' B'
  if (size < 1024 * 1024) return (size / 1024).toFixed(2) + ' KB'
  return (size / (1024 * 1024)).toFixed(2) + ' MB'
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
    approved: '已通過',
    rejected: '已駁回',
    withdrawn: '已撤回'
  }
  return texts[status] || status
}

const loadMaterial = async () => {
  loading.value = true
  try {
    let response
    const id = route.params.id
    
    // 根据材料类型调用对应的 API
    switch (materialType.value) {
      case 'research-project':
      case 'research_project':
        response = await getResearchProjects({ id })
        break
      case 'monograph':
        response = await getMonographs({ id })
        break
      case 'paper':
        response = await getPapers({ id })
        break
      case 'other-academic':
      case 'other_academic':
        response = await getOtherAcademics({ id })
        break
      case 'technology-competition':
      case 'technology_competition':
        response = await getTechnologyCompetitions({ id })
        break
      case 'social-practice':
      case 'social_practice':
        response = await getSocialPractices({ id })
        break
      case 'social-service':
      case 'social_service':
        response = await getSocialServices({ id })
        break
      case 'other-practice':
      case 'other_practice':
        response = await getOtherPractices({ id })
        break
      default:
        throw new Error('未知的材料类型')
    }
    
    if (response.data.results && response.data.results.length > 0) {
      material.value = response.data.results[0]
      // 加载文件列表
      await loadFiles()
    } else {
      ElMessage.error('材料不存在')
    }
  } catch (error) {
    console.error('加载材料详情失败:', error)
    ElMessage.error(error.response?.data?.detail || error.message || '加载材料详情失败')
  } finally {
    loading.value = false
  }
}

const loadFiles = async () => {
  try {
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
    const urlType = typeMap[materialType.value]
    if (!urlType) {
      console.error('未知的材料类型:', materialType.value)
      return
    }
    const response = await request({
      url: `/materials/${urlType}/${route.params.id}/files/`,
      method: 'get'
    })
    files.value = response.data || []
  } catch (error) {
    console.error('加载文件列表失败', error)
    // 文件加载失败不影响详情显示
  }
}

const handleEdit = () => {
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
  const routeType = typeMap[materialType.value]
  router.push(`/materials/edit/${routeType}/${route.params.id}`)
}

const handleBack = () => {
  router.back()
}

const handleDownload = async (file) => {
  if (!file) {
    ElMessage.error('文件信息不存在')
    return
  }
  
  try {
    // 优先使用 file_url（如果后端提供了）
    let fileUrl = file.file_url || file.file_path
    
    if (!fileUrl) {
      ElMessage.error('文件路径不存在')
      return
    }
    
    // 如果file_url/file_path不是完整URL，需要添加后端基础URL
    if (!fileUrl.startsWith('http://') && !fileUrl.startsWith('https://')) {
      const backendBaseURL = window.location.origin
      
      // 确保路径以 / 开头
      if (!fileUrl.startsWith('/')) {
        fileUrl = `/${fileUrl}`
      }
      fileUrl = `${backendBaseURL}${fileUrl}`
    }
    
    console.log('下载文件URL:', fileUrl)
    
    // 获取token
    const token = getToken()
    
    // 使用fetch下载文件，支持认证
    const headers = {
      'Accept': 'application/octet-stream, */*'
    }
    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }
    
    const response = await fetch(fileUrl, {
      method: 'GET',
      headers: headers,
      cache: 'no-cache'
    })
    
    if (!response.ok) {
      const errorText = await response.text()
      console.error('下载失败响应:', response.status, errorText)
      throw new Error(`下载失败: ${response.status} ${response.statusText}`)
    }
    
    // 获取文件blob
    const blob = await response.blob()
    
    // 验证blob大小
    if (file.file_size && blob.size > 0 && blob.size !== file.file_size) {
      console.warn(`文件大小不匹配: 期望 ${file.file_size} 字节, 实际 ${blob.size} 字节`)
    }
    
    // 确保blob有内容
    if (blob.size === 0) {
      throw new Error('下载的文件为空')
    }
    
    // 创建下载链接
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = file.original_name || file.file_name || 'download'
    link.style.display = 'none'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    
    // 释放URL对象
    setTimeout(() => {
      window.URL.revokeObjectURL(url)
    }, 100)
    
    ElMessage.success('文件下载成功')
  } catch (error) {
    console.error('下载文件失败:', error)
    ElMessage.error(error.message || '下载文件失败，请检查文件是否存在')
  }
}

const handlePreview = (file) => {
  previewFile.value = file
  
  // 获取文件扩展名，处理可能包含点号的情况
  let ext = file.file_ext?.toLowerCase() || ''
  // 移除前导点号
  if (ext.startsWith('.')) {
    ext = ext.substring(1)
  }
  
  // 如果没有 file_ext，尝试从文件名或 file_path 中提取
  if (!ext) {
    const fileName = file.original_name || file.file_name || file.file_path || ''
    const match = fileName.match(/\.([^.]+)$/)
    if (match) {
      ext = match[1].toLowerCase()
    }
  }
  
  console.log('预览文件:', file, '扩展名:', ext)
  
  // 构建完整的文件URL
  let fileUrl = file.file_url || file.file_path
  if (!fileUrl) {
    previewType.value = 'unsupported'
    previewVisible.value = true
    return
  }
  
  // 如果URL不是完整URL，使用相对路径（通过 Vite 代理访问）
  if (!fileUrl.startsWith('http://') && !fileUrl.startsWith('https://')) {
    // 确保路径以 / 开头
    if (!fileUrl.startsWith('/')) {
      fileUrl = `/${fileUrl}`
    }
    // 如果路径已经是 /media/ 开头，直接使用；否则添加 /media/ 前缀
    if (!fileUrl.startsWith('/media/')) {
      // file_path 可能是相对路径（如 technology_competition/1/file.png），需要添加 /media/ 前缀
      fileUrl = `/media${fileUrl}`
    }
    // 使用相对路径，让 Vite 代理处理（不需要添加 origin）
    // fileUrl 已经是 /media/xxx 格式，直接使用
  }
  
  console.log('预览文件URL:', fileUrl, '扩展名:', ext)
  
  // 判断文件类型
  if (['pdf'].includes(ext)) {
    previewType.value = 'pdf'
    previewUrl.value = fileUrl
    previewVisible.value = true
  } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].includes(ext)) {
    previewType.value = 'image'
    previewUrl.value = fileUrl
    previewVisible.value = true
  } else if (['doc', 'docx'].includes(ext)) {
    previewType.value = 'word'
    previewUrl.value = fileUrl
    previewVisible.value = true
  } else {
    console.warn('不支持的文件类型:', ext, file)
    previewType.value = 'unsupported'
    previewVisible.value = true
  }
}

// Word文档预览URL（使用Office Online Viewer）
const wordPreviewUrl = computed(() => {
  if (!previewFile.value || previewType.value !== 'word') return ''
  
  // 构建完整的文件URL
  let fileUrl = previewFile.value.file_url || previewFile.value.file_path
  if (!fileUrl) return ''
  
  // 如果URL不是完整URL，需要添加后端基础URL
  if (!fileUrl.startsWith('http://') && !fileUrl.startsWith('https://')) {
    const backendBaseURL = window.location.origin
    if (!fileUrl.startsWith('/')) {
      fileUrl = `/${fileUrl}`
    }
    if (!fileUrl.startsWith('/media/')) {
      fileUrl = `/media${fileUrl}`
    }
    fileUrl = `${backendBaseURL}${fileUrl}`
  }
  
  // 使用Office Online Viewer
  const encodedUrl = encodeURIComponent(fileUrl)
  return `https://view.officeapps.live.com/op/embed.aspx?src=${encodedUrl}`
})

// 图片加载错误处理
const handleImageError = (event) => {
  console.error('图片加载失败:', previewUrl.value, event)
  ElMessage.error('图片加载失败，请检查文件是否存在')
  // 如果图片加载失败，显示不支持预览的提示
  previewType.value = 'unsupported'
}

// 图片加载成功
const handleImageLoad = () => {
  console.log('图片加载成功:', previewUrl.value)
}

onMounted(() => {
  loadMaterial()
})
</script>

<style scoped>
.detail-page {
  padding: 20px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 60px);
}

.detail-card {
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.header-right {
  display: flex;
  gap: 10px;
}

.info-card {
  border-radius: 6px;
  border: 1px solid #ebeef5;
}

.card-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.card-title .el-icon {
  color: #409eff;
  font-size: 18px;
}

.material-detail {
  padding: 0;
}

.material-content {
  padding: 0;
}

.field-value {
  color: #606266;
  line-height: 1.8;
  word-break: break-word;
}

.file-name {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #606266;
}

.file-name .el-icon {
  color: #409eff;
}

:deep(.el-descriptions__label) {
  font-weight: 600;
  color: #606266;
  width: 150px;
}

:deep(.el-descriptions__content) {
  color: #303133;
}

:deep(.el-table) {
  border-radius: 4px;
}

:deep(.el-card__header) {
  background-color: #fafafa;
  border-bottom: 1px solid #ebeef5;
  padding: 16px 20px;
}

:deep(.el-card__body) {
  padding: 20px;
}

.preview-dialog {
  :deep(.el-dialog__body) {
    padding: 0;
  }
}

.preview-content {
  width: 100%;
  height: 70vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #f5f7fa;
}

.preview-iframe {
  width: 100%;
  height: 100%;
  border: none;
  background-color: #fff;
}

.image-preview {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: auto;
  background-color: #fff;
}

.preview-image {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
}

.preview-not-supported {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #909399;
  padding: 40px;
}

.preview-icon {
  font-size: 64px;
  color: #c0c4cc;
  margin-bottom: 20px;
}

.preview-not-supported p {
  margin: 10px 0;
  font-size: 16px;
  text-align: center;
}

.preview-tip {
  font-size: 14px;
  color: #c0c4cc;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style>


