import os
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from django.conf import settings
from .models import File

ALLOWED_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.pdf', '.doc', '.docx']
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB


def validate_file(file):
    """验证文件"""
    # 检查文件大小
    if file.size > MAX_FILE_SIZE:
        raise ValueError(f'文件大小不能超过{MAX_FILE_SIZE / 1024 / 1024}MB')
    
    # 检查文件扩展名
    ext = os.path.splitext(file.name)[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise ValueError(f'不支持的文件类型，支持的类型：{", ".join(ALLOWED_EXTENSIONS)}')
    
    return True


def save_file(uploaded_file, material_type, material_id, user):
    """保存文件"""
    validate_file(uploaded_file)
    
    # 生成文件路径
    ext = os.path.splitext(uploaded_file.name)[1].lower()
    file_name = f"{material_type}/{material_id}/{uploaded_file.name}"
    file_path = default_storage.save(file_name, ContentFile(uploaded_file.read()))
    
    # 创建文件记录
    file_obj = File.objects.create(
        file_name=os.path.basename(file_path),
        original_name=uploaded_file.name,
        file_path=file_path,
        file_size=uploaded_file.size,
        file_type=uploaded_file.content_type,
        file_ext=ext,
        material_type=material_type,
        material_id=material_id,
        upload_user=user
    )
    
    return file_obj

