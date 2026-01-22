from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    ResearchProjectViewSet, MonographViewSet, PaperViewSet, OtherAcademicViewSet,
    TechnologyCompetitionViewSet, SocialPracticeViewSet, SocialServiceViewSet, OtherPracticeViewSet
)
from .views_stats import user_statistics, admin_statistics, technology_competition_award_statistics
from .views_export import export_user_materials, export_all_materials, export_statistics, download_all_by_class

router = DefaultRouter()
router.register(r'research-projects', ResearchProjectViewSet, basename='research-project')
router.register(r'monographs', MonographViewSet, basename='monograph')
router.register(r'papers', PaperViewSet, basename='paper')
router.register(r'other-academics', OtherAcademicViewSet, basename='other-academic')
router.register(r'technology-competitions', TechnologyCompetitionViewSet, basename='technology-competition')
router.register(r'social-practices', SocialPracticeViewSet, basename='social-practice')
router.register(r'social-services', SocialServiceViewSet, basename='social-service')
router.register(r'other-practices', OtherPracticeViewSet, basename='other-practice')

urlpatterns = [
    path('', include(router.urls)),
    path('statistics/user/', user_statistics, name='user_statistics'),
    path('statistics/admin/', admin_statistics, name='admin_statistics'),
    path('statistics/technology-competition-awards/', technology_competition_award_statistics, name='technology_competition_award_statistics'),
    path('export/user/', export_user_materials, name='export_user_materials'),
    path('export/all/', export_all_materials, name='export_all_materials'),
    path('export/statistics/', export_statistics, name='export_statistics'),
    path('export/download-all-by-class/', download_all_by_class, name='download_all_by_class'),
]

