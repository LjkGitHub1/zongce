from rest_framework import serializers
from .models import AuditRecord, Announcement, Message, PermissionConfig, OperationLog
from apps.users.serializers import UserSerializer


class AuditRecordSerializer(serializers.ModelSerializer):
    """审核记录序列化器"""
    auditor_info = UserSerializer(source='auditor', read_only=True)
    
    class Meta:
        model = AuditRecord
        fields = ['id', 'material_type', 'material_id', 'auditor', 'auditor_name', 
                  'auditor_info', 'result', 'comment', 'created_at']
        read_only_fields = ['id', 'created_at']


class AnnouncementSerializer(serializers.ModelSerializer):
    """公告序列化器"""
    publisher_info = UserSerializer(source='publisher', read_only=True)
    
    class Meta:
        model = Announcement
        fields = ['id', 'title', 'content', 'category', 'is_top', 'is_active',
                  'start_time', 'end_time', 'publisher', 'publisher_name', 'publisher_info',
                  'view_count', 'created_at', 'updated_at']
        read_only_fields = ['id', 'publisher', 'publisher_name', 'view_count', 'created_at', 'updated_at']


class MessageSerializer(serializers.ModelSerializer):
    """消息序列化器"""
    
    class Meta:
        model = Message
        fields = ['id', 'user', 'title', 'content', 'message_type', 'is_read',
                  'related_type', 'related_id', 'created_at']
        read_only_fields = ['id', 'created_at']


class PermissionConfigSerializer(serializers.ModelSerializer):
    """权限配置序列化器"""
    
    class Meta:
        model = PermissionConfig
        fields = ['id', 'identity', 'module', 'material_type', 'is_enabled', 'created_at', 'updated_at']
        read_only_fields = ['id', 'identity', 'module', 'material_type', 'created_at', 'updated_at']


class OperationLogSerializer(serializers.ModelSerializer):
    """操作日志序列化器"""
    
    class Meta:
        model = OperationLog
        fields = ['id', 'user_name', 'operation', 'module', 'content', 'ip_address', 'user_agent', 'created_at']
        read_only_fields = ['id', 'created_at']

