# 🎓 学生就业管理系统

> 基于 Python Flask + MySQL 的学生就业信息管理平台，支持学生信息管理、企业岗位管理、就业数据统计分析。

![Python](https://img.shields.io/badge/Python-3.11+-blue)
![Flask](https://img.shields.io/badge/Flask-3.x-green)
![MySQL](https://img.shields.io/badge/MySQL-8.0+-orange)

## 功能模块

| 模块 | 说明 |
|------|------|
| 👨‍🎓 **学生管理** | 毕业生信息录入、简历管理、就业状态跟踪 |
| 🏢 **企业管理** | 入驻企业信息维护、岗位发布、宣讲会管理 |
| 💼 **招聘管理** | 招聘信息发布、学生投递、录用管理 |
| 📊 **数据统计** | 就业率分析、企业岗位统计、数据报表 |
| 📰 **新闻公告** | 就业新闻、招聘会公告发布 |

## 数据库表结构

| 表名 | 说明 |
|------|------|
| `graduate` | 毕业生信息 |
| `employer` | 企业信息 |
| `recruitment` | 招聘信息 |
| `application` | 投递申请 |
| `resume` | 简历信息 |
| `jobfair` | 宣讲会/招聘会 |
| `booth` | 展位管理 |
| `news` | 新闻公告 |

## 项目结构

```
├── app.py              # Flask 后端主程序
├── login.html          # 登录页面
├── admin.html          # 管理员后台
├── graduate.html       # 学生端
├── employer.html       # 企业端
└── sql/
    └── employment_system.sql   # 数据库脚本
```

## 环境要求

- Python 3.11+
- MySQL 8.0+
- pip 包管理器

## 快速开始

### 1. 配置数据库

创建 MySQL 数据库并导入 SQL 脚本：

```sql
mysql -u root -p < sql/employment_system.sql
```

### 2. 修改配置

编辑 `app.py`，修改以下配置：

```python
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'your_username'
app.config['MYSQL_PASSWORD'] = 'your_password'  # ← 修改为你的 MySQL 密码
app.config['MYSQL_DB'] = 'employment_system'
```

### 3. 安装依赖

```bash
pip install flask flask-cors flask-mysqldb
```

### 4. 启动服务

```bash
python app.py
```

然后在浏览器打开 `http://localhost:5000`

## 技术栈

| 技术 | 说明 |
|------|------|
| Flask | Python Web 框架 |
| Flask-CORS | 跨域支持 |
| Flask-MySQLdb | MySQL 数据库连接 |
| MySQL | 关系型数据库 |
| 原生 HTML/JS | 前端页面 |

## 登录说明

| 角色 | 账号 |
|------|------|
| 管理员 | admin / admin123 |
| 学生 | 学号 / 初始密码 |
| 企业 | 企业账号 / 初始密码 |

> ⚠️ 首次使用请及时修改默认密码
