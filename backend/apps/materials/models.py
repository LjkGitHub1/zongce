from django.db import models
from django.conf import settings


class BaseMaterial(models.Model):
    """材料基类"""
    STATUS_CHOICES = [
        ('pending', '待审核'),
        ('auditing', '审核中'),
        ('approved', '已通过'),
        ('rejected', '已驳回'),
        ('withdrawn', '已撤回'),
    ]
    
    IDENTITY_CHOICES = [
        ('teacher', '老师'),
        ('graduate', '研究生'),
        ('undergraduate', '本科生'),
    ]
    
    student_id = models.CharField(max_length=50, db_index=True, verbose_name='学号')
    name = models.CharField(max_length=100, verbose_name='姓名')
    identity = models.CharField(max_length=20, choices=IDENTITY_CHOICES, verbose_name='身份')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', db_index=True, verbose_name='状态')
    created_at = models.DateTimeField(auto_now_add=True, db_index=True, verbose_name='创建时间')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='更新时间')
    
    class Meta:
        abstract = True


class ResearchProject(BaseMaterial):
    """课题项目"""
    LEVEL_CHOICES = [
        ('national', '国家级'),
        ('provincial', '省级'),
        ('school', '校级'),
        ('college', '院级'),
    ]
    
    project_name = models.CharField(max_length=200, verbose_name='项目名称')
    level = models.CharField(max_length=50, choices=LEVEL_CHOICES, blank=True, null=True, verbose_name='项目级别')
    start_date = models.DateField(blank=True, null=True, verbose_name='立项时间')
    end_date = models.DateField(blank=True, null=True, verbose_name='结题时间')
    funds = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True, verbose_name='项目经费（万元）')
    number = models.CharField(max_length=100, blank=True, null=True, verbose_name='项目编号')
    host = models.TextField(blank=True, null=True, verbose_name='主持人（姓名+学号）')
    participants = models.TextField(blank=True, null=True, verbose_name='参与人（姓名+学号）')
    supervisor = models.CharField(max_length=100, blank=True, null=True, verbose_name='指导教师')
    contact_phone = models.CharField(max_length=20, blank=True, null=True, verbose_name='负责人联系电话')
    remark = models.TextField(blank=True, null=True, verbose_name='备注')
    
    class Meta:
        db_table = 'research_project'
        verbose_name = '课题项目'
        verbose_name_plural = '课题项目'
        ordering = ['-created_at']


class Monograph(BaseMaterial):
    """专著"""
    title = models.CharField(max_length=200, verbose_name='专著名称')
    publish = models.CharField(max_length=200, blank=True, null=True, verbose_name='出版社')
    publish_date = models.DateField(blank=True, null=True, verbose_name='出版时间')
    number = models.CharField(max_length=100, blank=True, null=True, verbose_name='编号')
    supervisor = models.CharField(max_length=100, blank=True, null=True, verbose_name='导师姓名')
    word_count = models.IntegerField(blank=True, null=True, verbose_name='撰写字数')
    author = models.TextField(blank=True, null=True, verbose_name='作者及顺序')
    remark = models.TextField(blank=True, null=True, verbose_name='备注')
    
    class Meta:
        db_table = 'monograph'
        verbose_name = '专著'
        verbose_name_plural = '专著'
        ordering = ['-created_at']


class Paper(BaseMaterial):
    """论文"""
    title = models.CharField(max_length=300, verbose_name='论文题目')
    publication = models.CharField(max_length=200, blank=True, null=True, verbose_name='刊物名称')
    category = models.CharField(max_length=100, blank=True, null=True, verbose_name='类别')
    publication_number = models.CharField(max_length=100, blank=True, null=True, verbose_name='刊号')
    publication_date = models.DateField(blank=True, null=True, db_index=True, verbose_name='发表时间')
    journal_status = models.CharField(max_length=100, blank=True, null=True, verbose_name='期刊收录情况')
    partition = models.CharField(max_length=50, blank=True, null=True, verbose_name='中科院分区')
    supervisor = models.CharField(max_length=100, blank=True, null=True, verbose_name='导师姓名')
    first_unit = models.BooleanField(blank=True, null=True, verbose_name='是否第一单位')
    communication = models.BooleanField(blank=True, null=True, verbose_name='导师是否通讯')
    author = models.TextField(blank=True, null=True, verbose_name='作者及排名')
    remark = models.TextField(blank=True, null=True, verbose_name='备注')
    
    class Meta:
        db_table = 'paper'
        verbose_name = '论文'
        verbose_name_plural = '论文'
        ordering = ['-created_at']


class OtherAcademic(BaseMaterial):
    """其他学术成果"""
    content = models.TextField(blank=True, null=True, verbose_name='富文本内容')
    
    class Meta:
        db_table = 'other_academic'
        verbose_name = '其他学术成果'
        verbose_name_plural = '其他学术成果'
        ordering = ['-created_at']


