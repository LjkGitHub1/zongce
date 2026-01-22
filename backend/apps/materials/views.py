from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from django_filters.rest_framework import DjangoFilterBackend
from django.conf import settings
from django.db.models import Q, Count
from django.http import HttpResponse
import json
from .models import (
    ResearchProject, Monograph, Paper, OtherAcademic,
    TechnologyCompetition, SocialPractice, SocialService, OtherPractice, File
)
from .serializers import (
    ResearchProjectSerializer, MonographSerializer, PaperSerializer, OtherAcademicSerializer,
    TechnologyCompetitionSerializer, SocialPracticeSerializer, SocialServiceSerializer,
    OtherPracticeSerializer, FileSerializer
)
from .utils import save_file
from apps.system.models import AuditRecord, Message
from apps.users.models import User


class BaseMaterialViewSet(viewsets.ModelViewSet):
    """材料基类视图集"""
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'identity', 'id']  # 添加 id 支持
    search_fields = ['student_id', 'name']
    ordering_fields = ['created_at', 'updated_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        user = self.request.user
        queryset = self.queryset.all() if user.is_staff else self.queryset.filter(student_id=user.student_id)
        
        # 支持按班级筛选（管理员）
        if user.is_staff:
            class_name = self.request.query_params.get('class_name')
            if class_name:
                # 获取该班级的所有学号
                student_ids = User.objects.filter(class_name=class_name).values_list('student_id', flat=True)
                queryset = queryset.filter(student_id__in=student_ids)
        
        return queryset
    
    def perform_create(self, serializer):
        user = self.request.user
        material = serializer.save(
            student_id=user.student_id,
            name=user.name,
            identity=user.identity
        )
        # 处理文件上传
        files = self.request.FILES.getlist('files')
        for file in files:
            try:
                save_file(file, self.get_material_type(), material.id, user)
            except ValueError as e:
                pass  # 文件验证失败，跳过
    
    def get_material_type(self):
        """获取材料类型"""
        model_name = self.queryset.model.__name__.lower()
        type_map = {
            'researchproject': 'research_project',
            'monograph': 'monograph',
            'paper': 'paper',
            'otheracademic': 'other_academic',
            'technologycompetition': 'technology_competition',
            'socialpractice': 'social_practice',
            'socialservice': 'social_service',
            'otherpractice': 'other_practice',
        }
        return type_map.get(model_name, model_name)
    
    @action(detail=True, methods=['post'])
    def upload_files(self, request, pk=None):
        """上传文件"""
        material = self.get_object()
        files = request.FILES.getlist('files')
        
        # 检查是否有文件
        if not files:
            return Response({'error': '没有上传文件'}, status=status.HTTP_400_BAD_REQUEST)
        
        uploaded_files = []
        errors = []
        
        for file in files:
            try:
                file_obj = save_file(file, self.get_material_type(), material.id, request.user)
                uploaded_files.append(FileSerializer(file_obj).data)
            except ValueError as e:
                errors.append(f'{file.name}: {str(e)}')
        
        # 如果有错误，返回错误信息
        if errors:
            return Response({
                'error': '部分文件上传失败',
                'details': errors,
                'uploaded_files': uploaded_files
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # 如果没有成功上传的文件
        if not uploaded_files:
            return Response({'error': '文件上传失败'}, status=status.HTTP_400_BAD_REQUEST)
        
        return Response({'files': uploaded_files}, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['delete'])
    def delete_file(self, request, pk=None):
        """删除文件"""
        material = self.get_object()
        file_id = request.data.get('file_id')
        
        if not file_id:
            return Response({'error': 'file_id is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            file_obj = File.objects.get(id=file_id, material_type=self.get_material_type(), material_id=material.id)
            # 只有材料所有者或管理员可以删除
            if material.student_id != request.user.student_id and not request.user.is_staff:
                return Response({'error': '没有权限'}, status=status.HTTP_403_FORBIDDEN)
            file_obj.delete()
            return Response({'message': '文件删除成功'}, status=status.HTTP_200_OK)
        except File.DoesNotExist:
            return Response({'error': '文件不存在'}, status=status.HTTP_404_NOT_FOUND)
    
    @action(detail=True, methods=['get'])
    def files(self, request, pk=None):
        """获取材料文件列表"""
        material = self.get_object()
        files = File.objects.filter(
            material_type=self.get_material_type(),
            material_id=material.id
        ).order_by('-created_at')
        serializer = FileSerializer(files, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['post'])
    def withdraw(self, request, pk=None):
        """撤回材料"""
        material = self.get_object()
        if material.student_id != request.user.student_id:
            return Response({'error': '没有权限'}, status=status.HTTP_403_FORBIDDEN)
        
        if material.status not in ['pending', 'rejected']:
            return Response({'error': '只能撤回待审核或已驳回的材料'}, status=status.HTTP_400_BAD_REQUEST)
        
        material.status = 'withdrawn'
        material.save()
        return Response({'message': '材料已撤回'}, status=status.HTTP_200_OK)


class ResearchProjectViewSet(BaseMaterialViewSet):
    """课题项目视图集"""
    queryset = ResearchProject.objects.all()
    serializer_class = ResearchProjectSerializer
    filterset_fields = BaseMaterialViewSet.filterset_fields + ['level']


class MonographViewSet(BaseMaterialViewSet):
    """专著视图集"""
    queryset = Monograph.objects.all()
    serializer_class = MonographSerializer


class PaperViewSet(BaseMaterialViewSet):
    """论文视图集"""
    queryset = Paper.objects.all()
    serializer_class = PaperSerializer
    filterset_fields = BaseMaterialViewSet.filterset_fields + ['publication_date']


class OtherAcademicViewSet(BaseMaterialViewSet):
    """其他学术成果视图集"""
    queryset = OtherAcademic.objects.all()
    serializer_class = OtherAcademicSerializer


class TechnologyCompetitionViewSet(BaseMaterialViewSet):
    """科技竞赛视图集"""
    queryset = TechnologyCompetition.objects.all()
    serializer_class = TechnologyCompetitionSerializer
    filterset_fields = BaseMaterialViewSet.filterset_fields + ['level', 'is_whitelist', 'grade']


class SocialPracticeViewSet(BaseMaterialViewSet):
    """社会实践调研视图集"""
    queryset = SocialPractice.objects.all()
    serializer_class = SocialPracticeSerializer


class SocialServiceViewSet(BaseMaterialViewSet):
    """服务社会视图集"""
    queryset = SocialService.objects.all()
    serializer_class = SocialServiceSerializer


class OtherPracticeViewSet(BaseMaterialViewSet):
    """其他实践活动视图集"""
    queryset = OtherPractice.objects.all()
    serializer_class = OtherPracticeSerializer

