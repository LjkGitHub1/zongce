# 综测材料收集系统 - 后端

## 技术栈
- Django 5.0
- Django REST Framework
- Django REST Framework SimpleJWT
- django-filter
- Celery
- MySQL 8.0

## 安装步骤

1. 创建虚拟环境
```bash
python -m venv venv
venv\Scripts\activate  # Windows
```

2. 安装依赖
```bash
pip install -r requirements.txt
```

3. 配置数据库

**注意**：本項目使用 `PyMySQL` 替代 `mysqlclient`，因為：
- Windows 上安裝 `mysqlclient` 需要編譯 C 擴展，容易出錯
- `PyMySQL` 是純 Python 實現，無需編譯，完全兼容 Django 的 MySQL 後端

**配置步驟：**

a. 創建 MySQL 數據庫：
```sql
CREATE DATABASE zongce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

b. 複製環境變量模板文件：
```bash
# Windows
copy .env.example .env

# Linux/Mac
cp .env.example .env
```

c. 編輯 `.env` 文件，填入您的數據庫配置：
```env
DB_NAME=zongce
DB_USER=root
DB_PASSWORD=your_password_here
DB_HOST=localhost
DB_PORT=3306
```

**重要**：請確保 `.env` 文件中的 `DB_PASSWORD` 設置為您的 MySQL root 用戶密碼。

4. 运行迁移

**重要**：請確保已激活虛擬環境並配置好 `.env` 文件後再執行遷移。

**步驟說明：**

a. **生成遷移文件**（首次運行時必須執行）：
```bash
python manage.py makemigrations
```
這會為所有應用（users、materials、system）生成遷移文件，保存在各自的 `migrations` 目錄中。

b. **執行遷移**（創建數據庫表）：
```bash
python manage.py migrate
```
這會根據遷移文件在數據庫中創建所有表。

**注意**：
- `migrations` 目錄已自動創建，但遷移文件需要通過 `makemigrations` 命令生成
- 首次運行時必須先執行 `makemigrations`，然後再執行 `migrate`
- 之後如果修改了模型，也需要重新運行 `makemigrations` 生成新的遷移文件

**故障排除：**

**問題 1：`Failed to open the referenced table 'user'` 錯誤**
1. 確保已創建 migrations 目錄（已自動創建）
2. 確保 `.env` 文件中的數據庫密碼正確
3. 確保 MySQL 服務正在運行
4. 嘗試刪除數據庫並重新創建：
   ```sql
   DROP DATABASE IF EXISTS zongce;
   CREATE DATABASE zongce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```
5. 重新運行 `python manage.py migrate`

**問題 2：`Table 'django_admin_log' already exists` 錯誤**

這表示數據庫中已存在部分表，但遷移記錄不一致。有兩種解決方案：

**方案 A：標記已存在的遷移為已應用（推薦，保留現有數據）**
```bash
# 使用 --fake-initial 標記初始遷移為已應用
python manage.py migrate --fake-initial

# 如果還有問題，可以手動標記特定遷移
python manage.py migrate --fake
```

**方案 B：重置數據庫（會丟失所有數據，僅用於開發環境）**
```sql
-- 在 MySQL 中執行
DROP DATABASE IF EXISTS zongce;
CREATE DATABASE zongce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```
然後重新運行：
```bash
python manage.py migrate
```

5. 创建超级用户
```bash
python manage.py createsuperuser
```

6. 运行开发服务器
```bash
python manage.py runserver
```

## 项目结构
```
backend/
├── apps/
│   ├── users/          # 用户管理
│   │   └── migrations/ # 数据库迁移文件
│   ├── materials/      # 材料管理
│   │   └── migrations/ # 数据库迁移文件
│   └── system/         # 系统管理
│       └── migrations/ # 数据库迁移文件
├── config/             # 项目配置
├── media/              # 媒体文件
├── .env                # 环境变量配置（需自行创建）
├── .env.example        # 环境变量模板
└── manage.py
```

## 常见问题

### 1. 数据库连接错误
- 检查 `.env` 文件是否存在且配置正确
- 检查 MySQL 服务是否运行
- 检查数据库用户权限

### 2. 迁移错误
- 确保所有 migrations 目录存在且包含 `__init__.py`
- 如果迁移失败，可以删除数据库重新创建（注意：会丢失所有数据）

