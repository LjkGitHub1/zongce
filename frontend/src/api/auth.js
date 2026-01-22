import request from './request'

export function login(data) {
  return request({
    url: '/auth/login/',
    method: 'post',
    data
  })
}

export function register(data) {
  return request({
    url: '/auth/register/',
    method: 'post',
    data
  })
}

export function getUserInfo() {
  return request({
    url: '/auth/info/',
    method: 'get'
  })
}

export function updateProfile(data) {
  return request({
    url: '/auth/profile/',
    method: 'put',
    data
  })
}

export function changePassword(data) {
  return request({
    url: '/auth/change-password/',
    method: 'post',
    data
  })
}

