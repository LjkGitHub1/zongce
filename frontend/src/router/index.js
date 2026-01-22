import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/',
    component: () => import('@/layouts/MainLayout.vue'),
    redirect: '/dashboard',
    meta: { requiresAuth: true },
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/Dashboard.vue')
      },
      {
        path: 'materials',
        name: 'Materials',
        component: () => import('@/views/materials/Index.vue')
      },
      {
        path: 'materials/academic',
        name: 'AcademicMaterials',
        component: () => import('@/views/materials/Academic.vue')
      },
      {
        path: 'materials/practice',
        name: 'PracticeMaterials',
        component: () => import('@/views/materials/Practice.vue')
      },
      {
        path: 'materials/add/research-project',
        name: 'AddResearchProject',
        component: () => import('@/views/materials/ResearchProjectForm.vue')
      },
      {
        path: 'materials/add/monograph',
        name: 'AddMonograph',
        component: () => import('@/views/materials/MonographForm.vue')
      },
      {
        path: 'materials/add/paper',
        name: 'AddPaper',
        component: () => import('@/views/materials/PaperForm.vue')
      },
      {
        path: 'materials/add/other-academic',
        name: 'AddOtherAcademic',
        component: () => import('@/views/materials/OtherAcademicForm.vue')
      },
      {
        path: 'materials/add/technology-competition',
        name: 'AddTechnologyCompetition',
        component: () => import('@/views/materials/TechnologyCompetitionForm.vue')
      },
      {
        path: 'materials/add/social-practice',
        name: 'AddSocialPractice',
        component: () => import('@/views/materials/SocialPracticeForm.vue')
      },
      {
        path: 'materials/add/social-service',
        name: 'AddSocialService',
        component: () => import('@/views/materials/SocialServiceForm.vue')
      },
      {
        path: 'materials/add/other-practice',
        name: 'AddOtherPractice',
        component: () => import('@/views/materials/OtherPracticeForm.vue')
      },
      {
        path: 'materials/edit/research-project/:id',
        name: 'EditResearchProject',
        component: () => import('@/views/materials/ResearchProjectForm.vue')
      },
      {
        path: 'materials/edit/monograph/:id',
        name: 'EditMonograph',
        component: () => import('@/views/materials/MonographForm.vue')
      },
      {
        path: 'materials/edit/paper/:id',
        name: 'EditPaper',
        component: () => import('@/views/materials/PaperForm.vue')
      },
      {
        path: 'materials/edit/other-academic/:id',
        name: 'EditOtherAcademic',
        component: () => import('@/views/materials/OtherAcademicForm.vue')
      },
      {
        path: 'materials/edit/technology-competition/:id',
        name: 'EditTechnologyCompetition',
        component: () => import('@/views/materials/TechnologyCompetitionForm.vue')
      },
      {
        path: 'materials/edit/social-practice/:id',
        name: 'EditSocialPractice',
        component: () => import('@/views/materials/SocialPracticeForm.vue')
      },
      {
        path: 'materials/edit/social-service/:id',
        name: 'EditSocialService',
        component: () => import('@/views/materials/SocialServiceForm.vue')
      },
      {
        path: 'materials/edit/other-practice/:id',
        name: 'EditOtherPractice',
        component: () => import('@/views/materials/OtherPracticeForm.vue')
      },
      {
        path: 'audit',
        name: 'Audit',
        component: () => import('@/views/audit/Index.vue')
      },
      {
        path: 'statistics',
        name: 'Statistics',
        component: () => import('@/views/statistics/Index.vue')
      },
      {
        path: 'logs',
        name: 'Logs',
        component: () => import('@/views/logs/Index.vue'),
        meta: { requiresAdmin: true }
      },
      {
        path: 'materials/detail/:type/:id',
        name: 'MaterialDetail',
        component: () => import('@/views/materials/Detail.vue')
      },
      {
        path: 'users',
        name: 'Users',
        component: () => import('@/views/users/Index.vue'),
        meta: { requiresAdmin: true }
      },
      {
        path: 'profile',
        name: 'Profile',
        component: () => import('@/views/profile/Index.vue')
      },
      {
        path: 'permission',
        name: 'Permission',
        component: () => import('@/views/permission/Index.vue'),
        meta: { requiresAdmin: true }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to, from, next) => {
  const userStore = useUserStore()
  const isAuthenticated = userStore.isAuthenticated

  // 如果有 token 但没有用户信息，尝试获取用户信息
  if (isAuthenticated && !userStore.userInfo) {
    await userStore.fetchUserInfo()
  }

  if (to.meta.requiresAuth && !isAuthenticated) {
    next({ name: 'Login' })
  } else if (to.meta.requiresAdmin && (!userStore.userInfo || !userStore.userInfo.is_staff)) {
    // 需要管理员权限但用户不是管理员
    next({ name: 'Dashboard' })
  } else if (to.name === 'Login' && isAuthenticated) {
    next({ name: 'Dashboard' })
  } else {
    // 检查模块权限
    // Dashboard 和 Profile 页面始终允许访问
    const alwaysAllowedRoutes = ['Dashboard', 'Profile', 'Login']
    if (alwaysAllowedRoutes.includes(to.name)) {
      next()
      return
    }
    
    if (isAuthenticated && userStore.userInfo) {
      const { usePermissionStore } = await import('@/stores/permission')
      const permissionStore = usePermissionStore()
      
      // 如果权限未加载，先加载
      if (!permissionStore.permissions || !permissionStore.permissions.modules) {
        await permissionStore.fetchPermissions()
      }
      
      // 检查页面权限
      const routeModuleMap = {
        'Materials': 'materials',
        'AcademicMaterials': 'academic',
        'PracticeMaterials': 'practice',
        'Statistics': 'statistics'
      }
      
      const module = routeModuleMap[to.name]
      if (module && !permissionStore.hasModulePermission(module)) {
        ElMessage.warning('您没有权限访问此页面')
        // 如果是从其他页面跳转过来的，返回上一页，否则跳转到首页
        if (from.name && from.name !== 'Dashboard') {
          next(false) // 阻止导航
        } else {
          next({ name: 'Dashboard' })
        }
        return
      }
    }
    
    next()
  }
})

export default router

