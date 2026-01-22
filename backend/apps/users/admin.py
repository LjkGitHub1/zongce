from django.contrib import admin
from .models import User


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ['student_id', 'name', 'identity', 'major', 'class_name', 'is_staff', 'is_active', 'created_at']
    list_filter = ['identity', 'is_staff', 'is_active']
    search_fields = ['student_id', 'name', 'major', 'class_name']
    readonly_fields = ['created_at', 'updated_at']

