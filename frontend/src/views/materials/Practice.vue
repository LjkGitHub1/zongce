<template>
  <div class="practice-page">
    <el-card>
      <template #header>
        <span>服务与实践</span>
      </template>
      <div class="material-types">
        <el-button
          v-if="hasPermission('technology_competition')"
          type="primary"
          size="large"
          @click="handleAdd('technology_competition')"
        >
          <el-icon><Trophy /></el-icon>
          科技竞赛
        </el-button>
        <el-button
          v-if="hasPermission('social_practice')"
          type="primary"
          size="large"
          @click="handleAdd('social_practice')"
        >
          <el-icon><Document /></el-icon>
          社会实践调研
        </el-button>
        <el-button
          v-if="hasPermission('social_service')"
          type="primary"
          size="large"
          @click="handleAdd('social_service')"
        >
          <el-icon><Service /></el-icon>
          服务社会
        </el-button>
        <el-button
          v-if="hasPermission('other_practice')"
          type="primary"
          size="large"
          @click="handleAdd('other_practice')"
        >
          <el-icon><More /></el-icon>
          其他实践活动
        </el-button>
        <el-empty v-if="!hasAnyPermission" description="您没有权限访问任何实践活动类型" />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Trophy, Document, Service, More } from '@element-plus/icons-vue'
import { usePermissionStore } from '@/stores/permission'

const router = useRouter()
const permissionStore = usePermissionStore()

// 确保权限已加载
onMounted(async () => {
  if (!permissionStore.permissions || !permissionStore.permissions.material_types) {
    await permissionStore.fetchPermissions()
  }
})

const hasPermission = (materialType) => {
  return permissionStore.hasMaterialTypePermission(materialType)
}

const hasAnyPermission = computed(() => {
  return hasPermission('technology_competition') ||
         hasPermission('social_practice') ||
         hasPermission('social_service') ||
         hasPermission('other_practice')
})

const handleAdd = (type) => {
  const typeMap = {
    technology_competition: '/materials/add/technology-competition',
    social_practice: '/materials/add/social-practice',
    social_service: '/materials/add/social-service',
    other_practice: '/materials/add/other-practice'
  }
  const path = typeMap[type]
  if (path) {
    router.push(path)
  }
}
</script>

<style scoped>
.practice-page {
  padding: 0;
}

.material-types {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  gap: 20px;
  align-items: stretch;
  justify-content: center;
  padding: 30px 40px;
  max-width: 100%;
  margin: 0 auto;
}

.material-types .el-button {
  flex: 1;
  min-width: 200px;
  max-width: 280px;
  height: 85px;
  font-size: 16px;
  font-weight: 500;
  display: flex !important;
  flex-direction: row;
  align-items: center;
  justify-content: flex-start !important;
  gap: 12px;
  padding-left: 24px !important;
  padding-right: 24px;
  padding-top: 0;
  padding-bottom: 0;
  border-radius: 8px;
  transition: all 0.3s ease;
  text-align: left;
  margin: 0;
}

.material-types .el-button :deep(span) {
  display: flex !important;
  align-items: center;
  justify-content: flex-start !important;
  width: 100%;
  margin: 0 !important;
  padding: 0 !important;
}

.material-types .el-button :deep(.el-icon) {
  margin: 0 !important;
  margin-right: 0 !important;
}

.material-types .el-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.25);
}

.material-types .el-button:active {
  transform: translateY(0);
}

.material-types .el-button .el-icon {
  font-size: 22px;
  flex-shrink: 0;
}

/* 平板端适配 */
@media (max-width: 992px) {
  .material-types {
    flex-direction: column;
    padding: 25px 30px;
    max-width: 450px;
    margin: 0 auto;
  }
  
  .material-types .el-button {
    width: 100%;
    max-width: 100%;
    height: 80px;
    font-size: 15px;
    padding: 0 20px;
  }
  
  .material-types .el-button:hover {
    transform: translateX(4px);
  }
  
  .material-types .el-button:active {
    transform: translateX(2px);
  }
  
  .material-types .el-button .el-icon {
    font-size: 20px;
  }
}

/* 移动端适配 */
@media (max-width: 768px) {
  .material-types {
    flex-direction: column;
    padding: 20px 20px;
    gap: 12px;
    max-width: 100%;
  }
  
  .material-types .el-button {
    width: 100%;
    max-width: 100%;
    height: 75px;
    font-size: 15px;
    padding: 0 18px;
    gap: 10px;
  }
  
  .material-types .el-button:hover {
    transform: translateX(4px);
  }
  
  .material-types .el-button:active {
    transform: translateX(2px);
  }
  
  .material-types .el-button .el-icon {
    font-size: 20px;
  }
}

@media (max-width: 480px) {
  .material-types {
    padding: 15px 15px;
    gap: 10px;
  }
  
  .material-types .el-button {
    height: 70px;
    font-size: 14px;
    padding: 0 15px;
    gap: 8px;
  }
  
  .material-types .el-button .el-icon {
    font-size: 18px;
  }
}
</style>

