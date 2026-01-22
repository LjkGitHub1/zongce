@echo off
echo ====================================
echo 启动综测材料收集系统 - 前端
echo ====================================

REM 检查node_modules
if not exist "node_modules" (
    echo 安装依赖...
    call npm install
)

REM 启动开发服务器
echo ====================================
echo 启动前端开发服务器...
echo 访问地址: http://localhost:5173
echo 按 Ctrl+C 停止服务器
echo ====================================
npm run dev

pause

