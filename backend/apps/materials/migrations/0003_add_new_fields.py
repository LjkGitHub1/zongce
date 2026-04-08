# Generated manually to add new fields

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('materials', '0002_initial'),
    ]

    operations = [
        # ResearchProject: 添加新字段，刪除舊字段
        migrations.AddField(
            model_name='researchproject',
            name='host',
            field=models.TextField(blank=True, null=True, verbose_name='主持人（姓名+学号）'),
        ),
        migrations.AddField(
            model_name='researchproject',
            name='participants',
            field=models.TextField(blank=True, null=True, verbose_name='参与人（姓名+学号）'),
        ),
        migrations.AddField(
            model_name='researchproject',
            name='supervisor',
            field=models.CharField(blank=True, max_length=100, null=True, verbose_name='指导教师'),
        ),
        migrations.AddField(
            model_name='researchproject',
            name='contact_phone',
            field=models.CharField(blank=True, max_length=20, null=True, verbose_name='负责人联系电话'),
        ),
        migrations.AlterField(
            model_name='researchproject',
            name='level',
            field=models.CharField(blank=True, choices=[('national', '国家级'), ('provincial', '省级'), ('school', '校级'), ('college', '院级')], max_length=50, null=True, verbose_name='项目级别'),
        ),
        # 注意：personnel 字段暫時保留，等數據遷移後再刪除
        
        # TechnologyCompetition: 添加新字段
        migrations.AddField(
            model_name='technologycompetition',
            name='leader',
            field=models.TextField(blank=True, null=True, verbose_name='负责人（姓名+学号）'),
        ),
        migrations.AddField(
            model_name='technologycompetition',
            name='members',
            field=models.TextField(blank=True, null=True, verbose_name='队员（姓名+学号）'),
        ),
        migrations.AddField(
            model_name='technologycompetition',
            name='certificate_number',
            field=models.CharField(blank=True, max_length=100, null=True, verbose_name='奖状编号'),
        ),
        migrations.AddField(
            model_name='technologycompetition',
            name='contact_phone',
            field=models.CharField(blank=True, max_length=20, null=True, verbose_name='负责人联系电话'),
        ),
        # 注意：author 字段暫時保留，等數據遷移後再刪除
        
        # SocialPractice: 添加新字段
        migrations.AddField(
            model_name='socialpractice',
            name='host',
            field=models.TextField(blank=True, null=True, verbose_name='主持人（姓名+学号）'),
        ),
        migrations.AddField(
            model_name='socialpractice',
            name='participants',
            field=models.TextField(blank=True, null=True, verbose_name='参与人（姓名+学号）'),
        ),
        migrations.AddField(
            model_name='socialpractice',
            name='content',
            field=models.TextField(blank=True, null=True, verbose_name='具体内容'),
        ),
        migrations.AddField(
            model_name='socialpractice',
            name='contact_phone',
            field=models.CharField(blank=True, max_length=20, null=True, verbose_name='负责人联系电话'),
        ),
        migrations.AlterField(
            model_name='socialpractice',
            name='level',
            field=models.CharField(blank=True, choices=[('national', '国家级'), ('provincial', '省级'), ('school', '校级'), ('college', '院级')], max_length=50, null=True, verbose_name='级别'),
        ),
        # 注意：author 字段暫時保留，等數據遷移後再刪除
        
        # SocialService: 添加新字段
        migrations.AddField(
            model_name='socialservice',
            name='content',
            field=models.TextField(blank=True, null=True, verbose_name='具体内容'),
        ),
        migrations.AddField(
            model_name='socialservice',
            name='contact_phone',
            field=models.CharField(blank=True, max_length=20, null=True, verbose_name='负责人联系电话'),
        ),
        migrations.AlterField(
            model_name='socialservice',
            name='level',
            field=models.CharField(blank=True, choices=[('national', '国家级'), ('provincial', '省级'), ('school', '校级'), ('college', '院级')], max_length=50, null=True, verbose_name='级别'),
        ),
        
        # OtherPractice: 添加新字段
        migrations.AddField(
            model_name='otherpractice',
            name='content',
            field=models.TextField(blank=True, null=True, verbose_name='具体内容'),
        ),
        migrations.AddField(
            model_name='otherpractice',
            name='contact_phone',
            field=models.CharField(blank=True, max_length=20, null=True, verbose_name='负责人联系电话'),
        ),
        migrations.AlterField(
            model_name='otherpractice',
            name='level',
            field=models.CharField(blank=True, choices=[('national', '国家级'), ('provincial', '省级'), ('school', '校级'), ('college', '院级')], max_length=50, null=True, verbose_name='级别'),
        ),
    ]

