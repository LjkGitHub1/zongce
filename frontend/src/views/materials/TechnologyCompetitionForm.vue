<template>
  <div class="form-page">
    <el-card>
    <template #header>
      <div class="card-header">
        <div class="header-content">
          <el-button 
            text 
            @click="handleBack"
            class="back-btn"
          >
            <el-icon><ArrowLeft /></el-icon>
            <span>返回</span>
          </el-button>
          <span class="page-title">{{ isEdit ? '编辑' : '添加' }}科技竞赛</span>
        </div>
      </div>
    </template>
    
    <el-form
      ref="formRef"
      :model="form"
      :rules="rules"
      :label-width="isMobile ? 'auto' : '120px'"
      :label-position="isMobile ? 'top' : 'right'"
      class="material-form"
    >
      <el-form-item label="赛事名称" prop="competition">
        <el-input v-model="form.competition" placeholder="请输入赛事名称" />
      </el-form-item>
      
      <el-form-item label="是否为白名单赛事">
        <el-radio-group v-model="form.is_whitelist">
          <el-radio :value="true">是</el-radio>
          <el-radio :value="false">否</el-radio>
        </el-radio-group>
      </el-form-item>
      
      <el-form-item label="作品名称" prop="title">
        <el-input v-model="form.title" placeholder="请输入作品名称" />
      </el-form-item>
      
      <el-form-item label="级别" prop="level">
        <el-select v-model="form.level" placeholder="请选择级别" style="width: 100%">
          <el-option label="国家级" value="national" />
          <el-option label="省级" value="provincial" />
          <el-option label="校级" value="school" />
          <el-option label="院级" value="college" />
        </el-select>
      </el-form-item>
      
      <el-form-item label="获奖时间" prop="award_date">
        <el-date-picker
          v-model="form.award_date"
          type="month"
          placeholder="请选择获奖时间"
          format="YYYY年MM月"
          value-format="YYYY-MM"
          style="width: 100%"
        />
      </el-form-item>
      
      <el-form-item label="获奖等级" prop="grade">
        <el-select
          v-model="form.grade"
          placeholder="请选择或输入获奖等级"
          filterable
          allow-create
          default-first-option
          style="width: 100%"
        >
          <el-option label="一等奖" value="一等奖" />
          <el-option label="二等奖" value="二等奖" />
          <el-option label="三等奖" value="三等奖" />
          <el-option label="优秀奖" value="优秀奖" />
        </el-select>
      </el-form-item>
      
      <el-form-item label="组织单位名称">
        <el-input v-model="form.organization" placeholder="请输入组织单位名称" />
      </el-form-item>
      
      <el-form-item label="团体/个人">
        <el-select v-model="form.group" placeholder="请选择团体或个人" style="width: 100%">
          <el-option label="团体" value="团体" />
          <el-option label="个人" value="个人" />
        </el-select>
      </el-form-item>
      
      <el-form-item label="负责人/参与者">
        <el-input
          v-model="form.author"
          type="textarea"
          :rows="3"
          :disabled="form.group === '个人'"
          :placeholder="form.group === '个人' ? '个人项目，自动填充为登录人' : '请输入负责人/参与者及顺序'"
        />
      </el-form-item>
      
      <el-form-item label="指导老师">
        <el-input v-model="form.supervisor" placeholder="请输入指导老师" />
      </el-form-item>
      
      <el-form-item label="证明材料" prop="files">
        <el-upload
          ref="uploadRef"
          :file-list="fileList"
          :auto-upload="false"
          :on-change="handleFileChange"
          :on-remove="handleFileRemove"
          multiple
          drag
        >
          <el-icon class="el-icon--upload"><upload-filled /></el-icon>
          <div class="el-upload__text">
            将文件拖到此处，或<em>点击上传</em>
          </div>
          <template #tip>
            <div class="el-upload__tip">
              支持 JPG、PNG、PDF、DOC、DOCX 格式，单文件不超过10MB
            </div>
          </template>
        </el-upload>
      </el-form-item>
      
      <el-form-item label="备注">
        <el-input
          v-model="form.remark"
          type="textarea"
          :rows="3"
          placeholder="请输入备注"
        />
      </el-form-item>
      
      <el-form-item>
        <el-button type="primary" @click="handleSubmit" :loading="loading">
          {{ isEdit ? '更新' : '提交' }}
        </el-button>
        <el-button @click="handleCancel">取消</el-button>
      </el-form-item>
    </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { UploadFilled, ArrowLeft } from '@element-plus/icons-vue'
