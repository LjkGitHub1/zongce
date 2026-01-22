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
            <span class="page-title">{{ isEdit ? '编辑' : '添加' }}论文</span>
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
        <el-form-item label="论文題目" prop="title">
          <el-input v-model="form.title" placeholder="请输入论文題目" />
        </el-form-item>
        
        <el-form-item label="刊物名称">
          <el-input v-model="form.publication" placeholder="请输入刊物名称" />
        </el-form-item>
        
        <el-form-item label="类别">
          <el-input v-model="form.category" placeholder="请输入类别" />
        </el-form-item>
        
        <el-form-item label="刊号">
          <el-input v-model="form.publication_number" placeholder="请输入刊号" />
        </el-form-item>
        
        <el-form-item label="发表时间">
          <el-date-picker
            v-model="form.publication_date"
            type="date"
            placeholder="选择发表时间"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        
        <el-form-item label="期刊收录情况">
          <el-input v-model="form.journal_status" placeholder="请输入期刊收录情况" />
        </el-form-item>
        
        <el-form-item label="中科院分区">
          <el-input v-model="form.partition" placeholder="请输入中科院分区" />
        </el-form-item>
        
        <el-form-item label="导师姓名">
          <el-input v-model="form.supervisor" placeholder="请输入导师姓名" />
        </el-form-item>
        
        <el-form-item label="是否第一单位">
          <el-radio-group v-model="form.first_unit">
          <el-radio :value="true">是</el-radio>
          <el-radio :value="false">否</el-radio>
          </el-radio-group>
        </el-form-item>
        
        <el-form-item label="导师是否通讯">
          <el-radio-group v-model="form.communication">
          <el-radio :value="true">是</el-radio>
          <el-radio :value="false">否</el-radio>
          </el-radio-group>
        </el-form-item>
        
        <el-form-item label="作者及排名">
          <el-input
            v-model="form.author"
            type="textarea"
            :rows="3"
            placeholder="请输入作者及排名"
          />
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
  createPaper,
  updatePaper,
  getPapers,
  uploadPaperFiles
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
  publication: '',
  category: '',
  publication_number: '',
  publication_date: '',
  journal_status: '',
  partition: '',
  supervisor: '',
  first_unit: true, // 默认为"是"
  communication: true, // 默认为"是"
  author: '',
  remark: ''
})

const rules = {
  title: [{ required: true, message: '请输入论文題目', trigger: 'blur' }],
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
          const response = await updatePaper(route.params.id, form)
          material = response.data
        } else {
          const response = await createPaper(form)
          material = response.data
        }
        
        // 上传文件
        if (filesToUpload.value.length > 0) {
          try {
            await uploadPaperFiles(material.id, filesToUpload.value)
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
      const response = await getPapers({ id: route.params.id })
      if (response.data.results && response.data.results.length > 0) {
        const data = response.data.results[0]
        Object.assign(form, {
          title: data.title || '',
          publication: data.publication || '',
          category: data.category || '',
          publication_number: data.publication_number || '',
          publication_date: data.publication_date || '',
          journal_status: data.journal_status || '',
          partition: data.partition || '',
          supervisor: data.supervisor || '',
          first_unit: data.first_unit ?? false,
          communication: data.communication ?? false,
          author: data.author || '',
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

