from rest_framework import viewsets, status, generics, filters
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Q, Count, F
from django.utils import timezone
from .models import AuditRecord, Announcement, Message, PermissionConfig, OperationLog
from .serializers import (
    AuditRecordSerializer, AnnouncementSerializer, 
    MessageSerializer, PermissionConfigSerializer, OperationLogSerializer
)
from apps.materials.models import (
    ResearchProject, Monograph, Paper, OtherAcademic,
    TechnologyCompetition, SocialPractice, SocialService, OtherPractice
)
from apps.users.models import User


class AuditRecordViewSet(viewsets.ModelViewSet):
    """审核记录视图集"""
    queryset = AuditRecord.objects.all()
    serializer_class = AuditRecordSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['material_type', 'material_id', 'result', 'auditor']
    
    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return AuditRecord.objects.all()
        # 普通用户只能查看自己材料的审核记录
        return AuditRecord.objects.filter(
            material_type__in=self._get_user_material_types(user),
            material_id__in=self._get_user_material_ids(user)
        )
    
    def _get_user_material_types(self, user):
        """获取用户材料类型"""
        return [
            'research_project', 'monograph', 'paper', 'other_academic',
            'technology_competition', 'social_practice', 'social_service', 'other_practice'
        ]
    
    def _get_user_material_ids(self, user):
        """获取用户材料ID列表"""
        ids = []
        for model in [ResearchProject, Monograph, Paper, OtherAcademic,
                     TechnologyCompetition, SocialPractice, SocialService, OtherPractice]:
            ids.extend(model.objects.filter(student_id=user.student_id).values_list('id', flat=True))
        return ids


@api_view(['POST'])
@permission_classes([IsAdminUser])
def audit_material(request):
    """审核材料"""
    material_type = request.data.get('material_type')
    material_id = request.data.get('material_id')
    result = request.data.get('result')  # 'approved' or 'rejected'
    comment = request.data.get('comment', '')
    
    if not all([material_type, material_id, result]):
        return Response({'error': '缺少必要参数'}, status=status.HTTP_400_BAD_REQUEST)
    
    if result not in ['approved', 'rejected']:
        return Response({'error': '无效的审核结果'}, status=status.HTTP_400_BAD_REQUEST)
    
    # 获取材料模型
    model_map = {
        'research_project': ResearchProject,
        'monograph': Monograph,
        'paper': Paper,
        'other_academic': OtherAcademic,
        'technology_competition': TechnologyCompetition,
        'social_practice': SocialPractice,
        'social_service': SocialService,
        'other_practice': OtherPractice,
    }
    
    model = model_map.get(material_type)
    if not model:
        return Response({'error': '无效的材料类型'}, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        material = model.objects.get(id=material_id)
    except model.DoesNotExist:
        return Response({'error': '材料不存在'}, status=status.HTTP_404_NOT_FOUND)
    
    # 更新材料状态
    if result == 'approved':
        material.status = 'approved'
    else:
        material.status = 'rejected'
        if not comment:
            return Response({'error': '驳回时必须填写审核意见'}, status=status.HTTP_400_BAD_REQUEST)
    
    material.save()
    
    # 创建审核记录
    audit_record = AuditRecord.objects.create(
        material_type=material_type,
        material_id=material_id,
        auditor=request.user,
        auditor_name=request.user.name,
        result=result,
        comment=comment
    )
    
    # 发送消息通知
    try:
        from apps.users.models import User
        material_user = User.objects.get(student_id=material.student_id)
        Message.objects.create(
            user=material_user,
            title=f'材料审核{("通过" if result == "approved" else "驳回")}',
            content=f'您的材料已{("通过" if result == "approved" else "驳回")}审核。' + (f'审核意见：{comment}' if comment else ''),
            message_type='audit_result',
            related_type=material_type,
            related_id=material_id
        )
    except Exception as e:
        print(f'发送消息失败: {e}')
    
    # 记录操作日志
    try:
        material_type_names = {
            'research_project': '课题项目',
            'monograph': '专著',
            'paper': '论文',
            'other_academic': '其他学术成果',
            'technology_competition': '科技竞赛',
            'social_practice': '社会实践调研',
            'social_service': '服务社会',
            'other_practice': '其他实践活动'
        }
        material_type_name = material_type_names.get(material_type, material_type)
        
        # 获取材料标题
        material_title = ''
        if hasattr(material, 'title'):
            material_title = material.title
        elif hasattr(material, 'project_name'):
            material_title = material.project_name
        elif hasattr(material, 'monograph_name'):
            material_title = material.monograph_name
        elif hasattr(material, 'paper_title'):
            material_title = material.paper_title
        elif hasattr(material, 'achievement_name'):
            material_title = material.achievement_name
        
        content = f'{material_type_name}'
        if material_title:
            content += f' | 标题: {material_title}'
        content += f' | 审核结果: {"通过" if result == "approved" else "驳回"}'
        if comment:
            content += f' | 审核意见: {comment[:100]}'
        
        ip_address = request.META.get('HTTP_X_FORWARDED_FOR', '').split(',')[0] if request.META.get('HTTP_X_FORWARDED_FOR') else request.META.get('REMOTE_ADDR', '')
        user_agent = request.META.get('HTTP_USER_AGENT', '')[:500]
        
        OperationLog.objects.create(
            user=request.user,
            user_name=request.user.name if hasattr(request.user, 'name') else request.user.student_id,
            operation='审核',
            module='审核管理',
            content=content[:500],
            ip_address=ip_address,
            user_agent=user_agent
        )
    except Exception as e:
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f'记录审核日志失败: {str(e)}')
    
    return Response({
        'message': '审核成功',
        'audit_record': AuditRecordSerializer(audit_record).data
    }, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAdminUser])
