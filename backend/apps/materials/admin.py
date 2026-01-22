from django.contrib import admin
from .models import (
    ResearchProject, Monograph, Paper, OtherAcademic,
    TechnologyCompetition, SocialPractice, SocialService, OtherPractice, File
)


@admin.register(ResearchProject)
class ResearchProjectAdmin(admin.ModelAdmin):
    list_display = ['project_name', 'student_id', 'name', 'level', 'status', 'created_at']
    list_filter = ['status', 'level', 'identity']
    search_fields = ['project_name', 'student_id', 'name']


@admin.register(Monograph)
class MonographAdmin(admin.ModelAdmin):
    list_display = ['title', 'student_id', 'name', 'publish', 'status', 'created_at']
    list_filter = ['status', 'identity']
    search_fields = ['title', 'student_id', 'name']


@admin.register(Paper)
class PaperAdmin(admin.ModelAdmin):
    list_display = ['title', 'student_id', 'name', 'publication', 'status', 'created_at']
    list_filter = ['status', 'identity']
    search_fields = ['title', 'student_id', 'name', 'publication']


@admin.register(OtherAcademic)
class OtherAcademicAdmin(admin.ModelAdmin):
    list_display = ['id', 'student_id', 'name', 'status', 'created_at']
    list_filter = ['status', 'identity']


@admin.register(TechnologyCompetition)
class TechnologyCompetitionAdmin(admin.ModelAdmin):
    list_display = ['competition', 'student_id', 'name', 'level', 'status', 'created_at']
    list_filter = ['status', 'level', 'is_whitelist', 'identity']
    search_fields = ['competition', 'student_id', 'name']


@admin.register(SocialPractice)
class SocialPracticeAdmin(admin.ModelAdmin):
    list_display = ['title', 'student_id', 'name', 'status', 'created_at']
    list_filter = ['status', 'identity']


@admin.register(SocialService)
class SocialServiceAdmin(admin.ModelAdmin):
    list_display = ['title', 'student_id', 'name', 'status', 'created_at']
    list_filter = ['status', 'identity']


@admin.register(OtherPractice)
class OtherPracticeAdmin(admin.ModelAdmin):
    list_display = ['title', 'student_id', 'name', 'status', 'created_at']
    list_filter = ['status', 'identity']


@admin.register(File)
class FileAdmin(admin.ModelAdmin):
    list_display = ['original_name', 'material_type', 'material_id', 'file_size', 'upload_user', 'created_at']
    list_filter = ['material_type', 'file_type']
    search_fields = ['original_name', 'file_name']

