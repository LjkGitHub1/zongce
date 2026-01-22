import request from './request'

// 审核
export function auditMaterial(data) {
  return request({
    url: '/system/audit/',
    method: 'post',
    data
  })
}

export function getAuditStatistics() {
  return request({
    url: '/system/audit/statistics/',
    method: 'get'
  })
}

// 公告
export function getAnnouncements(params) {
  return request({
    url: '/system/announcements/',
    method: 'get',
    params
  })
}

export function createAnnouncement(data) {
  return request({
    url: '/system/announcements/',
    method: 'post',
    data
  })
}

// 消息
export function getMessages(params) {
  return request({
    url: '/system/messages/',
    method: 'get',
    params
  })
}

export function markMessageRead(id) {
  return request({
    url: `/system/messages/${id}/mark_read/`,
    method: 'post'
  })
}

export function markAllMessagesRead() {
  return request({
    url: '/system/messages/mark_all_read/',
    method: 'post'
  })
}

// 获取所有材料（管理员）
export function getAllMaterials(params) {
  return request({
    url: '/materials/all/',
    method: 'get',
    params
  })
}

// 获取班级列表
export function getClassList() {
  return request({
    url: '/system/classes/',
    method: 'get'
  })
}

// 获取班级统计
export function getClassStatistics(params) {
  return request({
    url: '/system/classes/statistics/',
    method: 'get',
    params
  })
}

// 获取所有班级统计
export function getAllClassStatistics() {
  return request({
    url: '/system/classes/statistics/all/',
    method: 'get'
  })
}

// 获取未提交人员列表
export function getUnsubmittedStudents(params) {
  return request({
    url: '/system/classes/unsubmitted/',
    method: 'get',
    params
  })
}

// 权限配置
export function getPermissionConfigs(params) {
  return request({
    url: '/system/permission-configs/',
    method: 'get',
    params
  })
}

export function createPermissionConfig(data) {
  return request({
    url: '/system/permission-configs/',
    method: 'post',
    data
  })
}

export function updatePermissionConfig(id, data) {
  return request({
    url: `/system/permission-configs/${id}/`,
    method: 'patch',
    data
  })
}

export function deletePermissionConfig(id) {
  return request({
    url: `/system/permission-configs/${id}/`,
    method: 'delete'
  })
}

export function batchUpdatePermissions(identity, permissions) {
  return request({
    url: `/system/permission-configs/batch-update/`,
    method: 'post',
    data: {
      identity,
      permissions
    }
  })
}

// 获取当前用户权限
export function getUserPermissions() {
  return request({
    url: '/system/permissions/user/',
    method: 'get'
  })
}

// 操作日志
export function getOperationLogs(params) {
  return request({
    url: '/system/operation-logs/',
    method: 'get',
    params
  })
}

