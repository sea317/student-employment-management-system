# ============================================================
# PythonAnywhere WSGI 配置模板
# 把本文件内容整段复制到 Web 标签页里 "WSGI configuration file" 链接指向的文件中，
# 然后按下面的说明替换占位符，最后点 Reload。
# ============================================================

import sys
import os

# 1) 项目路径：/home/<你的用户名>/student-employment-management-system
project_home = '/home/REPLACE_USERNAME/student-employment-management-system'
if project_home not in sys.path:
    sys.path.insert(0, project_home)

# 2) 环境变量（免费账号也可用，直接写在这里）
os.environ.setdefault('SECRET_KEY', 'REPLACE_WITH_RANDOM_LONG_STRING')
os.environ.setdefault('SESSION_COOKIE_SECURE', 'true')

# 3) 数据库连接：在 Databases 标签页创建 MySQL 后，页面会给出主机名、用户名和密码
os.environ.setdefault('MYSQL_HOST', 'REPLACE_USERNAME.mysql.pythonanywhere-services.com')
os.environ.setdefault('MYSQL_PORT', '3306')
os.environ.setdefault('MYSQL_USER', 'REPLACE_USERNAME')
os.environ.setdefault('MYSQL_PASSWORD', 'REPLACE_DB_PASSWORD')
os.environ.setdefault('MYSQL_DB', 'REPLACE_USERNAME$employment_system')

# 4) 交给 PythonAnywhere 的 uWSGI 运行 Flask 应用
from app import app as application
