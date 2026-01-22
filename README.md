# 综测材料收集系统

## 项目简介

综测材料收集系统是一个用于收集、管理和审核学生综合素质测评相关材料的在线平台。系统支持学生上传各类证明材料（学术成果、科技竞赛、社会实践等），管理员进行审核和统计。

## 技术栈

### 后端
- Django 5.0
- Django REST Framework
- Django REST Framework SimpleJWT
- django-filter
- Celery
- MySQL 8.0

### 前端
- Vue 3
- Element Plus
- Plus Pro Components
- Pinia
- Vue Router
- Axios
- Vite

## 项目结构

```
zongce/
├── backend/                 # Django后端
│   ├── apps/
│   │   ├── users/          # 用户管理
│   │   ├── materials/      # 材料管理
│   │   └── system/         # 系统管理
│   ├── config/             # 项目配置
│   ├── manage.py
│   └── requirements.txt
├── frontend/                # Vue前端
│   ├── src/
│   │   ├── api/            # API接口
│   │   ├── components/     # 组件
│   │   ├── layouts/        # 布局
│   │   ├── router/         # 路由
│   │   ├── stores/         # 状态管理
│   │   ├── utils/          # 工具函数
│   │   └── views/          # 页面
│   ├── package.json
│   └── vite.config.js
├── 需求文档.md
├── 数据库设计.md
└── README.md
```

## 快速开始

> 📖 **详细运行指南**：请查看 [项目运行指南.md](./项目运行指南.md)  
> 🚀 **快速启动**：请查看 [快速启动.md](./快速启动.md)

### 后端设置

1. 进入后端目录
```bash
cd backend
```

2. 创建虚拟环境（推荐）
```bash
python -m venv venv
venv\Scripts\activate  # Windows
```

3. 安装依赖
```bash
pip install -r requirements.txt
```

4. 配置数据库环境变量（创建 `.env` 文件或设置系统环境变量）
```
DB_NAME=zongce
DB_USER=root
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=3306
```

5. 创建数据库
```sql
CREATE DATABASE zongce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

6. 运行迁移
```bash
python manage.py makemigrations
python manage.py migrate
```

7. 创建超级用户
```bash
python manage.py createsuperuser
```

8. 启动开发服务器
```bash
python manage.py runserver
```

### 前端设置

1. 进入前端目录
```bash
cd frontend
```

2. 安装依赖
```bash
npm install
```

3. 启动开发服务器
```bash
npm run dev
```

## 功能模块

### ✅ 已完成功能

#### 后端
- ✅ 用户认证（注册、登录、JWT）
- ✅ 用户管理模型
- ✅ 材料管理模型（学术成果、服务与实践）
- ✅ 系统管理模型（审核记录、公告、消息等）
- ✅ RESTful API完整实现
- ✅ 文件上传功能
- ✅ 审核管理API
- ✅ 数据统计API
- ✅ 数据导出功能（CSV）

#### 前端
- ✅ 用户登录页面
- ✅ 主布局和路由
- ✅ 材料上传页面（科技竞赛）
- ✅ 材料列表和详情
- ✅ 审核管理页面
- ✅ 数据统计页面
- ✅ 数据导出功能

## API接口

### 认证相关
- `POST /api/auth/register/` - 用户注册
- `POST /api/auth/login/` - 用户登录
- `POST /api/auth/refresh/` - 刷新Token
- `GET /api/auth/info/` - 获取当前用户信息
- `GET/PUT /api/auth/profile/` - 用户个人信息

### 材料相关
- `GET /api/materials/research-projects/` - 课题项目列表
- `POST /api/materials/research-projects/` - 创建课题项目
- `GET /api/materials/technology-competitions/` - 科技竞赛列表
- `POST /api/materials/technology-competitions/` - 创建科技竞赛
- `POST /api/materials/{type}/{id}/upload_files/` - 上传文件
- `POST /api/materials/{type}/{id}/withdraw/` - 撤回材料
- ... (其他材料类型类似)

### 统计和导出
- `GET /api/materials/statistics/user/` - 用户统计
- `GET /api/materials/statistics/admin/` - 管理员统计
- `GET /api/materials/export/user/` - 导出用户材料清单
- `GET /api/materials/export/all/` - 导出所有材料（管理员）

### 系统管理
- `POST /api/system/audit/` - 审核材料
- `GET /api/system/audit/statistics/` - 审核统计
- `GET /api/system/announcements/` - 公告列表
- `GET /api/system/messages/` - 消息列表

## 开发说明

### 数据库模型

所有材料模型都包含基础字段：
- `student_id` - 学号
- `name` - 姓名
- `identity` - 身份（teacher/graduate/undergraduate）
- `status` - 状态（pending/auditing/approved/rejected/withdrawn）

### 权限说明

- **管理员（老师）**：拥有所有权限
- **研究生**：可提交所有材料模块
- **本科生**：目前只能提交科技竞赛模块（可配置）

### 材料状态

- `pending` - 待审核
- `auditing` - 审核中
- `approved` - 已通过
- `rejected` - 已驳回
- `withdrawn` - 已撤回

## 使用说明

1. **用户注册/登录**：使用学号和密码登录系统
2. **添加材料**：在"服务与实践"页面选择材料类型，填写信息并上传证明材料
3. **查看材料**：在"我的材料"页面查看所有提交的材料及其状态
4. **审核材料**（管理员）：在"审核管理"页面审核学生提交的材料
5. **数据统计**：查看个人或整体的材料统计信息
6. **数据导出**：导出材料清单为CSV文件

## 注意事项

1. 文件上传限制：单文件不超过10MB，支持格式：JPG、PNG、PDF、DOC、DOCX
2. 只有待审核状态的材料可以编辑或删除
3. 管理员可以审核所有材料，普通用户只能查看自己的材料
4. 数据导出功能需要相应的权限

## 参考文档

- [需求文档](./需求文档.md)
- [数据库设计](./数据库设计.md)

---

**项目状态**：✅ 核心功能已完成，可以投入使用
