<template>
  <div class="profile-page">
    <el-card>
      <template #header>
        <span>个人中心</span>
      </template>
      
      <el-tabs v-model="activeTab">
        <el-tab-pane label="基本信息" name="info">
          <el-form
            ref="profileFormRef"
            :model="profileForm"
            :rules="profileRules"
            label-width="120px"
            style="max-width: 600px"
          >
            <el-form-item label="学号">
              <el-input v-model="profileForm.student_id" disabled />
            </el-form-item>
            <el-form-item label="姓名">
              <el-input v-model="profileForm.name" disabled />
            </el-form-item>
            <el-form-item label="身份">
              <el-input :value="getIdentityText(profileForm.identity)" disabled />
            </el-form-item>
            <el-form-item label="专业">
              <el-input v-model="profileForm.major" />
            </el-form-item>
            <el-form-item label="班级">
              <el-input v-model="profileForm.class_name" />
            </el-form-item>
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="profileForm.email" type="email" />
            </el-form-item>
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="profileForm.phone" />
            </el-form-item>
            <el-form-item label="注册时间">
              <el-input :value="formatDateTime(profileForm.created_at)" disabled />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleUpdateProfile" :loading="updating">
                保存修改
              </el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>
        
        <el-tab-pane label="修改密码" name="password">
          <el-form
            ref="passwordFormRef"
            :model="passwordForm"
            :rules="passwordRules"
            label-width="120px"
            style="max-width: 600px"
          >
            <el-form-item label="原密码" prop="old_password">
              <el-input
                v-model="passwordForm.old_password"
                type="password"
                show-password
                placeholder="请输入原密码"
              />
            </el-form-item>
            <el-form-item label="新密码" prop="new_password">
              <el-input
                v-model="passwordForm.new_password"
                type="password"
                show-password
                placeholder="请输入新密码（至少6位）"
              />
            </el-form-item>
            <el-form-item label="确认新密码" prop="new_password_confirm">
              <el-input
                v-model="passwordForm.new_password_confirm"
                type="password"
                show-password
                placeholder="请再次输入新密码"
              />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleChangePassword" :loading="changingPassword">
                修改密码
              </el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { getUserInfo, updateProfile, changePassword } from '@/api/auth'
import { formatDateTime } from '@/utils/date'

const userStore = useUserStore()

const activeTab = ref('info')
const updating = ref(false)
const changingPassword = ref(false)
const profileFormRef = ref(null)
const passwordFormRef = ref(null)

const profileForm = reactive({
  student_id: '',
  name: '',
  identity: '',
  major: '',
  class_name: '',
  email: '',
  phone: '',
  created_at: ''
})

const passwordForm = reactive({
  old_password: '',
  new_password: '',
  new_password_confirm: ''
})

const profileRules = {
  email: [
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ],
  phone: [
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ]
}

const passwordRules = {
  old_password: [
    { required: true, message: '请输入原密码', trigger: 'blur' }
  ],
  new_password: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ],
  new_password_confirm: [
    { required: true, message: '请确认新密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== passwordForm.new_password) {
          callback(new Error('两次密码输入不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]
}

const getIdentityText = (identity) => {
  const texts = {
    teacher: '老师',
    graduate: '研究生',
    undergraduate: '本科生'
  }
  return texts[identity] || identity
}

const loadProfile = async () => {
  try {
    const response = await getUserInfo()
    Object.assign(profileForm, response.data)
  } catch (error) {
    ElMessage.error('加载个人信息失败')
  }
}

const handleUpdateProfile = async () => {
  if (!profileFormRef.value) return
  
  await profileFormRef.value.validate(async (valid) => {
    if (valid) {
      updating.value = true
      try {
        await updateProfile({
          major: profileForm.major,
          class_name: profileForm.class_name,
          email: profileForm.email,
          phone: profileForm.phone
        })
        ElMessage.success('修改成功')
        // 重新获取用户信息
        await userStore.fetchUserInfo()
      } catch (error) {
        ElMessage.error(error.response?.data?.error || '修改失败')
      } finally {
        updating.value = false
      }
    }
  })
}

const handleChangePassword = async () => {
  if (!passwordFormRef.value) return
  
  await passwordFormRef.value.validate(async (valid) => {
    if (valid) {
      changingPassword.value = true
      try {
        await changePassword({
          old_password: passwordForm.old_password,
          new_password: passwordForm.new_password,
          new_password_confirm: passwordForm.new_password_confirm
        })
        ElMessage.success('密码修改成功，请重新登录')
        // 清空表单
        passwordForm.old_password = ''
        passwordForm.new_password = ''
        passwordForm.new_password_confirm = ''
        // 延迟退出登录
        setTimeout(() => {
          userStore.userLogout()
          window.location.href = '/login'
        }, 1500)
      } catch (error) {
        ElMessage.error(error.response?.data?.error || '密码修改失败')
      } finally {
        changingPassword.value = false
      }
    }
  })
}

onMounted(() => {
  loadProfile()
})
</script>

<style scoped>
.profile-page {
  padding: 0px;
}
</style>

