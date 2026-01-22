import request from './request'

// 获取用户列表
export function getUsers(params) {
  return request({
    url: '/auth/users/',
    method: 'get',
    params
  })
}

// 创建用户
export function createUser(data) {
  return request({
    url: '/auth/users/',
    method: 'post',
    data
  })
}

// 更新用户
export function updateUser(id, data) {
  return request({
    url: `/auth/users/${id}/`,
    method: 'put',
    data
  })
}

// 删除用户
export function deleteUser(id) {
  return request({
    url: `/auth/users/${id}/`,
    method: 'delete'
  })
}

// 批量导入用户
export function bulkImportUsers(file) {
  const formData = new FormData()
  formData.append('file', file)
  return request({
    url: '/auth/users/bulk_import/',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

