from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models


class UserManager(BaseUserManager):
    """自定义用户管理器"""
    
    def create_user(self, student_id, password=None, **extra_fields):
        if not student_id:
            raise ValueError('学号是必填项')
        user = self.model(student_id=student_id, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user
    
    def create_superuser(self, student_id, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('identity', 'teacher')
        
        if extra_fields.get('is_staff') is not True:
            raise ValueError('超级用户必须设置 is_staff=True')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('超级用户必须设置 is_superuser=True')
        
        return self.create_user(student_id, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """用户模型"""
    IDENTITY_CHOICES = [
        ('teacher', '老师'),
        ('graduate', '研究生'),
        ('undergraduate', '本科生'),
    ]
    
    student_id = models.CharField(max_length=50, unique=True, verbose_name='学号')
    name = models.CharField(max_length=100, verbose_name='姓名')
    identity = models.CharField(max_length=20, choices=IDENTITY_CHOICES, verbose_name='身份')
    major = models.CharField(max_length=100, blank=True, null=True, verbose_name='专业')
    class_name = models.CharField(max_length=50, blank=True, null=True, verbose_name='班级', db_column='class')
    email = models.EmailField(blank=True, null=True, verbose_name='邮箱')
    phone = models.CharField(max_length=20, blank=True, null=True, verbose_name='手机号')
    is_active = models.BooleanField(default=True, verbose_name='是否激活')
    is_staff = models.BooleanField(default=False, verbose_name='是否管理员')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='更新时间')
    
    objects = UserManager()
    
    USERNAME_FIELD = 'student_id'
    REQUIRED_FIELDS = ['name', 'identity']
    
    class Meta:
        db_table = 'user'
        verbose_name = '用户'
        verbose_name_plural = '用户'
        ordering = ['-created_at']
    
    def __str__(self):
        return f'{self.name}({self.student_id})'

