#!/bin/bash

echo "===================================="
echo "启动综测材料收集系统 - 后端"
echo "===================================="

# 检查虚拟环境
if [ ! -d "venv" ]; then
    echo "创建虚拟环境..."
    python3 -m venv venv
fi

# 激活虚拟环境
echo "激活虚拟环境..."
source venv/bin/activate

# 检查依赖
echo "检查依赖..."
if ! pip list | grep -q Django; then
    echo "安装依赖..."
    pip install -r requirements.txt
fi

# 检查数据库迁移
echo "检查数据库迁移..."
python manage.py migrate

# 启动服务器
echo "===================================="
echo "启动Django开发服务器..."
echo "访问地址: http://127.0.0.1:8000"
echo "按 Ctrl+C 停止服务器"
echo "===================================="
python manage.py runserver