class TechnologyCompetition(BaseMaterial):
    """科技竞赛"""
    LEVEL_CHOICES = [
        ('national', '国家级'),
        ('provincial', '省级'),
        ('school', '校级'),
        ('college', '院级'),
    ]
    
    GRADE_CHOICES = [
        ('first', '一等奖'),
        ('second', '二等奖'),
        ('third', '三等奖'),
        ('excellent', '优秀奖'),
    ]
    
    competition = models.CharField(max_length=200, verbose_name='赛事名称')
    is_whitelist = models.BooleanField(blank=True, null=True, verbose_name='是否为白名单赛事')
    title = models.CharField(max_length=200, blank=True, null=True, verbose_name='作品名称')
    level = models.CharField(max_length=50, choices=LEVEL_CHOICES, blank=True, null=True, db_index=True, verbose_name='级别')
    award_date = models.CharField(max_length=50, blank=True, null=True, verbose_name='获奖时间')
    grade = models.CharField(max_length=50, blank=True, null=True, verbose_name='获奖等级')
    organization = models.CharField(max_length=200, blank=True, null=True, verbose_name='组织单位名称')
    group = models.CharField(max_length=20, blank=True, null=True, verbose_name='团体/个人')
    leader = models.TextField(blank=True, null=True, verbose_name='负责人（姓名+学号）')
    members = models.TextField(blank=True, null=True, verbose_name='队员（姓名+学号）')
    supervisor = models.CharField(max_length=100, blank=True, null=True, verbose_name='指导老师')
    certificate_number = models.CharField(max_length=100, blank=True, null=True, verbose_name='奖状编号')
    contact_phone = models.CharField(max_length=20, blank=True, null=True, verbose_name='负责人联系电话')
    remark = models.TextField(blank=True, null=True, verbose_name='备注')
    
    class Meta:
        db_table = 'technology_competition'
        verbose_name = '科技竞赛'
        verbose_name_plural = '科技竞赛'
        ordering = ['-created_at']


class SocialPractice(BaseMaterial):
    """社会实践调研"""
    LEVEL_CHOICES = [
        ('national', '国家级'),
        ('provincial', '省级'),
        ('school', '校级'),
        ('college', '院级'),
    ]
    
    title = models.CharField(max_length=200, verbose_name='名称')
    level = models.CharField(max_length=50, choices=LEVEL_CHOICES, blank=True, null=True, verbose_name='级别')
    date = models.DateField(blank=True, null=True, verbose_name='时间')
    host = models.TextField(blank=True, null=True, verbose_name='主持人（姓名+学号）')
    participants = models.TextField(blank=True, null=True, verbose_name='参与人（姓名+学号）')
    content = models.TextField(blank=True, null=True, verbose_name='具体内容')
    contact_phone = models.CharField(max_length=20, blank=True, null=True, verbose_name='负责人联系电话')
    remark = models.TextField(blank=True, null=True, verbose_name='备注')
    
    class Meta:
        db_table = 'social_practice'
        verbose_name = '社会实践调研'
        verbose_name_plural = '社会实践调研'
        ordering = ['-created_at']


class SocialService(BaseMaterial):
    """服务社会"""
    LEVEL_CHOICES = [
        ('national', '国家级'),
        ('provincial', '省级'),
        ('school', '校级'),
        ('college', '院级'),
    ]
    
    title = models.CharField(max_length=200, verbose_name='名称')
    level = models.CharField(max_length=50, choices=LEVEL_CHOICES, blank=True, null=True, verbose_name='级别')
    date = models.DateField(blank=True, null=True, verbose_name='时间')
    author = models.TextField(blank=True, null=True, verbose_name='作者及顺序')
    content = models.TextField(blank=True, null=True, verbose_name='具体内容')
    contact_phone = models.CharField(max_length=20, blank=True, null=True, verbose_name='负责人联系电话')
    remark = models.TextField(blank=True, null=True, verbose_name='备注')
    
    class Meta:
        db_table = 'social_service'
        verbose_name = '服务社会'
        verbose_name_plural = '服务社会'
        ordering = ['-created_at']


class OtherPractice(BaseMaterial):
    """其他实践活动"""
    LEVEL_CHOICES = [
        ('national', '国家级'),
        ('provincial', '省级'),
        ('school', '校级'),
        ('college', '院级'),
    ]
    
    title = models.CharField(max_length=200, verbose_name='名称')
    level = models.CharField(max_length=50, choices=LEVEL_CHOICES, blank=True, null=True, verbose_name='级别')
    date = models.DateField(blank=True, null=True, verbose_name='时间')
    organization = models.CharField(max_length=200, blank=True, null=True, verbose_name='提供证明单位')
    author = models.TextField(blank=True, null=True, verbose_name='参与人')
    content = models.TextField(blank=True, null=True, verbose_name='具体内容')
    contact_phone = models.CharField(max_length=20, blank=True, null=True, verbose_name='负责人联系电话')
    remark = models.TextField(blank=True, null=True, verbose_name='备注')
    
    class Meta:
        db_table = 'other_practice'
        verbose_name = '其他实践活动'
        verbose_name_plural = '其他实践活动'
        ordering = ['-created_at']


class File(models.Model):
    """文件表"""
    file_name = models.CharField(max_length=255, verbose_name='文件名')
    original_name = models.CharField(max_length=255, verbose_name='原始文件名')
    file_path = models.CharField(max_length=500, verbose_name='文件路径')
    file_size = models.BigIntegerField(verbose_name='文件大小（字节）')
    file_type = models.CharField(max_length=50, blank=True, null=True, verbose_name='文件类型')
    file_ext = models.CharField(max_length=10, blank=True, null=True, verbose_name='文件扩展名')
    material_type = models.CharField(max_length=50, db_index=True, verbose_name='材料类型')
    material_id = models.BigIntegerField(db_index=True, verbose_name='材料ID')
    upload_user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='uploaded_files', verbose_name='上传用户')
    created_at = models.DateTimeField(auto_now_add=True, db_index=True, verbose_name='创建时间')
    
    class Meta:
        db_table = 'file'
        verbose_name = '文件'
        verbose_name_plural = '文件'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['material_type', 'material_id']),
        ]

