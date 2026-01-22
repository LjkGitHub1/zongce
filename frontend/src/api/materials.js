import request from './request'

// 课题项目
export function getResearchProjects(params) {
  return request({
    url: '/materials/research-projects/',
    method: 'get',
    params
  })
}

export function createResearchProject(data) {
  return request({
    url: '/materials/research-projects/',
    method: 'post',
    data
  })
}

export function updateResearchProject(id, data) {
  return request({
    url: `/materials/research-projects/${id}/`,
    method: 'put',
    data
  })
}

export function deleteResearchProject(id) {
  return request({
    url: `/materials/research-projects/${id}/`,
    method: 'delete'
  })
}

export function uploadResearchProjectFiles(id, files) {
  if (!files || files.length === 0) {
    return Promise.reject(new Error('没有要上传的文件'))
  }
  
  const formData = new FormData()
  files.forEach(file => {
    if (file) {
      formData.append('files', file)
    }
  })
  
  return request({
    url: `/materials/research-projects/${id}/upload_files/`,
    method: 'post',
    data: formData
    // 注意：不要手动设置 Content-Type，让浏览器自动设置（包括 boundary）
  })
}

// 科技竞赛
export function getTechnologyCompetitions(params) {
  return request({
    url: '/materials/technology-competitions/',
    method: 'get',
    params
  })
}

export function createTechnologyCompetition(data) {
  return request({
    url: '/materials/technology-competitions/',
    method: 'post',
    data
  })
}

export function updateTechnologyCompetition(id, data) {
  return request({
    url: `/materials/technology-competitions/${id}/`,
    method: 'put',
    data
  })
}

export function deleteTechnologyCompetition(id) {
  return request({
    url: `/materials/technology-competitions/${id}/`,
    method: 'delete'
  })
}

export function uploadTechnologyCompetitionFiles(id, files) {
  if (!files || files.length === 0) {
    return Promise.reject(new Error('没有要上传的文件'))
  }
  
  const formData = new FormData()
  files.forEach((file, index) => {
    if (!file) {
      console.warn(`文件 ${index} 为空，跳过`)
      return
    }
    formData.append('files', file)
  })
  
  // 检查 FormData 是否有文件
  if (!formData.has('files')) {
    return Promise.reject(new Error('没有有效的文件可以上传'))
  }
  
  return request({
    url: `/materials/technology-competitions/${id}/upload_files/`,
    method: 'post',
    data: formData
    // 注意：不要手动设置 Content-Type，让浏览器自动设置（包括 boundary）
  })
}

// 统计
export function getUserStatistics() {
  return request({
    url: '/materials/statistics/user/',
    method: 'get'
  })
}

export function getAdminStatistics() {
  return request({
    url: '/materials/statistics/admin/',
    method: 'get'
  })
}

export function getTechnologyCompetitionAwardStatistics(params) {
  return request({
    url: '/materials/statistics/technology-competition-awards/',
    method: 'get',
    params
  })
}

// 导出
export function exportUserMaterials() {
  return request({
    url: '/materials/export/user/',
    method: 'get',
    responseType: 'blob'
  })
}

// 一键下载所有班级材料
export function downloadAllByClass() {
  return request({
    url: '/materials/export/download-all-by-class/',
    method: 'get',
    responseType: 'blob'
  })
}

export function exportAllMaterials(params) {
  return request({
    url: '/materials/export/all/',
    method: 'get',
    params,
    responseType: 'blob'
  })
}

// 通用函數：根據類型獲取材料
export function getMaterialByType(type, params) {
  const typeMap = {
    research_project: getResearchProjects,
    monograph: getMonographs,
    paper: getPapers,
    other_academic: getOtherAcademics,
    technology_competition: getTechnologyCompetitions,
    social_practice: getSocialPractices,
    social_service: getSocialServices,
    other_practice: getOtherPractices
  }
  const func = typeMap[type]
  return func ? func(params) : Promise.reject(new Error('Unknown material type'))
}

// 專著
export function getMonographs(params) {
  return request({
    url: '/materials/monographs/',
    method: 'get',
    params
  })
}

export function createMonograph(data) {
  return request({
    url: '/materials/monographs/',
    method: 'post',
    data
  })
}

export function updateMonograph(id, data) {
  return request({
    url: `/materials/monographs/${id}/`,
    method: 'put',
    data
  })
}

export function deleteMonograph(id) {
  return request({
    url: `/materials/monographs/${id}/`,
    method: 'delete'
  })
}

export function uploadMonographFiles(id, files) {
  if (!files || files.length === 0) {
    return Promise.reject(new Error('没有要上传的文件'))
  }
  
  const formData = new FormData()
  files.forEach(file => {
    if (file) {
      formData.append('files', file)
    }
  })
  
  return request({
    url: `/materials/monographs/${id}/upload_files/`,
    method: 'post',
    data: formData
  })
}

