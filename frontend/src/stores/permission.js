import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getUserPermissions } from '@/api/system'

export const usePermissionStore = defineStore('permission', () => {
  const permissions = ref({
    modules: {
      dashboard: true,
      materials: true,
      academic: true,
      practice: true,
      statistics: true
    },
    material_types: {
      research_project: true,
      monograph: true,
      paper: true,
      other_academic: true,
      technology_competition: true,
      social_practice: true,
      social_service: true,
      other_practice: true
    }
  })

  async function fetchPermissions() {
    try {
      const response = await getUserPermissions()
      permissions.value = response.data
      // 确保 dashboard 始终为 true
      if (permissions.value.modules) {
        permissions.value.modules.dashboard = true
      }
    } catch (error) {
      console.error('获取权限失败:', error)
      // 如果获取失败，至少保证 dashboard 可访问
      if (permissions.value.modules) {
        permissions.value.modules.dashboard = true
      }
    }
  }

  function hasModulePermission(module) {
    return permissions.value.modules[module] === true
  }

  function hasMaterialTypePermission(materialType) {
    return permissions.value.material_types[materialType] === true
  }

  return {
    permissions,
    fetchPermissions,
    hasModulePermission,
    hasMaterialTypePermission
  }
})

