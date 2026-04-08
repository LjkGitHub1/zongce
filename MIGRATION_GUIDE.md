# 數據庫遷移指南

由於我們修改了模型結構，需要創建並運行數據庫遷移來更新數據庫表結構。

## 步驟

### 1. 激活虛擬環境（如果使用）

```bash
# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate
```

### 2. 創建遷移文件

```bash
cd backend
python manage.py makemigrations materials
```

### 3. 檢查遷移文件

遷移文件會創建在 `backend/apps/materials/migrations/` 目錄下。請檢查新創建的遷移文件，確保它包含以下字段變更：

**課題項目 (ResearchProject):**
- 刪除 `personnel` 字段
- 添加 `host` 字段（主持人）
- 添加 `participants` 字段（參與人）
- 添加 `supervisor` 字段（指導教師）
- 添加 `contact_phone` 字段（負責人聯繫電話）

**科技競賽 (TechnologyCompetition):**
- 刪除 `author` 字段
- 添加 `leader` 字段（負責人）
- 添加 `members` 字段（隊員）
- 添加 `certificate_number` 字段（獎狀編號）
- 添加 `contact_phone` 字段（負責人聯繫電話）

**社會實踐調研 (SocialPractice):**
- 刪除 `author` 字段
- 添加 `host` 字段（主持人）
- 添加 `participants` 字段（參與人）
- 添加 `content` 字段（具體內容）
- 添加 `contact_phone` 字段（負責人聯繫電話）

**服務社會 (SocialService):**
- 添加 `content` 字段（具體內容）
- 添加 `contact_phone` 字段（負責人聯繫電話）

**其他社會實踐 (OtherPractice):**
- 添加 `content` 字段（具體內容）
- 添加 `contact_phone` 字段（負責人聯繫電話）

### 4. 運行遷移

```bash
python manage.py migrate materials
```

### 5. 數據遷移（可選）

如果您有現有數據，可能需要手動遷移數據：

**課題項目：**
- 將 `personnel` 字段的數據遷移到 `host` 和 `participants`（需要根據實際情況手動處理）

**科技競賽：**
- 將 `author` 字段的數據遷移到 `leader` 和 `members`（需要根據實際情況手動處理）

**社會實踐調研：**
- 將 `author` 字段的數據遷移到 `host` 和 `participants`（需要根據實際情況手動處理）

### 6. 重啟服務器

遷移完成後，重啟 Django 開發服務器：

```bash
python manage.py runserver
```

## 注意事項

1. **備份數據庫**：在運行遷移之前，請務必備份您的數據庫。

2. **測試環境**：建議先在測試環境中運行遷移，確認無誤後再在生產環境執行。

3. **數據遷移**：舊字段（`personnel`、`author`）的數據不會自動遷移到新字段，需要手動處理或編寫數據遷移腳本。

4. **回滾**：如果需要回滾遷移，可以使用：
   ```bash
   python manage.py migrate materials <previous_migration_number>
   ```

## 常見問題

### Q: 遷移失敗怎麼辦？
A: 檢查遷移文件是否有語法錯誤，確保數據庫連接正常，檢查是否有外鍵約束衝突。

### Q: 如何查看遷移狀態？
A: 使用 `python manage.py showmigrations materials` 查看遷移狀態。

### Q: 如何撤銷遷移？
A: 使用 `python manage.py migrate materials <migration_number>` 回滾到指定遷移版本。

