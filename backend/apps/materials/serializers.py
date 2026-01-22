from rest_framework import serializers
from .models import (
    ResearchProject, Monograph, Paper, OtherAcademic,
    TechnologyCompetition, SocialPractice, SocialService, OtherPractice, File
)


class FileSerializer(serializers.ModelSerializer):
    """文件序列化器"""
    file_url = serializers.SerializerMethodField()
    
    class Meta:
        model = File
        fields = ['id', 'file_name', 'original_name', 'file_path', 'file_url', 'file_size', 'file_type', 'file_ext', 'created_at']
        read_only_fields = ['id', 'created_at']
    
    def get_file_url(self, obj):
        """获取文件的完整URL"""
        from django.conf import settings
        if obj.file_path.startswith('http://') or obj.file_path.startswith('https://'):
            return obj.file_path
        # 构建完整的媒体文件URL
        if obj.file_path.startswith('/'):
            return f"{settings.MEDIA_URL.rstrip('/')}{obj.file_path}"
        else:
            return f"{settings.MEDIA_URL.rstrip('/')}/{obj.file_path}"


class BaseMaterialSerializer(serializers.ModelSerializer):
    """材料基类序列化器"""
    files = FileSerializer(many=True, read_only=True)
    student_id = serializers.CharField(required=False, allow_blank=True)
    name = serializers.CharField(required=False, allow_blank=True)
    identity = serializers.CharField(required=False, allow_blank=True)
    class_name = serializers.SerializerMethodField()
    
    class Meta:
        fields = ['id', 'student_id', 'name', 'identity', 'class_name', 'status', 'files', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_class_name(self, obj):
        """获取用户的班级"""
        try:
            from apps.users.models import User
            user = User.objects.filter(student_id=obj.student_id).first()
            return user.class_name if user else None
        except:
            return None


class ResearchProjectSerializer(BaseMaterialSerializer):
    """课题项目序列化器"""
    
    class Meta(BaseMaterialSerializer.Meta):
        model = ResearchProject
        fields = BaseMaterialSerializer.Meta.fields + [
            'project_name', 'level', 'start_date', 'end_date', 'funds',
            'number', 'personnel', 'remark'
        ]


class MonographSerializer(BaseMaterialSerializer):
    """专著序列化器"""
    
    class Meta(BaseMaterialSerializer.Meta):
        model = Monograph
        fields = BaseMaterialSerializer.Meta.fields + [
            'title', 'publish', 'publish_date', 'number', 'supervisor',
            'word_count', 'author', 'remark'
        ]


class PaperSerializer(BaseMaterialSerializer):
    """论文序列化器"""
    
    class Meta(BaseMaterialSerializer.Meta):
        model = Paper
        fields = BaseMaterialSerializer.Meta.fields + [
            'title', 'publication', 'category', 'publication_number',
            'publication_date', 'journal_status', 'partition', 'supervisor',
            'first_unit', 'communication', 'author', 'remark'
        ]


class OtherAcademicSerializer(BaseMaterialSerializer):
    """其他学术成果序列化器"""
    
    class Meta(BaseMaterialSerializer.Meta):
        model = OtherAcademic
        fields = BaseMaterialSerializer.Meta.fields + ['content']


class TechnologyCompetitionSerializer(BaseMaterialSerializer):
    """科技竞赛序列化器"""
    
    class Meta(BaseMaterialSerializer.Meta):
        model = TechnologyCompetition
        fields = BaseMaterialSerializer.Meta.fields + [
            'competition', 'is_whitelist', 'title', 'level', 'award_date',
            'grade', 'organization', 'group', 'author', 'supervisor', 'remark'
        ]


class SocialPracticeSerializer(BaseMaterialSerializer):
    """社会实践调研序列化器"""
    
    class Meta(BaseMaterialSerializer.Meta):
        model = SocialPractice
        fields = BaseMaterialSerializer.Meta.fields + [
            'title', 'level', 'date', 'author', 'remark'
        ]


class SocialServiceSerializer(BaseMaterialSerializer):
    """服务社会序列化器"""
    
    class Meta(BaseMaterialSerializer.Meta):
        model = SocialService
        fields = BaseMaterialSerializer.Meta.fields + [
            'title', 'level', 'date', 'author', 'remark'
        ]


class OtherPracticeSerializer(BaseMaterialSerializer):
    """其他实践活动序列化器"""
    
    class Meta(BaseMaterialSerializer.Meta):
        model = OtherPractice
        fields = BaseMaterialSerializer.Meta.fields + [
            'title', 'level', 'date', 'organization', 'author', 'remark'
        ]

