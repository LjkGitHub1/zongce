from django.contrib import admin
from .models import AuditRecord, Announcement, Message, OperationLog, PermissionConfig


@admin.register(AuditRecord)
class AuditRecordAdmin(admin.ModelAdmin):
    list_display = ['material_type', 'material_id', 'auditor_name', 'result', 'created_at']
    list_filter = ['result', 'material_type']
    search_fields = ['auditor_name']


@admin.register(Announcement)
class AnnouncementAdmin(admin.ModelAdmin):
    list_display = ['title', 'category', 'is_top', 'is_active', 'publisher_name', 'created_at']
    list_filter = ['category', 'is_top', 'is_active']
    search_fields = ['title', 'content']


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ['title', 'user', 'message_type', 'is_read', 'created_at']
    list_filter = ['message_type', 'is_read']
    search_fields = ['title', 'content']


@admin.register(OperationLog)
class OperationLogAdmin(admin.ModelAdmin):
    list_display = ['user_name', 'operation', 'module', 'ip_address', 'created_at']
    list_filter = ['operation', 'module']
    search_fields = ['user_name', 'content']


@admin.register(PermissionConfig)
class PermissionConfigAdmin(admin.ModelAdmin):
    list_display = ['identity', 'module', 'is_enabled', 'updated_at']
    list_filter = ['identity', 'is_enabled']
    search_fields = ['module']