import { getTechnologyCompetitions, createTechnologyCompetition, updateTechnologyCompetition, uploadTechnologyCompetitionFiles } from '@/api/materials'
import { useUserStore } from '@/stores/user'
import request from '@/api/request'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const formRef = ref(null)
const uploadRef = ref(null)
const loading = ref(false)
const fileList = ref([])
const filesToUpload = ref([])

const isEdit = ref(route.params.id ? true : false)

const form = reactive({
  competition: '',
  is_whitelist: true, // 默认为"是"
  title: '',
  level: '',
  award_date: '',
  grade: '',
  organization: '',
  group: '团体', // 默认为团体
  author: '',
  supervisor: '',
  remark: ''
})

// 监听团体/个人选择变化
watch(() => form.group, (newValue) => {
  if (newValue === '个人') {
    // 选择个人时，自动填充登录人姓名
    if (userStore.userInfo?.name) {
      form.author = userStore.userInfo.name
    }
  } else if (newValue === '团体') {
    // 选择团体时，清空负责人/参与者字段，允许用户输入
    form.author = ''
  }
})

const rules = {
  competition: [{ required: true, message: '请输入赛事名称', trigger: 'blur' }],
  title: [{ required: true, message: '请输入作品名称', trigger: 'blur' }],
  level: [{ required: true, message: '请选择级别', trigger: 'change' }],
  award_date: [{ required: true, message: '请选择获奖时间', trigger: 'change' }],
  files: [
    { 
      required: true, 
      validator: (rule, value, callback) => {
        if (filesToUpload.value.length === 0 && fileList.value.length === 0) {
          callback(new Error('请上传证明材料'))
        } else {
          callback()
        }
      }, 
      trigger: 'change' 
    }
  ]
}

const handleFileChange = (file, fileList) => {
  // 更新 fileList
  fileList.value = fileList
  // 只保留新上传的文件（有 raw 属性的）
  filesToUpload.value = fileList.map(f => f.raw).filter(Boolean)
  // 触发表单验证
  if (formRef.value) {
    formRef.value.validateField('files')
  }
}

const handleFileRemove = (file, fileList) => {
  // 更新 fileList
  fileList.value = fileList
  // 只保留新上传的文件（有 raw 属性的）
  filesToUpload.value = fileList.map(f => f.raw).filter(Boolean)
  // 触发表单验证
  if (formRef.value) {
    formRef.value.validateField('files')
  }
}

const handleBack = () => {
  router.back()
}

const handleCancel = () => {
  router.back()
}

const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        let material
        if (isEdit.value) {
          const response = await updateTechnologyCompetition(route.params.id, form)
          material = response.data
        } else {
          const response = await createTechnologyCompetition(form)
          material = response.data
        }
        
        // 上传文件
        if (filesToUpload.value.length > 0) {
          try {
            await uploadTechnologyCompetitionFiles(material.id, filesToUpload.value)
          } catch (uploadError) {
            const errorMsg = uploadError.response?.data?.error || uploadError.response?.data?.detail || '文件上传失败'
            const errorDetails = uploadError.response?.data?.details
            if (errorDetails && Array.isArray(errorDetails)) {
              ElMessage.error(`${errorMsg}: ${errorDetails.join('; ')}`)
            } else {
              ElMessage.error(errorMsg)
            }
            throw uploadError // 重新抛出错误，阻止后续操作
          }
        }
        
        ElMessage.success(isEdit.value ? '更新成功' : '提交成功')
        router.push('/materials')
      } catch (error) {
        // 如果是上传错误，已经在上面的 catch 中处理了
        if (!error.response?.data?.error) {
          ElMessage.error(error.response?.data?.detail || error.message || '操作失败')
        }
      } finally {
        loading.value = false
      }
    }
  })
}

