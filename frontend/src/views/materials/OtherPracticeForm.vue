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
            <span class="page-title">{{ isEdit ? '编辑' : '添加' }}其他实践活动</span>
          </div>
        </div>
      </template>
      
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        :label-width="isMobile ? 'auto' : '140px'"
        :label-position="isMobile ? 'top' : 'right'"
        class="material-form"
      >
        <el-form-item label="名称" prop="title">
          <el-input v-model="form.title" placeholder="请输入名称" />
        </el-form-item>
        
        <el-form-item label="级别">
          <el-select
            v-model="form.level"
            placeholder="请选择或输入级别"
            filterable
            allow-create
            default-first-option
            style="width: 100%"
          >
            <el-option label="国家级" value="national" />
            <el-option label="省级" value="provincial" />
            <el-option label="校级" value="school" />
            <el-option label="院级" value="college" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="时间">
          <el-date-picker
            v-model="form.date"
            type="date"
            placeholder="选择时间"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        
        <el-form-item label="提供证明单位">
          <el-input v-model="form.organization" placeholder="请输入提供证明单位" />
        </el-form-item>
        
        <el-form-item label="参与人">
          <el-input
            v-model="form.author"
            type="textarea"
            :rows="3"
            placeholder="请输入参与人"
          />
        </el-form-item>
        
        <el-form-item label="具体内容">
          <el-input
            v-model="form.content"
            type="textarea"
            :rows="4"
            placeholder="请输入具体内容"
          />
        </el-form-item>
        
        <el-form-item label="负责人联系电话">
          <el-input v-model="form.contact_phone" placeholder="请输入负责人联系电话" />
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
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { UploadFilled, ArrowLeft } from '@element-plus/icons-vue'
import {
  createOtherPractice,
  updateOtherPractice,
  getOtherPractices,
  uploadOtherPracticeFiles
} from '@/api/materials'

const route = useRoute()
const router = useRouter()

const formRef = ref(null)
const uploadRef = ref(null)
const loading = ref(false)
const fileList = ref([])
const filesToUpload = ref([])

const isEdit = ref(!!route.params.id)

const form = reactive({
  title: '',
  level: '',
  date: '',
  organization: '',
  author: '',
  content: '',
  contact_phone: '',
  remark: ''
})

const rules = {
  title: [{ required: true, message: '请输入名称', trigger: 'blur' }],
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

const handleFileChange = (file, files) => {
  filesToUpload.value = files.map(f => f.raw).filter(Boolean)
  // 触发表单验证
  if (formRef.value) {
    formRef.value.validateField('files')
  }
}

const handleFileRemove = () => {
  filesToUpload.value = []
  // 触发表单验证
  if (formRef.value) {
    formRef.value.validateField('files')
  }
}

const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        let material
        if (isEdit.value) {
          const response = await updateOtherPractice(route.params.id, form)
          material = response.data
        } else {
          const response = await createOtherPractice(form)
          material = response.data
        }
        
        // 上传文件
        if (filesToUpload.value.length > 0) {
          try {
            await uploadOtherPracticeFiles(material.id, filesToUpload.value)
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
        } else {
          // 新增模式下必须上传文件
          if (!isEdit.value) {
            ElMessage.error('请上传证明材料')
            return
          }
          // 编辑模式下，如果没有新上传的文件，检查是否有已存在的文件
          // 这里假设编辑模式下可以保留原有文件，所以不强制上传
        }
        
        ElMessage.success(isEdit.value ? '更新成功' : '提交成功')
        router.push('/materials')
      } catch (error) {
        ElMessage.error(error.response?.data?.detail || '操作失败')
      } finally {
        loading.value = false
      }
    }
  })
}

const handleBack = () => {
  router.back()
}

const handleCancel = () => {
  router.back()
}

// 检测移动端
const isMobile = ref(window.innerWidth < 768)
const checkMobile = () => {
  isMobile.value = window.innerWidth < 768
}

onMounted(async () => {
  window.addEventListener('resize', checkMobile)
  if (isEdit.value) {
    try {
      const response = await getOtherPractices({ id: route.params.id })
      if (response.data.results && response.data.results.length > 0) {
        const data = response.data.results[0]
        Object.assign(form, {
          title: data.title || '',
          level: data.level || '',
          date: data.date || '',
          organization: data.organization || '',
          author: data.author || '',
          content: data.content || '',
          contact_phone: data.contact_phone || '',
          remark: data.remark || ''
        })
      }
    } catch (error) {
      ElMessage.error('加载数据失败')
    }
  }
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
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

.material-form :deep(.el-form-item__label) {
  font-weight: 500;
}
</style>

