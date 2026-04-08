<template>
  <div class="dashboard">
    <el-row :gutter="15">
      <el-col :xs="12" :sm="12" :md="6" :lg="6" :xl="6">
        <el-card>
          <div class="stat-item">
            <div class="stat-value">{{ stats.total }}</div>
            <div class="stat-label">材料总数</div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="12" :sm="12" :md="6" :lg="6" :xl="6">
        <el-card>
          <div class="stat-item">
            <div class="stat-value">{{ stats.pending }}</div>
            <div class="stat-label">待审核</div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="12" :sm="12" :md="6" :lg="6" :xl="6">
        <el-card>
          <div class="stat-item">
            <div class="stat-value">{{ stats.approved }}</div>
            <div class="stat-label">已通过</div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="12" :sm="12" :md="6" :lg="6" :xl="6">
        <el-card>
          <div class="stat-item">
            <div class="stat-value">{{ stats.rejected }}</div>
            <div class="stat-label">已驳回</div>
          </div>
        </el-card>
      </el-col>
    </el-row>
    
    <el-row :gutter="15" style="margin-top: 15px">
      <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
        <el-card class="quick-actions-card">
          <template #header>
            <span>快速操作</span>
          </template>
          <div class="quick-actions">
            <el-button
              v-if="hasModulePermission('academic')"
              type="primary"
              @click="$router.push('/materials/academic')"
              class="action-btn"
            >
              学术成果
            </el-button>
            <el-button
              v-if="hasModulePermission('practice')"
              type="primary"
              @click="$router.push('/materials/practice')"
              class="action-btn"
            >
              服务与实践
            </el-button>
            <el-button
              v-if="hasModulePermission('materials')"
              @click="$router.push('/materials')"
              class="action-btn"
            >
              我的材料
            </el-button>
            <el-button
              v-if="hasModulePermission('materials')"
              @click="handleExport"
              class="action-btn"
            >
              导出材料清单
            </el-button>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
        <el-card>
          <template #header>
            <span>材料类型分布</span>
          </template>
          <div class="type-stats">
            <div v-for="(value, key) in filteredTypeStats" :key="key" class="type-item">
              <span class="type-name">{{ getTypeName(key) }}</span>
              <span class="type-value">{{ value }}</span>
            </div>
            <div v-if="Object.keys(filteredTypeStats).length === 0" class="empty-tip">
              暂无数据
            </div>
          </div>
        </el-card>
      </el-col>
      
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getUserStatistics, getAdminStatistics, exportUserMaterials } from '@/api/materials'
import { usePermissionStore } from '@/stores/permission'
import { useUserStore } from '@/stores/user'

const permissionStore = usePermissionStore()
const userStore = useUserStore()

const stats = ref({
  total: 0,
  pending: 0,
  approved: 0,
  rejected: 0,
  by_type: {}
})

// 过滤材料类型统计，只显示有权限的类型
const filteredTypeStats = computed(() => {
  const filtered = {}
  for (const [key, value] of Object.entries(stats.value.by_type)) {
    if (permissionStore.hasMaterialTypePermission(key)) {
      filtered[key] = value
    }
  }
  return filtered
})

const hasModulePermission = (module) => {
  return permissionStore.hasModulePermission(module)
}

const getTypeName = (key) => {
  const names = {
    'research_project': '课题项目',
    'monograph': '专著',
    'paper': '论文',
    'other_academic': '其他学术成果',
    'technology_competition': '科技竞赛',
    'social_practice': '社会实践调研',
    'social_service': '服务社会',
    'other_practice': '其他实践活动'
  }
  return names[key] || key
}

const loadStatistics = async () => {
  try {
    // 根据用户角色调用不同的统计API
    let response
    if (userStore.userInfo?.is_staff) {
      // 管理员调用管理员统计API，获取所有用户的统计数据
      response = await getAdminStatistics()
    } else {
      // 普通用户调用用户统计API，获取当前用户的统计数据
      response = await getUserStatistics()
    }
    
    // 更新统计数据
    if (response.data) {
      stats.value = {
        total: response.data.total || 0,
        pending: response.data.by_status?.pending || 0,
        approved: response.data.by_status?.approved || 0,
        rejected: response.data.by_status?.rejected || 0,
        by_type: response.data.by_type || {}
      }
    }
  } catch (error) {
    console.error('加载统计数据失败:', error)
    ElMessage.error('加载统计数据失败: ' + (error.response?.data?.detail || error.message || '未知错误'))
  }
}

const handleExport = async () => {
  try {
    const response = await exportUserMaterials()
    const blob = new Blob([response.data], { type: 'text/csv;charset=utf-8' })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `材料清单_${new Date().getTime()}.csv`
    link.click()
    window.URL.revokeObjectURL(url)
    ElMessage.success('导出成功')
  } catch (error) {
    ElMessage.error('导出失败')
  }
}

onMounted(async () => {
  // 确保用户信息已加载
  if (!userStore.userInfo) {
    await userStore.fetchUserInfo()
  }
  
  // 确保权限已加载
  if (!permissionStore.permissions || !permissionStore.permissions.modules) {
    await permissionStore.fetchPermissions()
  }
  
  loadStatistics()
})
</script>

<style scoped>
.dashboard {
  padding: 0;
}

.stat-item {
  text-align: center;
  padding: 10px 0;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #409eff;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 13px;
  color: #909399;
}

.type-stats {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.type-item {
  display: flex;
  justify-content: space-between;
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
}

.type-name {
  color: #606266;
  font-size: 14px;
}

.type-value {
  font-weight: bold;
  color: #409eff;
  font-size: 14px;
}

.empty-tip {
  text-align: center;
  color: #909399;
  padding: 20px;
}

.quick-actions-card :deep(.el-card__body) {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 20px;
}

.quick-actions {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12px;
  width: 100%;
  max-width: 100%;
}

/* 确保按钮容器内的所有按钮都从同一位置开始 */
.quick-actions > .action-btn {
  align-self: center;
  margin-left: auto;
  margin-right: auto;
}

.action-btn {
  width: 100%;
  max-width: 300px;
  margin: 0 !important;
  padding: 12px 20px !important;
  box-sizing: border-box;
  text-align: left;
  justify-content: flex-start;
  border-width: 1px !important;
  min-height: 40px;
}

/* 统一所有按钮的边框和盒模型 */
.action-btn.el-button--primary,
.action-btn:not(.el-button--primary) {
  border-width: 1px !important;
  box-sizing: border-box !important;
}

.action-btn :deep(.el-button__inner) {
  width: 100%;
  text-align: left;
  justify-content: flex-start;
  display: flex;
  align-items: center;
  box-sizing: border-box;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .stat-value {
    font-size: 24px;
  }
  
  .stat-label {
    font-size: 12px;
  }
  
  .type-name,
  .type-value {
    font-size: 13px;
  }
  
  .action-btn {
    width: 100%;
    max-width: 100%;
    margin-bottom: 0;
  }
  
  .quick-actions {
    flex-direction: column;
    align-items: center;
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .stat-value {
    font-size: 20px;
  }
  
  .stat-label {
    font-size: 11px;
  }
}
</style>

