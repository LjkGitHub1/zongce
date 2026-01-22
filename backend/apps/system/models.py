from django.db import models
from django.conf import settings


class AuditRecord(models.Model):
    """审核记录"""
    RESULT_CHOICES = [
        ('approved', '通过'),
        ('rejected', '驳回'),
    ]
    
    material_type = models.CharField(max_length=50, db_index=True, verbose_name='材料类型')
    material_id = models.BigIntegerField(db_index=True, verbose_name='材料ID')
    auditor = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='audit_records', verbose_name='审核人')
    auditor_name = models.CharField(max_length=100, verbose_name='审核人姓名')
    result = models.CharField(max_length=20, choices=RESULT_CHOICES, db_index=True, verbose_name='审核结果')
    comment = models.TextField(blank=True, null=True, verbose_name='审核意见')
    created_at = models.DateTimeField(auto_now_add=True, db_index=True, verbose_name='审核时间')
    
    class Meta:
        db_table = 'audit_record'
        verbose_name = '审核记录'
        verbose_name_plural = '审核记录'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['material_type', 'material_id']),
        ]


class Announcement(models.Model):
    """公告"""
    CATEGORY_CHOICES = [
        ('system', '系统通知'),
        ('audit', '审核通知'),
        ('important', '重要通知'),
    ]
    
    title = models.CharField(max_length=200, verbose_name='公告标题')
    content = models.TextField(verbose_name='公告内容')
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES, blank=True, null=True, db_index=True, verbose_name='公告分类')
    is_top = models.BooleanField(default=False, db_index=True, verbose_name='是否置顶')
    is_active = models.BooleanField(default=True, db_index=True, verbose_name='是否有效')
    start_time = models.DateTimeField(blank=True, null=True, verbose_name='生效时间')
    end_time = models.DateTimeField(blank=True, null=True, verbose_name='失效时间')
    publisher = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='published_announcements', verbose_name='发布人')
    publisher_name = models.CharField(max_length=100, verbose_name='发布人姓名')
    view_count = models.IntegerField(default=0, verbose_name='查看次数')
    created_at = models.DateTimeField(auto_now_add=True, db_index=True, verbose_name='创建时间')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='更新时间')
    
    class Meta:
        db_table = 'announcement'
        verbose_name = '公告'
        verbose_name_plural = '公告'
        ordering = ['-is_top', '-created_at']


class Message(models.Model):
    """消息"""
    MESSAGE_TYPE_CHOICES = [
        ('audit_result', '审核结果'),
        ('system', '系统消息'),
    ]
    
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='messages', db_index=True, verbose_name='接收用户')
    title = models.CharField(max_length=200, verbose_name='消息标题')
    content = models.TextField(verbose_name='消息内容')
    message_type = models.CharField(max_length=50, choices=MESSAGE_TYPE_CHOICES, db_index=True, verbose_name='消息类型')
    is_read = models.BooleanField(default=False, db_index=True, verbose_name='是否已读')
    related_type = models.CharField(max_length=50, blank=True, null=True, verbose_name='关联类型')
    related_id = models.BigIntegerField(blank=True, null=True, verbose_name='关联ID')
    created_at = models.DateTimeField(auto_now_add=True, db_index=True, verbose_name='创建时间')
    
    class Meta:
        db_table = 'message'
        verbose_name = '消息'
        verbose_name_plural = '消息'
        ordering = ['-created_at']


class OperationLog(models.Model):
    """操作日志"""
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, db_index=True, verbose_name='操作用户')
    user_name = models.CharField(max_length=100, blank=True, null=True, verbose_name='操作用户姓名')
    operation = models.CharField(max_length=100, db_index=True, verbose_name='操作类型')
    module = models.CharField(max_length=50, db_index=True, verbose_name='操作模块')
    content = models.TextField(blank=True, null=True, verbose_name='操作内容')
    ip_address = models.CharField(max_length=50, blank=True, null=True, verbose_name='IP地址')
    user_agent = models.CharField(max_length=500, blank=True, null=True, verbose_name='用户代理')
    created_at = models.DateTimeField(auto_now_add=True, db_index=True, verbose_name='操作时间')
    
    class Meta:
        db_table = 'operation_log'
        verbose_name = '操作日志'
        verbose_name_plural = '操作日志'
        ordering = ['-created_at']


class PermissionConfig(models.Model):
    """权限配置"""
    IDENTITY_CHOICES = [
        ('graduate', '研究生'),
        ('undergraduate', '本科生'),
    ]
    
    MODULE_CHOICES = [
        ('dashboard', '首页'),
        ('materials', '我的材料'),
        ('academic', '学术成果'),
        ('practice', '服务与实践'),
        ('statistics', '数据统计'),
    ]
    
    MATERIAL_TYPE_CHOICES = [
        ('research_project', '课题项目'),
        ('monograph', '专著'),
        ('paper', '论文'),
        ('other_academic', '其他学术成果'),
        ('technology_competition', '科技竞赛'),
        ('social_practice', '社会实践调研'),
        ('social_service', '服务社会'),
        ('other_practice', '其他实践活动'),
    ]
    
    identity = models.CharField(max_length=20, choices=IDENTITY_CHOICES, db_index=True, verbose_name='身份')
    module = models.CharField(max_length=50, choices=MODULE_CHOICES, db_index=True, verbose_name='模块名称')
    material_type = models.CharField(max_length=50, choices=MATERIAL_TYPE_CHOICES, blank=True, null=True, db_index=True, verbose_name='材料类型')
    is_enabled = models.BooleanField(default=True, verbose_name='是否启用')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='更新时间')
    
    class Meta:
        db_table = 'permission_config'
        verbose_name = '权限配置'
        verbose_name_plural = '权限配置'
        unique_together = [['identity', 'module', 'material_type']]
        indexes = [
            models.Index(fields=['identity', 'module', 'material_type']),
        ]

