<template>
  <div class="permission-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>菜单权限管理</span>
        </div>
      </template>
      
      <el-form :inline="true" class="filter-form" style="margin-bottom: 20px">
        <el-form-item label="选择身份">
          <el-select v-model="selectedIdentity" placeholder="请选择身份" style="width: 200px" @change="loadPermissionForIdentity">
            <el-option label="研究生" value="graduate" />
            <el-option label="本科生" value="undergraduate" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSave" :loading="saving">保存权限配置</el-button>
        </el-form-item>
      </el-form>

      <div v-if="selectedIdentity" class="permission-config">
        <!-- 一级菜单权限 -->
        <div class="module-section">
          <h3>一级菜单权限</h3>
          <el-checkbox-group v-model="selectedModules">
            <el-checkbox
              v-for="module in moduleList"
              :key="module.value"
              :value="module.value"
              :disabled="module.value === 'dashboard'"
            >
              {{ module.label }}
            </el-checkbox>
          </el-checkbox-group>
          <el-alert
            type="info"
            :closable="false"
            style="margin-top: 10px"
          >
            首页权限始终开启，不可修改
          </el-alert>
        </div>

        <!-- 二级按钮权限 - 学术成果 -->
        <div class="material-section" v-if="selectedModules.includes('academic')">
          <h3>学术成果 - 二级按钮权限</h3>
          <el-checkbox-group v-model="selectedMaterialTypes.academic">
            <el-checkbox
              v-for="type in academicMaterialTypes"
              :key="type.value"
              :value="type.value"
            >
              {{ type.label }}
            </el-checkbox>
          </el-checkbox-group>
        </div>

        <!-- 二级按钮权限 - 服务与实践 -->
        <div class="material-section" v-if="selectedModules.includes('practice')">
          <h3>服务与实践 - 二级按钮权限</h3>
          <el-checkbox-group v-model="selectedMaterialTypes.practice">
            <el-checkbox
              v-for="type in practiceMaterialTypes"
              :key="type.value"
              :value="type.value"
            >
              {{ type.label }}
            </el-checkbox>
          </el-checkbox-group>
        </div>

        <el-empty v-if="!selectedIdentity" description="请先选择身份" />
      </div>
      <el-empty v-else description="请先选择身份进行权限配置" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { ElMessage } from 'element-plus'
import {
  getPermissionConfigs,
  batchUpdatePermissions
} from '@/api/system'

const selectedIdentity = ref('')
const saving = ref(false)
const isLoading = ref(false) // 标记是否正在加载权限
const selectedModules = ref([])
const selectedMaterialTypes = reactive({
  academic: [],
  practice: []
})

const moduleList = [
  { label: '首页', value: 'dashboard' },
  { label: '我的材料', value: 'materials' },
  { label: '学术成果', value: 'academic' },
  { label: '服务与实践', value: 'practice' },
  { label: '数据统计', value: 'statistics' }
]

const academicMaterialTypes = [
  { label: '课题项目', value: 'research_project' },
  { label: '专著', value: 'monograph' },
  { label: '论文', value: 'paper' },
  { label: '其他学术成果', value: 'other_academic' }
]

const practiceMaterialTypes = [
  { label: '科技竞赛', value: 'technology_competition' },
  { label: '社会实践调研', value: 'social_practice' },
  { label: '服务社会', value: 'social_service' },
  { label: '其他实践活动', value: 'other_practice' }
]

// 监听模块选择变化
watch(() => selectedModules.value, (newVal, oldVal) => {
  // 如果正在加载权限，不执行自动全选逻辑
  if (isLoading.value) {
    return
  }
  
  // 只在用户手动操作时才自动全选（oldVal 存在且不包含该模块，说明是用户新勾选的）
  if (oldVal !== undefined) {
    // 当选择学术成果模块时，如果之前没有选中，则默认全选所有学术成果类型
    if (newVal.includes('academic') && !oldVal.includes('academic')) {
      // 如果当前没有任何学术成果类型被选中，则全选
      if (selectedMaterialTypes.academic.length === 0) {
        selectedMaterialTypes.academic = academicMaterialTypes.map(t => t.value)
      }
    }
    // 当取消选择学术成果模块时，清空对应的材料类型
    if (!newVal.includes('academic')) {
      selectedMaterialTypes.academic = []
    }
    
    // 当选择服务与实践模块时，如果之前没有选中，则默认全选所有服务与实践类型
    if (newVal.includes('practice') && !oldVal.includes('practice')) {
      // 如果当前没有任何服务与实践类型被选中，则全选
      if (selectedMaterialTypes.practice.length === 0) {
        selectedMaterialTypes.practice = practiceMaterialTypes.map(t => t.value)
      }
    }
    // 当取消选择服务与实践模块时，清空对应的材料类型
    if (!newVal.includes('practice')) {
      selectedMaterialTypes.practice = []
    }
  }
}, { deep: true })

