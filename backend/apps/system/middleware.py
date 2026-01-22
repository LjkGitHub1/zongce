from django.utils.deprecation import MiddlewareMixin
from django.utils import timezone
from .models import OperationLog
import json


class OperationLogMiddleware(MiddlewareMixin):
    """操作日志中间件"""
    
    # 需要记录的操作方法
    OPERATION_METHODS = ['POST', 'PUT', 'PATCH', 'DELETE']
    
    # 需要排除的路径
    EXCLUDE_PATHS = [
        '/api/auth/login/',
        '/api/auth/refresh/',
        '/api/system/operation-logs/',
    ]
    
    # 操作类型映射
    OPERATION_MAP = {
        'POST': '创建',
        'PUT': '更新',
        'PATCH': '更新',
        'DELETE': '删除',
    }
    
    # 模块映射
    MODULE_MAP = {
        '/api/auth/': '用户管理',
        '/api/materials/': '材料管理',
        '/api/system/audit/': '审核管理',
        '/api/system/permission-configs/': '权限管理',
        '/api/system/announcements/': '系统管理',
        '/api/system/messages/': '系统管理',
        '/api/system/classes/': '系统管理',
        '/api/users/': '用户管理',
    }
    
    def process_response(self, request, response):
        """处理响应时记录日志"""
        # 只记录需要记录的操作方法
        if request.method not in self.OPERATION_METHODS:
            return response
        
        # 排除不需要记录的路径
        if any(request.path.startswith(path) for path in self.EXCLUDE_PATHS):
            return response
        
        # 只记录成功的操作（2xx状态码）
        if not (200 <= response.status_code < 300):
            return response
        
        # 获取用户信息
        user = getattr(request, 'user', None)
        if not user or not user.is_authenticated:
            return response
        
        try:
            # 确定操作类型
            operation = self.OPERATION_MAP.get(request.method, request.method)
            
            # 确定模块
            module = '系统管理'
            for path_prefix, module_name in self.MODULE_MAP.items():
                if request.path.startswith(path_prefix):
                    module = module_name
                    break
            
            # 获取操作内容
            content = self._get_operation_content(request, response)
            
            # 获取IP地址
            ip_address = self._get_client_ip(request)
            
            # 获取用户代理
            user_agent = request.META.get('HTTP_USER_AGENT', '')[:500]
            
            # 创建日志记录
            OperationLog.objects.create(
                user=user,
                user_name=user.name if hasattr(user, 'name') else user.student_id,
                operation=operation,
                module=module,
                content=content,
                ip_address=ip_address,
                user_agent=user_agent
            )
        except Exception as e:
            # 记录日志失败不应该影响正常请求
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f'记录操作日志失败: {str(e)}')
        
        return response
    
    def _get_operation_content(self, request, response):
        """获取操作内容"""
        try:
            # 尝试从请求数据中获取内容
            data = {}
            if hasattr(request, 'data'):
                data = request.data
            elif hasattr(request, 'body') and request.body:
                try:
                    import json
                    data = json.loads(request.body)
                except:
                    pass
            
            # 构建操作内容
            content_parts = []
            
            # 根据路径确定操作对象
            path = request.path
            if '/materials/' in path:
                # 材料相关操作
                if 'research-project' in path:
                    content_parts.append('课题项目')
                elif 'monograph' in path:
                    content_parts.append('专著')
                elif 'paper' in path:
                    content_parts.append('论文')
                elif 'other-academic' in path:
                    content_parts.append('其他学术成果')
                elif 'technology-competition' in path:
                    content_parts.append('科技竞赛')
                elif 'social-practice' in path:
                    content_parts.append('社会实践调研')
                elif 'social-service' in path:
                    content_parts.append('服务社会')
                elif 'other-practice' in path:
                    content_parts.append('其他实践活动')
            
            # 添加操作数据的关键信息
            if isinstance(data, dict):
                if 'title' in data:
                    content_parts.append(f"标题: {data.get('title')}")
                elif 'name' in data:
                    content_parts.append(f"名称: {data.get('name')}")
                elif 'competition' in data:
                    content_parts.append(f"赛事: {data.get('competition')}")
                elif 'project_name' in data:
                    content_parts.append(f"项目名称: {data.get('project_name')}")
                elif 'monograph_name' in data:
                    content_parts.append(f"专著名称: {data.get('monograph_name')}")
                elif 'paper_title' in data:
                    content_parts.append(f"论文标题: {data.get('paper_title')}")
                elif 'achievement_name' in data:
                    content_parts.append(f"成果名称: {data.get('achievement_name')}")
            
            content = ' | '.join(content_parts) if content_parts else f"{request.method} {request.path}"
            
            return content[:500]  # 限制长度
        except Exception:
            return f"{request.method} {request.path}"
    
    def _get_client_ip(self, request):
        """获取客户端IP地址"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip or ''