def audit_statistics(request):
    """审核统计"""
    pending_count = sum([
        ResearchProject.objects.filter(status='pending').count(),
        Monograph.objects.filter(status='pending').count(),
        Paper.objects.filter(status='pending').count(),
        OtherAcademic.objects.filter(status='pending').count(),
        TechnologyCompetition.objects.filter(status='pending').count(),
        SocialPractice.objects.filter(status='pending').count(),
        SocialService.objects.filter(status='pending').count(),
        OtherPractice.objects.filter(status='pending').count(),
    ])
    
    approved_count = AuditRecord.objects.filter(result='approved').count()
    rejected_count = AuditRecord.objects.filter(result='rejected').count()
    total_count = approved_count + rejected_count
    approval_rate = (approved_count / total_count * 100) if total_count > 0 else 0
    
    return Response({
        'pending_count': pending_count,
        'approved_count': approved_count,
        'rejected_count': rejected_count,
        'approval_rate': round(approval_rate, 2)
    })


@api_view(['GET'])
@permission_classes([IsAdminUser])
def get_class_list(request):
    """获取班级列表"""
    classes = User.objects.filter(
        class_name__isnull=False
    ).exclude(
        class_name=''
    ).values_list('class_name', flat=True).distinct().order_by('class_name')
    
    return Response({'classes': list(classes)})


@api_view(['GET'])
@permission_classes([IsAdminUser])
def get_class_statistics(request):
    """获取班级提交统计"""
    class_name = request.query_params.get('class_name')
    material_type = request.query_params.get('type', '')  # 可选，指定材料类型
    
    if not class_name:
        return Response({'error': 'class_name is required'}, status=status.HTTP_400_BAD_REQUEST)
    
    # 获取该班级的所有学生
    students = User.objects.filter(class_name=class_name, is_staff=False)
    total_students = students.count()
    
    if total_students == 0:
        return Response({
            'class_name': class_name,
            'total_students': 0,
            'submitted_students': 0,
            'submitted_count': 0,
            'ratio': '0/0'
        })
    
    student_ids = list(students.values_list('student_id', flat=True))
    
    # 获取所有材料模型
    models = [
        ('research_project', ResearchProject),
        ('monograph', Monograph),
        ('paper', Paper),
        ('other_academic', OtherAcademic),
        ('technology_competition', TechnologyCompetition),
        ('social_practice', SocialPractice),
        ('social_service', SocialService),
        ('other_practice', OtherPractice),
    ]
    
    # 如果指定了材料类型，只统计该类型
    if material_type:
        type_map = {
            'research_project': ResearchProject,
            'monograph': Monograph,
            'paper': Paper,
            'other_academic': OtherAcademic,
            'technology_competition': TechnologyCompetition,
            'social_practice': SocialPractice,
            'social_service': SocialService,
            'other_practice': OtherPractice,
        }
        models = [(material_type, type_map.get(material_type))] if type_map.get(material_type) else models
    
    # 统计提交人数和提交份数
    submitted_student_ids = set()
    submitted_count = 0
    
    for type_name, model in models:
        if model:
            materials = model.objects.filter(student_id__in=student_ids)
            submitted_student_ids.update(materials.values_list('student_id', flat=True))
            submitted_count += materials.count()
    
    submitted_students = len(submitted_student_ids)
    
    return Response({
        'class_name': class_name,
        'total_students': total_students,
        'submitted_students': submitted_students,
        'submitted_count': submitted_count,
        'ratio': f'{submitted_students}/{total_students}'
    })


