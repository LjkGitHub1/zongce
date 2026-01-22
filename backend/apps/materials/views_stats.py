from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from django.db.models import Count, Q
from django.http import HttpResponse
import json
from .models import (
    ResearchProject, Monograph, Paper, OtherAcademic,
    TechnologyCompetition, SocialPractice, SocialService, OtherPractice
)
from apps.users.models import User


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_statistics(request):
    """用户统计"""
    user = request.user
    
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
    
    total = 0
    by_type = {}
    by_status = {
        'pending': 0,
        'auditing': 0,
        'approved': 0,
        'rejected': 0,
        'withdrawn': 0
    }
    
    for type_name, model in models:
        materials = model.objects.filter(student_id=user.student_id)
        count = materials.count()
        total += count
        by_type[type_name] = count
        
        for status in by_status.keys():
            by_status[status] += materials.filter(status=status).count()
    
    return Response({
        'total': total,
        'by_type': by_type,
        'by_status': by_status
    })


@api_view(['GET'])
@permission_classes([IsAdminUser])
def admin_statistics(request):
    """管理员统计"""
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
    
    total = 0
    by_type = {}
    by_status = {
        'pending': 0,
        'auditing': 0,
        'approved': 0,
        'rejected': 0,
        'withdrawn': 0
    }
    by_identity = {
        'graduate': 0,
        'undergraduate': 0
    }
    
    for type_name, model in models:
        materials = model.objects.all()
        count = materials.count()
        total += count
        by_type[type_name] = count
        
        for status in by_status.keys():
            by_status[status] += materials.filter(status=status).count()
        
        by_identity['graduate'] += materials.filter(identity='graduate').count()
        by_identity['undergraduate'] += materials.filter(identity='undergraduate').count()
    
    # 用户参与度统计
    total_users = User.objects.filter(is_staff=False).count()
    users_with_materials = User.objects.filter(
        is_staff=False,
        student_id__in=[
            *ResearchProject.objects.values_list('student_id', flat=True).distinct(),
            *Monograph.objects.values_list('student_id', flat=True).distinct(),
            *Paper.objects.values_list('student_id', flat=True).distinct(),
            *OtherAcademic.objects.values_list('student_id', flat=True).distinct(),
            *TechnologyCompetition.objects.values_list('student_id', flat=True).distinct(),
            *SocialPractice.objects.values_list('student_id', flat=True).distinct(),
            *SocialService.objects.values_list('student_id', flat=True).distinct(),
            *OtherPractice.objects.values_list('student_id', flat=True).distinct(),
        ]
    ).distinct().count()
    
    participation_rate = (users_with_materials / total_users * 100) if total_users > 0 else 0
    
    return Response({
        'total': total,
        'by_type': by_type,
        'by_status': by_status,
        'by_identity': by_identity,
        'participation': {
            'total_users': total_users,
            'users_with_materials': users_with_materials,
            'participation_rate': round(participation_rate, 2)
        }
    })


@api_view(['GET'])
@permission_classes([IsAdminUser])
def technology_competition_award_statistics(request):
    """科技竞赛获奖情况统计 - 统计所有已提交的记录，不考虑审核状态"""
    identity = request.query_params.get('identity')  # graduate, undergraduate, 或 None（全部）
    
    # 基础查询 - 统计所有已提交的记录，不考虑状态
    queryset = TechnologyCompetition.objects.all()
    
    # 按身份筛选
    if identity:
        queryset = queryset.filter(identity=identity)
    
    # 总获奖数
    total_awards = queryset.count()
    
    # 按级别统计
    level_stats = {
        'national': 0,
        'provincial': 0,
        'school': 0,
        'college': 0
    }
    level_choices = ['national', 'provincial', 'school', 'college']
    for level in level_choices:
        count = queryset.filter(level=level).count()
        level_stats[level] = count
    
    # 按获奖等级统计 - 先统计预设的等级，再统计其他等级
    grade_stats = {
        '一等奖': 0,
        '二等奖': 0,
        '三等奖': 0,
        '优秀奖': 0
    }
    grade_choices = ['一等奖', '二等奖', '三等奖', '优秀奖']
    for grade in grade_choices:
        count = queryset.filter(grade=grade).count()
        grade_stats[grade] = count
    
    # 按级别和获奖等级交叉统计
    level_grade_stats = {}
    for level in level_choices:
        level_grade_stats[level] = {}
        for grade in grade_choices:
            count = queryset.filter(level=level, grade=grade).count()
            level_grade_stats[level][grade] = count
    
    return Response({
        'total_awards': total_awards,
        'by_level': level_stats,
        'by_grade': grade_stats,
        'by_level_grade': level_grade_stats
    })