// 检测移动端
const isMobile = ref(window.innerWidth < 768)
const checkMobile = () => {
  isMobile.value = window.innerWidth < 768
}
window.addEventListener('resize', checkMobile)

const loadMaterial = async () => {
  if (!isEdit.value) return
  
  try {
    const response = await getTechnologyCompetitions({ id: route.params.id })
    if (response.data.results && response.data.results.length > 0) {
      const data = response.data.results[0]
      
      // 填充表单数据
      Object.assign(form, {
        competition: data.competition || '',
        is_whitelist: data.is_whitelist !== undefined ? data.is_whitelist : true,
        title: data.title || '',
        level: data.level || '',
        award_date: data.award_date || '',
        grade: data.grade || '',
        organization: data.organization || '',
        group: data.group || '团体',
        author: data.author || '',
        supervisor: data.supervisor || '',
        remark: data.remark || ''
      })
      
      // 如果当前是个人项目，自动填充登录人姓名
      if (form.group === '个人' && userStore.userInfo?.name) {
        form.author = userStore.userInfo.name
      }
      
      // 加载已有文件列表
      await loadFiles()
    } else {
      ElMessage.error('材料不存在')
      router.push('/materials')
    }
  } catch (error) {
    console.error('加载材料数据失败:', error)
    ElMessage.error('加载材料数据失败: ' + (error.response?.data?.detail || error.message || '未知错误'))
    router.push('/materials')
  }
}

const loadFiles = async () => {
  if (!isEdit.value) return
  
  try {
    const response = await request({
      url: `/materials/technology-competitions/${route.params.id}/files/`,
      method: 'get'
    })
    
    // 将文件列表转换为 el-upload 需要的格式
    const files = response.data || []
    fileList.value = files.map(file => ({
      uid: file.id,
      name: file.original_name || file.file_name || '文件',
      url: file.file_url || '',
      status: 'success'
    }))
  } catch (error) {
    console.error('加载文件列表失败:', error)
    // 文件加载失败不影响表单显示
  }
}

onMounted(async () => {
  // 确保用户信息已加载
  if (!userStore.userInfo) {
    await userStore.fetchUserInfo()
  }
  
  // 如果当前是个人项目，自动填充登录人姓名
  if (form.group === '个人' && userStore.userInfo?.name) {
    form.author = userStore.userInfo.name
  }
  
  // 如果是编辑模式，加载材料数据
  if (isEdit.value) {
    await loadMaterial()
  }
})
</script>

<style scoped>
.form-page {
  padding: 0;
}

:deep(.el-card) {
  border: 1px solid #ebeef5;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

:deep(.el-card__header) {
  padding: 18px 20px;
  padding-left: 0 !important;
  border-bottom: 1px solid #ebeef5;
}

:deep(.el-card__body) {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: flex-start;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
  padding-left: 0;
  margin-left: 0;
}

.header-content {
  display: flex;
  align-items: center;
  gap: 15px;
  width: 100%;
}

.back-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #606266;
  font-size: 14px;
  padding: 6px 0 6px 0;
  margin-left: 0;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.back-btn:hover {
  color: #409eff;
  background-color: #ecf5ff;
}

.back-btn .el-icon {
  font-size: 16px;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.material-form :deep(.el-form-item__label) {
  font-weight: 500;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .card-header {
    padding-left: 0;
  }
  
  .header-content {
    gap: 12px;
  }
  
  .back-btn {
    padding: 5px 0 5px 0;
    margin-left: 0;
    font-size: 13px;
  }
  
  .page-title {
    font-size: 16px;
  }
  
  .material-form :deep(.el-form-item) {
    margin-bottom: 20px;
  }
  
  .material-form :deep(.el-form-item__label) {
    font-size: 14px;
    margin-bottom: 8px;
  }
  
  .material-form :deep(.el-form-item__content) {
    font-size: 14px;
  }
  
  .material-form :deep(.el-upload-dragger) {
    width: 100%;
  }
}
</style>

