<template>
  <div class="users-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
          <div>
            <el-button type="primary" @click="handleBulkImport">批量导入</el-button>
            <el-button type="primary" @click="handleAdd">添加用户</el-button>
          </div>
        </div>
      </template>
      
      <el-form :inline="true" class="filter-form">
        <el-form-item label="身份">
          <el-select
            v-model="filters.identity"
            placeholder="全部"
            clearable
            style="width: 150px"
            @change="loadUsers"
          >
            <el-option label="老师" value="teacher" />
            <el-option label="研究生" value="graduate" />
            <el-option label="本科生" value="undergraduate" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select
            v-model="filters.is_active"
            placeholder="全部"
            clearable
            style="width: 150px"
            @change="loadUsers"
          >
            <el-option label="激活" :value="true" />
            <el-option label="禁用" :value="false" />
          </el-select>
        </el-form-item>
        <el-form-item label="专业">
          <el-input
            v-model="filters.major"
            placeholder="搜索专业"
            clearable
            style="width: 200px"
            @keyup.enter="loadUsers"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadUsers">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
      
      <el-table :data="users" style="width: 100%" v-loading="loading">
        <el-table-column prop="student_id" label="学号" width="120" align="center" />
        <el-table-column prop="name" label="姓名" width="100" align="center" />
        <el-table-column prop="identity" label="身份" width="100" align="center">
          <template #default="scope">
            <el-tag :type="getIdentityType(scope.row.identity)">
              {{ getIdentityText(scope.row.identity) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="major" label="专业" width="150" align="center" />
        <el-table-column prop="class_name" label="班级" width="120" align="center" />
        <el-table-column prop="email" label="邮箱" width="180" align="center" />
        <el-table-column prop="phone" label="手机号" width="120" align="center" />
        <el-table-column prop="is_active" label="状态" width="80" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.is_active ? 'success' : 'danger'">
              {{ scope.row.is_active ? '激活' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="创建时间" width="180" align="center">
          <template #default="scope">
            {{ formatDateTime(scope.row.created_at) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right" align="center">
          <template #default="scope">
            <el-button link type="primary" @click="handleEdit(scope.row)">编辑</el-button>
            <el-button link type="danger" @click="handleDelete(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.size"
        :total="pagination.total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="loadUsers"
        @current-change="loadUsers"
        style="margin-top: 20px; justify-content: flex-end"
      />
    </el-card>
    
    <!-- 批量导入对话框 -->
    <el-dialog v-model="importDialogVisible" title="批量导入用户" width="600px">
      <el-alert
        title="导入说明"
        type="info"
        :closable="false"
        style="margin-bottom: 20px"
      >
        <template #default>
          <div>
            <p>1. Excel文件必须包含以下列：学号、姓名、身份</p>
            <p>2. 可选列：专业、班级、邮箱、手机号</p>
            <p>3. 身份值：老师、研究生、本科生</p>
            <p>4. 默认密码：Aa@2026</p>
          </div>
        </template>
      </el-alert>
      
      <el-upload
        ref="uploadRef"
        :auto-upload="false"
        :on-change="handleFileChange"
        :on-remove="handleFileRemove"
        :limit="1"
        accept=".xlsx,.xls"
        drag
      >
        <el-icon class="el-icon--upload"><upload-filled /></el-icon>
        <div class="el-upload__text">
          将Excel文件拖到此处，或<em>点击上传</em>
        </div>
        <template #tip>
          <div class="el-upload__tip">
            只能上传 Excel 文件（.xlsx, .xls）
          </div>
        </template>
      </el-upload>
      
      <div v-if="importResult" style="margin-top: 20px">
        <el-alert
          :title="importResult.message"
          :type="importResult.error_count > 0 ? 'warning' : 'success'"
          :closable="false"
        >
          <template #default>
            <div>
              <p>成功：{{ importResult.success_count }} 条</p>
              <p>失败：{{ importResult.error_count }} 条</p>
              <div v-if="importResult.errors && importResult.errors.length > 0" style="margin-top: 10px">
                <p><strong>错误详情：</strong></p>
                <ul style="margin: 5px 0; padding-left: 20px">
                  <li v-for="(error, index) in importResult.errors" :key="index">{{ error }}</li>
                </ul>
              </div>
            </div>
          </template>
        </el-alert>
      </div>
      
      <template #footer>
        <el-button @click="importDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleImportSubmit" :loading="importing">
          确定导入
        </el-button>
      </template>
    </el-dialog>
    
    <!-- 添加/编辑用户对话框 -->
    <el-dialog
      v-model="userDialogVisible"
      :title="isEdit ? '编辑用户' : '添加用户'"
      width="600px"
    >
      <el-form
        ref="userFormRef"
        :model="userForm"
        :rules="userFormRules"
        label-width="100px"
      >
        <el-form-item label="学号" prop="student_id">
          <el-input
            v-model="userForm.student_id"
            placeholder="请输入学号"
            :disabled="isEdit"
          />
        </el-form-item>
        <el-form-item label="姓名" prop="name">
          <el-input v-model="userForm.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="身份" prop="identity">
          <el-select
            v-model="userForm.identity"
            placeholder="请选择身份"
            style="width: 100%"
          >
            <el-option label="老师" value="teacher" />
            <el-option label="研究生" value="graduate" />
            <el-option label="本科生" value="undergraduate" />
          </el-select>
        </el-form-item>
        <el-form-item label="专业">
          <el-input v-model="userForm.major" placeholder="请输入专业" />
        </el-form-item>
        <el-form-item label="班级">
          <el-input v-model="userForm.class_name" placeholder="请输入班级" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="userForm.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="userForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="userForm.is_active" />
        </el-form-item>
      </el-form>
      
      <template #footer>
        <el-button @click="userDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleUserSubmit" :loading="submitting">
          {{ isEdit ? '更新' : '创建' }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { UploadFilled } from '@element-plus/icons-vue'
import {
  getUsers,
  createUser,
  updateUser,
  deleteUser,
  bulkImportUsers
} from '@/api/users'
import { formatDateTime } from '@/utils/date'

const loading = ref(false)
const importing = ref(false)
const submitting = ref(false)
const users = ref([])
const importDialogVisible = ref(false)
const userDialogVisible = ref(false)
const isEdit = ref(false)
const uploadRef = ref(null)
const userFormRef = ref(null)
const importFile = ref(null)
const importResult = ref(null)

const filters = reactive({
  identity: '',
  is_active: null,
  major: ''
})

const pagination = reactive({
  page: 1,
  size: 20,
  total: 0
})

const userForm = reactive({
  student_id: '',
  name: '',
  identity: '',
  major: '',
  class_name: '',
  email: '',
  phone: '',
  is_active: true
})

const userFormRules = {
  student_id: [{ required: true, message: '请输入学号', trigger: 'blur' }],
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  identity: [{ required: true, message: '请选择身份', trigger: 'change' }]
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

const loadUsers = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.page,
      page_size: pagination.size
    }
    if (filters.identity) params.identity = filters.identity
    if (filters.is_active !== null) params.is_active = filters.is_active
    if (filters.major) params.major = filters.major
    
    const response = await getUsers(params)
    users.value = response.data.results || []
    pagination.total = response.data.count || 0
  } catch (error) {
    ElMessage.error('加载用户列表失败')
  } finally {
    loading.value = false
  }
}

const handleReset = () => {
  filters.identity = ''
  filters.is_active = null
  filters.major = ''
  loadUsers()
}

const handleBulkImport = () => {
  importDialogVisible.value = true
  importFile.value = null
  importResult.value = null
  if (uploadRef.value) {
    uploadRef.value.clearFiles()
  }
}

const handleFileChange = (file) => {
  importFile.value = file.raw
}

const handleFileRemove = () => {
  importFile.value = null
}

const handleImportSubmit = async () => {
  if (!importFile.value) {
    ElMessage.warning('请选择要导入的Excel文件')
    return
  }
  
  importing.value = true
  try {
    const response = await bulkImportUsers(importFile.value)
    importResult.value = response.data
    if (response.data.error_count === 0) {
      ElMessage.success('导入成功')
      setTimeout(() => {
        importDialogVisible.value = false
        loadUsers()
      }, 2000)
    } else {
      ElMessage.warning(response.data.message)
    }
  } catch (error) {
    ElMessage.error(error.response?.data?.error || '导入失败')
  } finally {
    importing.value = false
  }
}

const handleAdd = () => {
  isEdit.value = false
  Object.assign(userForm, {
    student_id: '',
    name: '',
    identity: '',
    major: '',
    class_name: '',
    email: '',
    phone: '',
    is_active: true
  })
  userDialogVisible.value = true
}

const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(userForm, {
    student_id: row.student_id,
    name: row.name,
    identity: row.identity,
    major: row.major || '',
    class_name: row.class_name || '',
    email: row.email || '',
    phone: row.phone || '',
    is_active: row.is_active
  })
  userDialogVisible.value = true
}

const handleUserSubmit = async () => {
  if (!userFormRef.value) return
  
  await userFormRef.value.validate(async (valid) => {
    if (valid) {
      submitting.value = true
      try {
        if (isEdit.value) {
          const userId = users.value.find(u => u.student_id === userForm.student_id)?.id
          await updateUser(userId, userForm)
          ElMessage.success('更新成功')
        } else {
          // 创建用户时设置默认密码
          const createData = {
            ...userForm,
            password: 'Aa@2026'
          }
          await createUser(createData)
          ElMessage.success('创建成功，默认密码为：Aa@2026')
        }
        userDialogVisible.value = false
        loadUsers()
      } catch (error) {
        ElMessage.error(error.response?.data?.detail || '操作失败')
      } finally {
        submitting.value = false
      }
    }
  })
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除该用户吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await deleteUser(row.id)
    ElMessage.success('删除成功')
    loadUsers()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

onMounted(() => {
  loadUsers()
})
</script>

<style scoped>
.users-page {
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
</style>

