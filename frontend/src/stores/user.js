import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { login, getUserInfo } from '@/api/auth'
import { getToken, setToken, removeToken } from '@/utils/auth'

export const useUserStore = defineStore('user', () => {
  const token = ref(getToken())
  const userInfo = ref(null)

  const isAuthenticated = computed(() => !!token.value)

  async function userLogin(loginForm) {
    try {
      const response = await login(loginForm)
      const { access, refresh } = response.data
      setToken(access)
      token.value = access
      await fetchUserInfo()
      return { success: true }
    } catch (error) {
      return { success: false, message: error.response?.data?.detail || '登录失败' }
    }
  }

  async function fetchUserInfo() {
    try {
      const response = await getUserInfo()
      userInfo.value = response.data
      // 获取用户信息后，同时获取权限信息
      const { usePermissionStore } = await import('@/stores/permission')
      const permissionStore = usePermissionStore()
      await permissionStore.fetchPermissions()
    } catch (error) {
      console.error('获取用户信息失败:', error)
    }
  }

  function userLogout() {
    token.value = null
    userInfo.value = null
    removeToken()
  }

  return {
    token,
    userInfo,
    isAuthenticated,
    userLogin,
    fetchUserInfo,
    userLogout
  }
})

