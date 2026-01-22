from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from .models import User


class UserSerializer(serializers.ModelSerializer):
    """用户序列化器"""
    
    class Meta:
        model = User
        fields = ['id', 'student_id', 'name', 'identity', 'major', 'class_name', 'email', 'phone', 'is_active', 'is_staff', 'created_at']
        read_only_fields = ['id', 'is_staff', 'created_at']


class UserRegisterSerializer(serializers.ModelSerializer):
    """用户注册序列化器"""
    password = serializers.CharField(write_only=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = ['student_id', 'name', 'identity', 'major', 'class_name', 'email', 'phone', 'password', 'password_confirm']
    
    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({'password_confirm': '两次密码输入不一致'})
        return attrs
    
    def create(self, validated_data):
        validated_data.pop('password_confirm')
        password = validated_data.pop('password')
        user = User.objects.create_user(password=password, **validated_data)
        return user


class UserProfileSerializer(serializers.ModelSerializer):
    """用户个人信息序列化器"""
    
    class Meta:
        model = User
        fields = ['id', 'student_id', 'name', 'identity', 'major', 'class_name', 'email', 'phone', 'created_at']
        read_only_fields = ['id', 'student_id', 'identity', 'created_at']


class UserAdminSerializer(serializers.ModelSerializer):
    """管理员用户序列化器"""
    password = serializers.CharField(write_only=True, required=False)
    
    class Meta:
        model = User
        fields = ['id', 'student_id', 'name', 'identity', 'major', 'class_name', 'email', 'phone', 'is_active', 'is_staff', 'password', 'created_at']
        read_only_fields = ['id', 'created_at']
    
    def create(self, validated_data):
        password = validated_data.pop('password', 'Aa@2026')
        user = User.objects.create_user(password=password, **validated_data)
        return user
    
    def update(self, instance, validated_data):
        # 更新时不处理密码
        validated_data.pop('password', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance
