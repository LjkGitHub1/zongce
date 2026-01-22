<template>
  <el-container class="layout-container">
    <el-header class="layout-header">
      <div class="header-left">
        <el-button
          class="mobile-menu-btn"
          :icon="menuCollapsed ? Expand : Fold"
          @click="toggleMenu"
          circle
          text
        />
        <img src="@/assets/logo.png" alt="Logo" class="header-logo" />
        <h2 class="header-title">综测材料收集系统</h2>
      </div>
      <div class="header-right">
        <el-dropdown @command="handleCommand">
          <span class="user-info">
            <el-icon><User /></el-icon>
            <span class="user-name">{{ userStore.userInfo?.name || '用户' }}</span>
            <el-icon class="el-icon--right"><arrow-down /></el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="profile">个人中心</el-dropdown-item>
              <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </el-header>
    <el-container>
      <el-aside 
        :width="menuCollapsed ? '0px' : '200px'" 
        class="layout-aside"
        :class="{ 'collapsed': menuCollapsed }"
      >
        <el-menu
          :default-active="activeMenu"
          router
          class="sidebar-menu"
          :collapse="menuCollapsed"
        >
          <el-menu-item index="/dashboard">
            <el-icon><Odometer /></el-icon>
            <span>首页</span>
          </el-menu-item>
          <el-menu-item 
            v-if="hasModulePermission('materials')" 
            index="/materials"
          >
            <el-icon><Document /></el-icon>
            <span>我的材料</span>
          </el-menu-item>
          <el-menu-item 
            v-if="hasModulePermission('academic') || hasAnyAcademicPermission" 
            index="/materials/academic"
          >
            <el-icon><Reading /></el-icon>
            <span>学术成果</span>
          </el-menu-item>
          <el-menu-item 
            v-if="hasModulePermission('practice') || hasAnyPracticePermission" 
            index="/materials/practice"
          >
            <el-icon><Trophy /></el-icon>
            <span>服务与实践</span>
          </el-menu-item>
          <el-menu-item index="/audit" v-if="userStore.userInfo?.is_staff">
            <el-icon><DocumentChecked /></el-icon>
            <span>审核管理</span>
          </el-menu-item>
          <el-menu-item 
            v-if="hasModulePermission('statistics')" 
            index="/statistics"
          >
            <el-icon><DataAnalysis /></el-icon>
            <span>数据统计</span>
          </el-menu-item>
          <el-menu-item index="/logs" v-if="userStore.userInfo?.is_staff">
            <el-icon><Document /></el-icon>
            <span>日志监控</span>
          </el-menu-item>
          <el-menu-item index="/users" v-if="userStore.userInfo?.is_staff">
            <el-icon><UserFilled /></el-icon>
            <span>用户管理</span>
          </el-menu-item>
          <el-menu-item index="/permission" v-if="userStore.userInfo?.is_staff">
            <el-icon><Setting /></el-icon>
            <span>菜单权限管理</span>
          </el-menu-item>
        </el-menu>
      </el-aside>
      <el-main class="layout-main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed, onMounted, ref, onUnmounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { User, ArrowDown, Odometer, Document, Reading, Trophy, DocumentChecked, DataAnalysis, UserFilled, Setting, Fold, Expand } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { usePermissionStore } from '@/stores/permission'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const permissionStore = usePermissionStore()

const activeMenu = computed(() => route.path)
const menuCollapsed = ref(false)

// 检测是否是移动端
const isMobile = () => {
  return window.innerWidth < 768
}

// 检测屏幕宽度，自动折叠菜单
const checkScreenSize = () => {
  menuCollapsed.value = isMobile()
}

const toggleMenu = () => {
  menuCollapsed.value = !menuCollapsed.value
}

// 监听路由变化，移动端自动收起菜单
watch(() => route.path, () => {
  if (isMobile() && !menuCollapsed.value) {
    menuCollapsed.value = true
  }
})

onMounted(() => {
  checkScreenSize()
  window.addEventListener('resize', checkScreenSize)
})

onUnmounted(() => {
  window.removeEventListener('resize', checkScreenSize)
})

const hasModulePermission = (module) => {
  return permissionStore.hasModulePermission(module)
}

// 检查是否有任何学术成果类型的权限
const hasAnyAcademicPermission = computed(() => {
  return permissionStore.hasMaterialTypePermission('research_project') ||
         permissionStore.hasMaterialTypePermission('monograph') ||
         permissionStore.hasMaterialTypePermission('paper') ||
         permissionStore.hasMaterialTypePermission('other_academic')
})

// 检查是否有任何实践活动类型的权限
const hasAnyPracticePermission = computed(() => {
  return permissionStore.hasMaterialTypePermission('technology_competition') ||
         permissionStore.hasMaterialTypePermission('social_practice') ||
         permissionStore.hasMaterialTypePermission('social_service') ||
         permissionStore.hasMaterialTypePermission('other_practice')
})

// 确保权限已加载
onMounted(async () => {
  if (userStore.userInfo && (!permissionStore.permissions || !permissionStore.permissions.modules)) {
    await permissionStore.fetchPermissions()
  }
})

const handleCommand = async (command) => {
  if (command === 'logout') {
    try {
      await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      userStore.userLogout()
      router.push('/login')
    } catch {
      // 用户取消
    }
  } else if (command === 'profile') {
    router.push('/profile')
  }
}
</script>

<style scoped>
.layout-container {
  height: 100vh;
}

.layout-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #fff;
  border-bottom: 1px solid #e4e7ed;
  padding: 0 15px;
  height: 60px;
  position: relative;
  z-index: 1000;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.header-logo {
  height: 32px;
  width: auto;
  object-fit: contain;
}

.mobile-menu-btn {
  display: none;
}

.header-title {
  margin: 0;
  color: #409eff;
  font-size: 18px;
  white-space: nowrap;
}

.header-right {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  cursor: pointer;
  color: #606266;
  gap: 5px;
}

.user-name {
  display: inline-block;
}

.layout-aside {
  background: #fff;
  border-right: 1px solid #e4e7ed;
  transition: width 0.3s;
  overflow: hidden;
}

.layout-aside.collapsed {
  width: 0 !important;
  border-right: none;
}

.sidebar-menu {
  border-right: none;
  height: calc(100vh - 60px);
  overflow-y: auto;
}

.layout-main {
  background: #f5f5f5;
  padding: 15px;
  overflow-x: hidden;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .layout-header {
    padding: 0 10px;
  }
  
  .mobile-menu-btn {
    display: inline-flex !important;
  }
  
  .header-title {
    font-size: 16px;
  }
  
  .user-name {
    display: none;
  }
  
  .layout-main {
    padding: 10px;
  }
  
  .layout-aside {
    position: fixed;
    left: 0;
    top: 60px;
    height: calc(100vh - 60px);
    z-index: 999;
    box-shadow: 2px 0 8px rgba(0, 0, 0, 0.1);
  }
  
  .layout-aside.collapsed {
    transform: translateX(-100%);
  }
}

@media (max-width: 480px) {
  .header-title {
    font-size: 14px;
  }
  
  .layout-main {
    padding: 8px;
  }
}
</style>

