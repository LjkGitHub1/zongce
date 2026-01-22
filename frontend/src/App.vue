<template>
  <router-view />
</template>

<script setup>
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#app {
  min-height: 100vh;
}

/* 全局移动端适配 */
@media (max-width: 768px) {
  /* 优化触摸目标大小 */
  .el-button {
    min-height: 44px;
    padding: 10px 15px;
  }
  
  /* 优化输入框 */
  .el-input__inner,
  .el-textarea__inner {
    font-size: 16px; /* 防止iOS自动缩放 */
  }
  
  /* 优化表格 */
  .el-table {
    font-size: 13px;
  }
  
  /* 优化卡片 */
  .el-card {
    margin-bottom: 10px;
  }
  
  /* 优化对话框 */
  .el-dialog {
    width: 95% !important;
    margin: 5vh auto;
  }
  
  /* 优化分页 */
  .el-pagination {
    justify-content: center;
  }
  
  .el-pagination .el-pagination__sizes,
  .el-pagination .el-pagination__jump {
    display: none;
  }
}

@media (max-width: 480px) {
  .el-button {
    font-size: 14px;
    padding: 8px 12px;
  }
  
  .el-card__header {
    padding: 12px;
    font-size: 14px;
  }
  
  .el-card__body {
    padding: 12px;
  }
}
</style>

