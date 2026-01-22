import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'

import App from './App.vue'
import router from './router'

const app = createApp(App)

// 注册所有图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

app.use(createPinia())
app.use(router)
app.use(ElementPlus, { locale: zhCn })

// 保存原始的 console.error
const originalConsoleError = console.error

// 覆盖 console.error 来过滤浏览器扩展相关的错误
console.error = function(...args) {
  const message = args.join(' ')
  // 过滤掉浏览器扩展相关的错误
  if (
    message.includes('runtime.lastError') ||
    message.includes('message port closed') ||
    message.includes('Extension context invalidated') ||
    message.includes('Unchecked runtime.lastError')
  ) {
    return // 不输出这些错误
  }
  // 其他错误正常输出
  originalConsoleError.apply(console, args)
}

// 过滤浏览器扩展相关的错误
window.addEventListener('error', (event) => {
  // 过滤掉浏览器扩展相关的错误
  if (event.message && (
    event.message.includes('runtime.lastError') ||
    event.message.includes('message port closed') ||
    event.message.includes('Extension context invalidated') ||
    event.message.includes('Unchecked runtime.lastError')
  )) {
    event.preventDefault()
    event.stopPropagation()
    return false
  }
}, true) // 使用捕获阶段

// 过滤未捕获的 Promise 错误
window.addEventListener('unhandledrejection', (event) => {
  // 过滤掉浏览器扩展相关的错误
  const reason = event.reason
  const message = reason?.message || reason?.toString() || ''
  if (
    message.includes('runtime.lastError') ||
    message.includes('message port closed') ||
    message.includes('Extension context invalidated') ||
    message.includes('Unchecked runtime.lastError')
  ) {
    event.preventDefault()
    return false
  }
})

app.mount('#app')