@api_view(['GET'])
@permission_classes([IsAdminUser])
def get_all_class_statistics(request):
    """获取所有班级的提交统计"""
    # 获取所有班级列表
    classes = User.objects.filter(
        class_name__isnull=False
    ).exclude(
        class_name=''
    ).values_list('class_name', flat=True).distinct().order_by('class_name')
    
    # 获取所有材料模型
    models = [
        ResearchProject,
        Monograph,
        Paper,
        OtherAcademic,
        TechnologyCompetition,
        SocialPractice,
        SocialService,
        OtherPractice,
    ]
    
    result = []
    
    for class_name in classes:
        # 获取该班级的所有学生
        students = User.objects.filter(class_name=class_name, is_staff=False)
        total_students = students.count()
        
        if total_students == 0:
            result.append({
                'class_name': class_name,
                'total_students': 0,
                'submitted_students': 0,
                'ratio': '0/0'
            })
            continue
        
        student_ids = list(students.values_list('student_id', flat=True))
        
        # 统计提交人数
        submitted_student_ids = set()
        
        for model in models:
            materials = model.objects.filter(student_id__in=student_ids)
            submitted_student_ids.update(materials.values_list('student_id', flat=True))
        
        submitted_students = len(submitted_student_ids)
        
        result.append({
            'class_name': class_name,
            'total_students': total_students,
            'submitted_students': submitted_students,
            'ratio': f'{submitted_students}/{total_students}'
        })
    
    return Response(result)


@api_view(['GET'])
@permission_classes([IsAdminUser])
def get_unsubmitted_students(request):
    """获取某个班级的未提交人员列表"""
    class_name = request.query_params.get('class_name')
    
    if not class_name:
        return Response({'error': 'class_name is required'}, status=status.HTTP_400_BAD_REQUEST)
    
    # 获取该班级的所有学生
    students = User.objects.filter(class_name=class_name, is_staff=False)
    total_students = students.count()
    
    if total_students == 0:
        return Response({
            'class_name': class_name,
            'unsubmitted_students': []
        })
    
    student_ids = list(students.values_list('student_id', flat=True))
    
    # 获取所有材料模型
    models = [
        ResearchProject,
        Monograph,
        Paper,
        OtherAcademic,
        TechnologyCompetition,
        SocialPractice,
        SocialService,
        OtherPractice,
    ]
    
    # 统计已提交的学生ID
    submitted_student_ids = set()
    
    for model in models:
        materials = model.objects.filter(student_id__in=student_ids)
        submitted_student_ids.update(materials.values_list('student_id', flat=True))
    
    # 获取未提交的学生
    unsubmitted_student_ids = set(student_ids) - submitted_student_ids
    unsubmitted_students = User.objects.filter(
        student_id__in=unsubmitted_student_ids
    ).values('student_id', 'name', 'class_name').order_by('student_id')
    
    return Response({
        'class_name': class_name,
        'unsubmitted_students': list(unsubmitted_students)
    })


class AnnouncementViewSet(viewsets.ModelViewSet):
    """公告视图集"""
    queryset = Announcement.objects.filter(is_active=True)
    serializer_class = AnnouncementSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['category', 'is_top']
    
    def get_queryset(self):
        now = timezone.now()
        return Announcement.objects.filter(
            Q(is_active=True) &
            (Q(start_time__isnull=True) | Q(start_time__lte=now)) &
            (Q(end_time__isnull=True) | Q(end_time__gte=now))
        ).order_by('-is_top', '-created_at')
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAdminUser()]
        return [IsAuthenticated()]
    
    def perform_create(self, serializer):
        serializer.save(
            publisher=self.request.user,
            publisher_name=self.request.user.name
        )
    
    @action(detail=True, methods=['post'])
    def view(self, request, pk=None):
        """查看公告（增加查看次数）"""
        announcement = self.get_object()
        announcement.view_count = F('view_count') + 1
        announcement.save(update_fields=['view_count'])
        return Response({'message': '查看成功'})


class MessageViewSet(viewsets.ReadOnlyModelViewSet):
    """消息视图集"""
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['message_type', 'is_read']
    
    def get_queryset(self):
        return Message.objects.filter(user=self.request.user).order_by('-created_at')
    
    @action(detail=True, methods=['post'])
    def mark_read(self, request, pk=None):
        """标记为已读"""
        message = self.get_object()
        if message.user != request.user:
            return Response({'error': '没有权限'}, status=status.HTTP_403_FORBIDDEN)
        message.is_read = True
        message.save()
        return Response({'message': '已标记为已读'})
    
    @action(detail=False, methods=['post'])
    def mark_all_read(self, request):
        """标记全部为已读"""
        Message.objects.filter(user=request.user, is_read=False).update(is_read=True)
        return Response({'message': '全部标记为已读'})