// 論文
export function getPapers(params) {
  return request({
    url: '/materials/papers/',
    method: 'get',
    params
  })
}

export function createPaper(data) {
  return request({
    url: '/materials/papers/',
    method: 'post',
    data
  })
}

export function updatePaper(id, data) {
  return request({
    url: `/materials/papers/${id}/`,
    method: 'put',
    data
  })
}

export function deletePaper(id) {
  return request({
    url: `/materials/papers/${id}/`,
    method: 'delete'
  })
}

export function uploadPaperFiles(id, files) {
  if (!files || files.length === 0) {
    return Promise.reject(new Error('没有要上传的文件'))
  }
  
  const formData = new FormData()
  files.forEach(file => {
    if (file) {
      formData.append('files', file)
    }
  })
  
  return request({
    url: `/materials/papers/${id}/upload_files/`,
    method: 'post',
    data: formData
  })
}

// 其他學術成果
export function getOtherAcademics(params) {
  return request({
    url: '/materials/other-academics/',
    method: 'get',
    params
  })
}

export function createOtherAcademic(data) {
  return request({
    url: '/materials/other-academics/',
    method: 'post',
    data
  })
}

export function updateOtherAcademic(id, data) {
  return request({
    url: `/materials/other-academics/${id}/`,
    method: 'put',
    data
  })
}

export function deleteOtherAcademic(id) {
  return request({
    url: `/materials/other-academics/${id}/`,
    method: 'delete'
  })
}

export function uploadOtherAcademicFiles(id, files) {
  if (!files || files.length === 0) {
    return Promise.reject(new Error('没有要上传的文件'))
  }
  
  const formData = new FormData()
  files.forEach(file => {
    if (file) {
      formData.append('files', file)
    }
  })
  
  return request({
    url: `/materials/other-academics/${id}/upload_files/`,
    method: 'post',
    data: formData
  })
}

// 社會實踐調研
export function getSocialPractices(params) {
  return request({
    url: '/materials/social-practices/',
    method: 'get',
    params
  })
}

export function createSocialPractice(data) {
  return request({
    url: '/materials/social-practices/',
    method: 'post',
    data
  })
}

export function updateSocialPractice(id, data) {
  return request({
    url: `/materials/social-practices/${id}/`,
    method: 'put',
    data
  })
}

export function deleteSocialPractice(id) {
  return request({
    url: `/materials/social-practices/${id}/`,
    method: 'delete'
  })
}

export function uploadSocialPracticeFiles(id, files) {
  if (!files || files.length === 0) {
    return Promise.reject(new Error('没有要上传的文件'))
  }
  
  const formData = new FormData()
  files.forEach(file => {
    if (file) {
      formData.append('files', file)
    }
  })
  
  return request({
    url: `/materials/social-practices/${id}/upload_files/`,
    method: 'post',
    data: formData
  })
}

// 服務社會
export function getSocialServices(params) {
  return request({
    url: '/materials/social-services/',
    method: 'get',
    params
  })
}

export function createSocialService(data) {
  return request({
    url: '/materials/social-services/',
    method: 'post',
    data
  })
}

export function updateSocialService(id, data) {
  return request({
    url: `/materials/social-services/${id}/`,
    method: 'put',
    data
  })
}

export function deleteSocialService(id) {
  return request({
    url: `/materials/social-services/${id}/`,
    method: 'delete'
  })
}

export function uploadSocialServiceFiles(id, files) {
  if (!files || files.length === 0) {
    return Promise.reject(new Error('没有要上传的文件'))
  }
  
  const formData = new FormData()
  files.forEach(file => {
    if (file) {
      formData.append('files', file)
    }
  })
  
  return request({
    url: `/materials/social-services/${id}/upload_files/`,
    method: 'post',
    data: formData
  })
}

// 其他實踐活動
export function getOtherPractices(params) {
  return request({
    url: '/materials/other-practices/',
    method: 'get',
    params
  })
}

export function createOtherPractice(data) {
  return request({
    url: '/materials/other-practices/',
    method: 'post',
    data
  })
}

export function updateOtherPractice(id, data) {
  return request({
    url: `/materials/other-practices/${id}/`,
    method: 'put',
    data
  })
}

export function deleteOtherPractice(id) {
  return request({
    url: `/materials/other-practices/${id}/`,
    method: 'delete'
  })
}

export function uploadOtherPracticeFiles(id, files) {
  if (!files || files.length === 0) {
    return Promise.reject(new Error('没有要上传的文件'))
  }
  
  const formData = new FormData()
  files.forEach(file => {
    if (file) {
      formData.append('files', file)
    }
  })
  
  return request({
    url: `/materials/other-practices/${id}/upload_files/`,
    method: 'post',
    data: formData
  })
}

