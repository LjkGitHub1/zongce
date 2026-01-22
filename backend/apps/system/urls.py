from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    AuditRecordViewSet, AnnouncementViewSet, MessageViewSet, PermissionConfigViewSet,
    OperationLogViewSet,
    audit_material, audit_statistics, get_class_list, get_class_statistics, get_all_class_statistics, get_unsubmitted_students, get_user_permissions,
    batch_update_permissions
)

router = DefaultRouter()
router.register(r'audit-records', AuditRecordViewSet, basename='audit-record')
router.register(r'announcements', AnnouncementViewSet, basename='announcement')
router.register(r'messages', MessageViewSet, basename='message')
router.register(r'permission-configs', PermissionConfigViewSet, basename='permission-config')
router.register(r'operation-logs', OperationLogViewSet, basename='operation-log')

urlpatterns = [
    # 将 batch-update 放在 router.urls 之前，避免被 ViewSet 路由拦截
    path('permission-configs/batch-update/', batch_update_permissions, name='batch_update_permissions'),
    path('', include(router.urls)),
    path('audit/', audit_material, name='audit_material'),
    path('audit/statistics/', audit_statistics, name='audit_statistics'),
    path('classes/', get_class_list, name='get_class_list'),
    path('classes/statistics/', get_class_statistics, name='get_class_statistics'),
    path('classes/statistics/all/', get_all_class_statistics, name='get_all_class_statistics'),
    path('classes/unsubmitted/', get_unsubmitted_students, name='get_unsubmitted_students'),
    path('permissions/user/', get_user_permissions, name='get_user_permissions'),
]