// 加载指定身份的权限配置
const loadPermissionForIdentity = async () => {
  if (!selectedIdentity.value) {
    selectedModules.value = []
    selectedMaterialTypes.academic = []
    selectedMaterialTypes.practice = []
    return
  }

  isLoading.value = true // 标记开始加载
  try {
    const response = await getPermissionConfigs({
      identity: selectedIdentity.value,
      page_size: 1000
    })
    
    const permissions = response.data.results || []
    
    // 初始化选中状态
    selectedModules.value = []
    selectedMaterialTypes.academic = []
    selectedMaterialTypes.practice = []
    
    // 首页始终选中
    selectedModules.value.push('dashboard')
    
    // 根据权限配置设置选中状态
    permissions.forEach(perm => {
      if (perm.is_enabled) {
        // 模块权限（没有 material_type 表示整个模块）
        if (perm.module && !perm.material_type) {
          if (!selectedModules.value.includes(perm.module)) {
            selectedModules.value.push(perm.module)
          }
        }
        // 材料类型权限
        if (perm.material_type) {
          const materialType = perm.material_type
          if (academicMaterialTypes.find(t => t.value === materialType)) {
            if (!selectedMaterialTypes.academic.includes(materialType)) {
              selectedMaterialTypes.academic.push(materialType)
            }
            // 如果选择了材料类型，确保模块也被选中
            if (!selectedModules.value.includes('academic')) {
              selectedModules.value.push('academic')
            }
          } else if (practiceMaterialTypes.find(t => t.value === materialType)) {
            if (!selectedMaterialTypes.practice.includes(materialType)) {
              selectedMaterialTypes.practice.push(materialType)
            }
            // 如果选择了材料类型，确保模块也被选中
            if (!selectedModules.value.includes('practice')) {
              selectedModules.value.push('practice')
            }
          }
        }
      }
    })
  } catch (error) {
    ElMessage.error('加载权限配置失败')
    console.error('加载权限配置失败:', error)
  } finally {
    isLoading.value = false // 标记加载完成
  }
}

// 保存权限配置
const handleSave = async () => {
  if (!selectedIdentity.value) {
    ElMessage.warning('请先选择身份')
    return
  }

  saving.value = true
  try {
    // 构建权限配置数据
    const permissions = []
    
    // 添加模块权限（不包括材料类型）
    selectedModules.value.forEach(module => {
      permissions.push({
        identity: selectedIdentity.value,
        module: module,
        material_type: null,
        is_enabled: true
      })
    })
    
    // 添加学术成果的材料类型权限
    selectedMaterialTypes.academic.forEach(materialType => {
      permissions.push({
        identity: selectedIdentity.value,
        module: 'academic',
        material_type: materialType,
        is_enabled: true
      })
    })
    
    // 添加服务与实践的材料类型权限
    selectedMaterialTypes.practice.forEach(materialType => {
      permissions.push({
        identity: selectedIdentity.value,
        module: 'practice',
        material_type: materialType,
        is_enabled: true
      })
    })
    
    await batchUpdatePermissions(selectedIdentity.value, permissions)
    ElMessage.success('权限配置保存成功')
  } catch (error) {
    const errorMsg = error.response?.data?.error || error.response?.data?.detail || '保存权限配置失败'
    ElMessage.error(errorMsg)
    console.error('保存权限配置失败:', error)
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  // 页面加载时不自动加载，等待用户选择身份
})
</script>

<style scoped>
.permission-page {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.filter-form {
  margin-bottom: 20px;
}

.permission-config {
  padding: 20px;
  background: #f5f7fa;
  border-radius: 4px;
}

.module-section,
.material-section {
  margin-bottom: 30px;
  padding: 20px;
  background: white;
  border-radius: 4px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.module-section h3,
.material-section h3 {
  margin-top: 0;
  margin-bottom: 15px;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.el-checkbox-group {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
}

.el-checkbox {
  margin-right: 0;
}
</style>