class PermissionConfigViewSet(viewsets.ModelViewSet):
    """权限配置视图集"""
    queryset = PermissionConfig.objects.all()
    serializer_class = PermissionConfigSerializer
    permission_classes = [IsAdminUser]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['identity', 'module', 'material_type', 'is_enabled']


class OperationLogViewSet(viewsets.ReadOnlyModelViewSet):
    """操作日志视图集"""
    queryset = OperationLog.objects.all()
    serializer_class = OperationLogSerializer
    permission_classes = [IsAdminUser]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['user_name', 'operation', 'module', 'ip_address']
    search_fields = ['user_name', 'operation', 'module', 'content']
    ordering_fields = ['created_at']
    ordering = ['-created_at']


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_user_permissions(request):
    """获取当前用户的权限配置"""
    user = request.user
    
    # 管理员拥有所有权限
    if user.is_staff:
        return Response({
            'modules': {
                'dashboard': True,
                'materials': True,
                'academic': True,
                'practice': True,
                'statistics': True
            },
            'material_types': {
                'research_project': True,
                'monograph': True,
                'paper': True,
                'other_academic': True,
                'technology_competition': True,
                'social_practice': True,
                'social_service': True,
                'other_practice': True
            }
        })
    
    # 老师拥有所有权限
    if user.identity == 'teacher':
        return Response({
            'modules': {
                'dashboard': True,
                'materials': True,
                'academic': True,
                'practice': True,
                'statistics': True
            },
            'material_types': {
                'research_project': True,
                'monograph': True,
                'paper': True,
                'other_academic': True,
                'technology_competition': True,
                'social_practice': True,
                'social_service': True,
                'other_practice': True
            }
        })
    
    # 研究生和本科生根据权限配置
    identity = user.identity
    permissions = PermissionConfig.objects.filter(identity=identity, is_enabled=True)
    
    # 默认 dashboard 始终启用，其他模块和材料类型都禁用
    modules = {
        'dashboard': True,  # 首页始终可访问
        'materials': False,
        'academic': False,
        'practice': False,
        'statistics': False
    }
    
    material_types = {
        'research_project': False,
        'monograph': False,
        'paper': False,
        'other_academic': False,
        'technology_competition': False,
        'social_practice': False,
        'social_service': False,
        'other_practice': False
    }
    
    # 材料类型到模块的映射
    material_type_to_module = {
        'research_project': 'academic',
        'monograph': 'academic',
        'paper': 'academic',
        'other_academic': 'academic',
        'technology_competition': 'practice',
        'social_practice': 'practice',
        'social_service': 'practice',
        'other_practice': 'practice'
    }
    
    # 根据权限配置设置
    for perm in permissions:
        if perm.module:
            modules[perm.module] = True
        if perm.material_type:
            material_types[perm.material_type] = True
            # 如果配置了材料类型，自动启用对应的模块
            module = material_type_to_module.get(perm.material_type)
            if module:
                modules[module] = True
    
    return Response({
        'modules': modules,
        'material_types': material_types
    })


@api_view(['POST'])
@permission_classes([IsAdminUser])
def batch_update_permissions(request):
    """批量更新权限配置"""
    identity = request.data.get('identity')
    permissions = request.data.get('permissions', [])
    
    if not identity:
        return Response({'error': '缺少身份参数'}, status=status.HTTP_400_BAD_REQUEST)
    
    if identity not in ['graduate', 'undergraduate']:
        return Response({'error': '无效的身份参数'}, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        # 先禁用该身份的所有权限（除了 dashboard）
        PermissionConfig.objects.filter(identity=identity).exclude(module='dashboard').update(is_enabled=False)
        
        # 根据前端传来的权限列表，创建或更新权限配置并启用
        for perm_data in permissions:
            module = perm_data.get('module')
            material_type = perm_data.get('material_type')
            is_enabled = perm_data.get('is_enabled', True)
            
            if not module:
                continue
            
            # 创建或更新权限配置
            PermissionConfig.objects.update_or_create(
                identity=identity,
                module=module,
                material_type=material_type,
                defaults={'is_enabled': is_enabled}
            )
        
        # 确保 dashboard 始终启用
        PermissionConfig.objects.update_or_create(
            identity=identity,
            module='dashboard',
            material_type=None,
            defaults={'is_enabled': True}
        )
        
        return Response({'message': '权限配置更新成功'})
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

