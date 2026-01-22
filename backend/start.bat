@echo off
echo ====================================
echo 启动综测材料收集系统 - 后端
echo ====================================

REM 检查虚拟环境
if not exist "venv" (
    echo 创建虚拟环境...
    python -m venv venv
)

REM 激活虚拟环境
echo 激活虚拟环境...
call venv\Scripts\activate.bat

REM 检查依赖
echo 检查依赖...
pip list | findstr Django >nul
if errorlevel 1 (
    echo 安装依赖...
    pip install -r requirements.txt
)

REM 检查数据库迁移
echo 检查数据库迁移...
python manage.py showmigrations | findstr "\[ \]" >nul
if not errorlevel 1 (
    echo 运行数据库迁移...
    python manage.py migrate
)

REM 启动服务器
echo ====================================
echo 启动Django开发服务器...
echo 访问地址: http://127.0.0.1:8000
echo 按 Ctrl+C 停止服务器
echo ====================================
python manage.py runserver

pause

