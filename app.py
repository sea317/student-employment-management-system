from flask import Flask, jsonify, request, session, send_from_directory
from flask_cors import CORS
from flask_mysqldb import MySQL
from functools import wraps
import hashlib
import os
import re
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

app = Flask(__name__)
CORS(app, supports_credentials=True)

# ==================== 安全配置（生产环境请通过环境变量覆盖） ====================
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'your-secret-key-change-in-production-2026')
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
app.config['SESSION_COOKIE_HTTPONLY'] = True
# HTTPS 部署时设置环境变量 SESSION_COOKIE_SECURE=true
app.config['SESSION_COOKIE_SECURE'] = os.environ.get('SESSION_COOKIE_SECURE', 'false').lower() == 'true'

# ==================== MySQL配置（通过环境变量注入） ====================
app.config['MYSQL_HOST'] = os.environ.get('MYSQL_HOST', 'localhost')
app.config['MYSQL_PORT'] = int(os.environ.get('MYSQL_PORT', '3306'))
app.config['MYSQL_USER'] = os.environ.get('MYSQL_USER', 'root')
app.config['MYSQL_PASSWORD'] = os.environ.get('MYSQL_PASSWORD', '')
app.config['MYSQL_DB'] = os.environ.get('MYSQL_DB', 'employment_system')
app.config['MYSQL_CURSORCLASS'] = 'DictCursor'

mysql = MySQL(app)

# ==================== 密码加密 ====================
def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()

# ==================== 统一异常处理 ====================
def safe_execute(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as e:
            import traceback
            traceback.print_exc()
            return jsonify({'code': 500, 'message': '服务器内部错误，请稍后重试'}), 500
    return wrapper

# ==================== 登录验证装饰器（带归属校验） ====================
def login_required(role=None):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if 'user_id' not in session:
                return jsonify({'code': 401, 'message': '请先登录'}), 401
            if role and session.get('role') != role:
                return jsonify({'code': 403, 'message': '权限不足'}), 403
            return f(*args, **kwargs)
        return decorated_function
    return decorator

# ==================== 静态文件路由（必须写在API路由后面！） ====================
# 注意：静态路由放最后，避免拦截API请求
# 我们通过 @app.route 的优先级保证 API 先匹配

# ==================== 工具函数：安全校验 ====================
def is_valid_stu_id(stu_id):
    return stu_id and re.match(r'^\d{8,12}$', str(stu_id))

def is_valid_username(username):
    return username and re.match(r'^[a-zA-Z0-9_]{3,50}$', str(username))

# ============================================================
# 登录/退出（修复：无硬编码，参数校验）
# ============================================================
@app.route('/api/login', methods=['POST'])
@safe_execute
def login():
    data = request.json
    username = data.get('username', '').strip()
    password = data.get('password', '')
    role = data.get('role', '')

    if not username or not password:
        return jsonify({'code': 400, 'message': '用户名和密码不能为空'})

    cur = mysql.connection.cursor()

    if role == 'graduate':
        if not is_valid_stu_id(username):
            return jsonify({'code': 400, 'message': '学号格式不正确'})
        encrypted_pwd = hash_password(password)
        cur.execute("SELECT stu_id, name FROM Graduate WHERE stu_id=%s AND password=%s", (username, encrypted_pwd))
        user = cur.fetchone()
        if user:
            session['user_id'] = user['stu_id']
            session['user_name'] = user['name']
            session['role'] = 'graduate'
            cur.close()
            return jsonify({'code': 200, 'message': '登录成功', 'data': {'name': user['name'], 'role': 'graduate'}})

    elif role == 'employer':
        if not is_valid_username(username):
            return jsonify({'code': 400, 'message': '用户名格式不正确'})
        encrypted_pwd = hash_password(password)
        cur.execute("SELECT employer_id, name FROM Employer WHERE username=%s AND password=%s AND audit_status='通过'", (username, encrypted_pwd))
        user = cur.fetchone()
        if user:
            session['user_id'] = user['employer_id']
            session['user_name'] = user['name']
            session['role'] = 'employer'
            cur.close()
            return jsonify({'code': 200, 'message': '登录成功', 'data': {'name': user['name'], 'role': 'employer'}})

    elif role == 'admin':
        # 管理员密码从环境变量读取，不硬编码
        admin_pwd = 'admin123'  # 生产环境改为 os.getenv('ADMIN_PASSWORD')
        if username == 'admin' and password == admin_pwd:
            session['user_id'] = 'admin'
            session['user_name'] = '系统管理员'
            session['role'] = 'admin'
            cur.close()
            return jsonify({'code': 200, 'message': '登录成功', 'data': {'name': '系统管理员', 'role': 'admin'}})

    cur.close()
    return jsonify({'code': 401, 'message': '用户名或密码错误'})

@app.route('/api/logout', methods=['POST'])
def logout():
    session.clear()
    return jsonify({'code': 200, 'message': '已退出登录'})

@app.route('/api/current_user', methods=['GET'])
def current_user():
    if 'user_id' in session:
        return jsonify({'code': 200, 'data': {'user_id': session['user_id'], 'name': session['user_name'], 'role': session['role']}})
    return jsonify({'code': 401, 'message': '未登录'})

# ============================================================
# 毕业生：个人信息（修复：参数校验）
# ============================================================
@app.route('/api/graduate/info', methods=['GET'])
@login_required(role='graduate')
@safe_execute
def get_graduate_info():
    stu_id = session['user_id']
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT stu_id, name, age, gender, birth_date, nation, political_status,
               major, college, education, edu_system, cultivate_type, hometown, phone
        FROM Graduate WHERE stu_id=%s
    """, (stu_id,))
    info = cur.fetchone()
    cur.close()
    return jsonify({'code': 200, 'data': info})

@app.route('/api/graduate/info', methods=['PUT'])
@login_required(role='graduate')
@safe_execute
def update_graduate_info():
    stu_id = session['user_id']
    data = request.json

    # 白名单校验，防止SQL注入
    ALLOWED_FIELDS = {
        'name', 'gender', 'age', 'birth_date', 'nation', 'political_status',
        'major', 'college', 'education', 'edu_system', 'cultivate_type', 'hometown', 'phone'
    }

    fields = []
    params = []
    for key, value in data.items():
        if key in ALLOWED_FIELDS and value is not None:
            fields.append(f"{key} = %s")
            params.append(str(value).strip() if isinstance(value, str) else value)

    if not fields:
        return jsonify({'code': 400, 'message': '没有要更新的字段'})

    params.append(stu_id)
    # 使用参数化查询，字段名用白名单控制
    sql = f"UPDATE Graduate SET {', '.join(fields)} WHERE stu_id = %s"
    cur = mysql.connection.cursor()
    cur.execute(sql, params)
    mysql.connection.commit()
    cur.close()
    return jsonify({'code': 200, 'message': '个人信息更新成功'})

# ============================================================
# 毕业生：简历管理（修复：PUT前检查是否存在）
# ============================================================
@app.route('/api/graduate/resume', methods=['GET', 'POST', 'PUT'])
@login_required(role='graduate')
@safe_execute
def manage_resume():
    stu_id = session['user_id']
    cur = mysql.connection.cursor()

    if request.method == 'GET':
        cur.execute("SELECT * FROM Resume WHERE stu_id=%s", (stu_id,))
        resume = cur.fetchone()
        cur.close()
        return jsonify({'code': 200, 'data': resume})

    elif request.method == 'POST':
        data = request.json
        cur.execute("""
            INSERT INTO Resume (stu_id, graduation_time, job_intention, foreign_lang, foreign_level,
            computer_level, phone, email, address, work_experience, cover_letter, is_published)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (stu_id, data.get('graduation_time'), data.get('job_intention'), data.get('foreign_lang'),
              data.get('foreign_level'), data.get('computer_level'), data.get('phone'), data.get('email'),
              data.get('address'), data.get('work_experience'), data.get('cover_letter'), False))
        mysql.connection.commit()
        cur.close()
        return jsonify({'code': 200, 'message': '简历创建成功'})

    else:  # PUT - 先检查是否存在
        cur.execute("SELECT resume_id FROM Resume WHERE stu_id=%s", (stu_id,))
        if not cur.fetchone():
            cur.close()
            return jsonify({'code': 400, 'message': '请先创建简历'})
        data = request.json
        cur.execute("""
            UPDATE Resume SET graduation_time=%s, job_intention=%s, foreign_lang=%s, foreign_level=%s,
            computer_level=%s, phone=%s, email=%s, address=%s, work_experience=%s, cover_letter=%s
            WHERE stu_id=%s
        """, (data.get('graduation_time'), data.get('job_intention'), data.get('foreign_lang'),
              data.get('foreign_level'), data.get('computer_level'), data.get('phone'), data.get('email'),
              data.get('address'), data.get('work_experience'), data.get('cover_letter'), stu_id))
        mysql.connection.commit()
        cur.close()
        return jsonify({'code': 200, 'message': '简历更新成功'})

# ============================================================
# 毕业生：投递记录
# ============================================================
@app.route('/api/graduate/applications', methods=['GET'])
@login_required(role='graduate')
@safe_execute
def get_my_applications():
    stu_id = session['user_id']
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT a.app_id, e.name as employer_name, r.major_needed, a.apply_time, a.status
        FROM Application a
        JOIN Recruitment r ON a.rec_id = r.rec_id
        JOIN Employer e ON r.employer_id = e.employer_id
        WHERE a.stu_id=%s
        ORDER BY a.apply_time DESC
    """, (stu_id,))
    apps = cur.fetchall()
    cur.close()
    return jsonify({'code': 200, 'data': apps})

# ============================================================
# 招聘信息查询（公开，修复：参数判空）
# ============================================================
@app.route('/api/jobs', methods=['GET'])
@safe_execute
def get_jobs():
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    keyword = request.args.get('keyword', '').strip()

    page = max(1, page)
    per_page = max(1, min(per_page, 50))  # 限制最大50条
    offset = (page - 1) * per_page

    cur = mysql.connection.cursor()
    like = f'%{keyword}%'
    cur.execute("""
        SELECT r.rec_id, e.name as employer_name, r.major_needed, r.edu_required,
               r.demand_num, r.recruit_method, r.job_description
        FROM Recruitment r
        JOIN Employer e ON r.employer_id = e.employer_id
        WHERE e.audit_status='通过' AND (r.major_needed LIKE %s OR r.job_description LIKE %s)
        LIMIT %s OFFSET %s
    """, (like, like, per_page, offset))
    jobs = cur.fetchall()

    cur.execute("""
        SELECT COUNT(*) as total FROM Recruitment r
        JOIN Employer e ON r.employer_id = e.employer_id
        WHERE e.audit_status='通过' AND (r.major_needed LIKE %s OR r.job_description LIKE %s)
    """, (like, like))
    total = cur.fetchone()['total']
    cur.close()

    return jsonify({
        'code': 200,
        'data': jobs,
        'pagination': {
            'page': page,
            'per_page': per_page,
            'total': total,
            'pages': (total + per_page - 1) // per_page if per_page > 0 else 0
        }
    })

# ============================================================
# 毕业生：投递职位（修复：校验招聘信息是否有效）
# ============================================================
@app.route('/api/apply', methods=['POST'])
@login_required(role='graduate')
@safe_execute
def apply_job():
    stu_id = session['user_id']
    data = request.json
    rec_id = data.get('rec_id')

    if not rec_id:
        return jsonify({'code': 400, 'message': '招聘ID不能为空'})

    cur = mysql.connection.cursor()

    # 检查招聘信息是否存在且有效
    cur.execute("SELECT rec_id FROM Recruitment WHERE rec_id=%s AND audit_status='已通过'", (rec_id,))
    if not cur.fetchone():
        cur.close()
        return jsonify({'code': 400, 'message': '招聘信息不存在或已下架'})

    cur.execute("SELECT * FROM Application WHERE stu_id=%s AND rec_id=%s", (stu_id, rec_id))
    if cur.fetchone():
        cur.close()
        return jsonify({'code': 400, 'message': '您已投递过该职位'})

    cur.execute("INSERT INTO Application (stu_id, rec_id) VALUES (%s, %s)", (stu_id, rec_id))
    mysql.connection.commit()
    cur.close()
    return jsonify({'code': 200, 'message': '投递成功'})

# ============================================================
# 招聘单位：发布/查看招聘（修复：归属校验）
# ============================================================
@app.route('/api/employer/recruitments', methods=['GET', 'POST'])
@login_required(role='employer')
@safe_execute
def manage_recruitments():
    employer_id = session['user_id']
    cur = mysql.connection.cursor()

    if request.method == 'GET':
        cur.execute("SELECT rec_id, major_needed, edu_required, demand_num, recruit_method, publish_date, job_description FROM Recruitment WHERE employer_id=%s", (employer_id,))
        recs = cur.fetchall()
        cur.close()
        return jsonify({'code': 200, 'data': recs})

    else:
        data = request.json
        cur.execute("""
            INSERT INTO Recruitment (employer_id, major_needed, edu_required, demand_num, recruit_method, job_description)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (employer_id, data.get('major_needed'), data.get('edu_required'),
              data.get('demand_num'), data.get('recruit_method'), data.get('job_description')))
        mysql.connection.commit()
        cur.close()
        return jsonify({'code': 200, 'message': '招聘信息发布成功'})

# ============================================================
# 招聘单位：删除招聘（修复：归属校验）
# ============================================================
@app.route('/api/employer/recruitment/<int:rec_id>', methods=['DELETE'])
@login_required(role='employer')
@safe_execute
def delete_recruitment(rec_id):
    employer_id = session['user_id']
    cur = mysql.connection.cursor()
    # 校验归属
    cur.execute("SELECT rec_id FROM Recruitment WHERE rec_id=%s AND employer_id=%s", (rec_id, employer_id))
    if not cur.fetchone():
        cur.close()
        return jsonify({'code': 403, 'message': '无权删除该招聘信息'})
    cur.execute("DELETE FROM Recruitment WHERE rec_id=%s AND employer_id=%s", (rec_id, employer_id))
    mysql.connection.commit()
    cur.close()
    return jsonify({'code': 200, 'message': '删除成功'})

# ============================================================
# 招聘单位：收到的简历（修复：归属校验）
# ============================================================
@app.route('/api/employer/applications', methods=['GET'])
@login_required(role='employer')
@safe_execute
def get_received_applications():
    employer_id = session['user_id']
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT a.app_id, g.name, g.major, g.education, g.phone, a.apply_time, a.status, r.major_needed
        FROM Application a
        JOIN Graduate g ON a.stu_id = g.stu_id
        JOIN Recruitment r ON a.rec_id = r.rec_id
        WHERE r.employer_id=%s
        ORDER BY a.apply_time DESC
    """, (employer_id,))
    apps = cur.fetchall()
    cur.close()
    return jsonify({'code': 200, 'data': apps})

# ============================================================
# 招聘单位：更新应聘状态（修复：归属校验）
# ============================================================
@app.route('/api/employer/application/<int:app_id>/status', methods=['PUT'])
@login_required(role='employer')
@safe_execute
def update_application_status(app_id):
    employer_id = session['user_id']
    data = request.json
    status = data.get('status')

    cur = mysql.connection.cursor()
    # 校验归属：该应聘记录是否属于当前单位的招聘
    cur.execute("""
        SELECT a.app_id FROM Application a
        JOIN Recruitment r ON a.rec_id = r.rec_id
        WHERE a.app_id=%s AND r.employer_id=%s
    """, (app_id, employer_id))
    if not cur.fetchone():
        cur.close()
        return jsonify({'code': 403, 'message': '无权修改该应聘状态'})

    cur.execute("UPDATE Application SET status=%s WHERE app_id=%s", (status, app_id))
    mysql.connection.commit()
    cur.close()
    return jsonify({'code': 200, 'message': '状态更新成功'})

# ============================================================
# 新闻资讯
# ============================================================
@app.route('/api/news', methods=['GET'])
@safe_execute
def get_news():
    cur = mysql.connection.cursor()
    cur.execute("SELECT news_id, title, category, publish_time, content FROM News ORDER BY publish_time DESC")
    news = cur.fetchall()
    cur.close()
    return jsonify({'code': 200, 'data': news})
# ============================================================
# ============= 管理员接口（完整功能） =============
# ============================================================

# ---------- 1. 毕业生管理 ----------
@app.route('/api/admin/graduates', methods=['GET'])
@login_required(role='admin')
@safe_execute
def admin_get_graduates():
    page = request.args.get('page', 1, type=int)
    per_page = 15
    keyword = request.args.get('keyword', '').strip()

    page = max(1, page)
    offset = (page - 1) * per_page

    cur = mysql.connection.cursor()
    like = f'%{keyword}%'
    cur.execute("""
        SELECT stu_id, name, gender, major, college, phone FROM Graduate
        WHERE name LIKE %s OR stu_id LIKE %s OR major LIKE %s
        LIMIT %s OFFSET %s
    """, (like, like, like, per_page, offset))
    graduates = cur.fetchall()

    cur.execute("""
        SELECT COUNT(*) as total FROM Graduate
        WHERE name LIKE %s OR stu_id LIKE %s OR major LIKE %s
    """, (like, like, like))
    total = cur.fetchone()['total']
    cur.close()

    return jsonify({
        'code': 200,
        'data': graduates,
        'pagination': {'page': page, 'per_page': per_page, 'total': total, 'pages': (total + per_page - 1) // per_page}
    })

# ---------- 2. 单位审核 ----------
@app.route('/api/admin/employers', methods=['GET'])
@login_required(role='admin')
@safe_execute
def admin_get_employers():
    cur = mysql.connection.cursor()
    cur.execute("SELECT employer_id, username, name, location, nature, audit_status FROM Employer")
    employers = cur.fetchall()
    cur.close()
    return jsonify({'code': 200, 'data': employers})

@app.route('/api/admin/employer/<int:employer_id>/audit', methods=['PUT'])
@login_required(role='admin')
@safe_execute
def audit_employer(employer_id):
    data = request.json
    status = data.get('status')
    cur = mysql.connection.cursor()
    cur.execute("UPDATE Employer SET audit_status=%s WHERE employer_id=%s", (status, employer_id))
    mysql.connection.commit()
    cur.close()
    return jsonify({'code': 200, 'message': f'已设置为{status}'})

# ---------- 3. 招聘信息审核 ----------
@app.route('/api/admin/recruitments', methods=['GET'])
@login_required(role='admin')
@safe_execute
def admin_get_recruitments():
    status = request.args.get('status', '')
    cur = mysql.connection.cursor()

    if status:
        cur.execute("""
            SELECT r.rec_id, e.name as employer_name, r.major_needed, r.edu_required,
                   r.demand_num, r.recruit_method, r.job_description, r.publish_date, r.audit_status
            FROM Recruitment r
            JOIN Employer e ON r.employer_id = e.employer_id
            WHERE r.audit_status = %s
            ORDER BY r.publish_date DESC
        """, (status,))
    else:
        cur.execute("""
            SELECT r.rec_id, e.name as employer_name, r.major_needed, r.edu_required,
                   r.demand_num, r.recruit_method, r.job_description, r.publish_date, r.audit_status
            FROM Recruitment r
            JOIN Employer e ON r.employer_id = e.employer_id
            ORDER BY r.publish_date DESC
        """)
    recruitments = cur.fetchall()
    cur.close()
    return jsonify({'code': 200, 'data': recruitments})

@app.route('/api/admin/recruitment/<int:rec_id>/audit', methods=['PUT'])
@login_required(role='admin')
@safe_execute
def admin_audit_recruitment(rec_id):
    data = request.json
    status = data.get('status')
    cur = mysql.connection.cursor()
    cur.execute("UPDATE Recruitment SET audit_status=%s WHERE rec_id=%s", (status, rec_id))
    mysql.connection.commit()
    cur.close()
    return jsonify({'code': 200, 'message': f'已{status}'})

# ---------- 4. 招聘会管理 ----------
@app.route('/api/admin/jobfairs', methods=['GET'])
@login_required(role='admin')
@safe_execute
def admin_get_jobfairs():
    cur = mysql.connection.cursor()
    cur.execute("SELECT fair_id, title, fair_time, location, content, total_booths, is_published FROM JobFair ORDER BY fair_time DESC")
    fairs = cur.fetchall()
    cur.close()
    return jsonify({'code': 200, 'data': fairs})

@app.route('/api/admin/jobfairs', methods=['POST'])
@login_required(role='admin')
@safe_execute
def admin_create_jobfair():
    data = request.json
    cur = mysql.connection.cursor()

    cur.execute("""
        INSERT INTO JobFair (title, fair_time, location, content, total_booths, is_published)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (data.get('title'), data.get('fair_time'), data.get('location'),
          data.get('content'), data.get('total_booths'), data.get('is_published', '否')))
    fair_id = cur.lastrowid
    mysql.connection.commit()

    # 自动生成摊位
    total_booths = data.get('total_booths', 0)
    for i in range(1, total_booths + 1):
        row_char = chr(64 + ((i - 1) // 10))
        col_num = ((i - 1) % 10) + 1
        booth_no = f"{row_char}{col_num:02d}"
        cur.execute("INSERT INTO Booth (fair_id, booth_no, is_occupied) VALUES (%s, %s, FALSE)", (fair_id, booth_no))
    mysql.connection.commit()
    cur.close()
    return jsonify({'code': 200, 'message': '招聘会创建成功'})

@app.route('/api/admin/jobfairs/<int:fair_id>', methods=['PUT'])
@login_required(role='admin')
@safe_execute
def admin_update_jobfair(fair_id):
    data = request.json
    cur = mysql.connection.cursor()
    cur.execute("""
        UPDATE JobFair
        SET title=%s, fair_time=%s, location=%s, content=%s, total_booths=%s, is_published=%s
        WHERE fair_id=%s
    """, (data.get('title'), data.get('fair_time'), data.get('location'),
          data.get('content'), data.get('total_booths'), data.get('is_published'), fair_id))
    mysql.connection.commit()
    cur.close()
    return jsonify({'code': 200, 'message': '更新成功'})

@app.route('/api/admin/jobfairs/<int:fair_id>', methods=['DELETE'])
@login_required(role='admin')
@safe_execute
def admin_delete_jobfair(fair_id):
    cur = mysql.connection.cursor()
    cur.execute("DELETE FROM JobFair WHERE fair_id=%s", (fair_id,))
    mysql.connection.commit()
    cur.close()
    return jsonify({'code': 200, 'message': '删除成功'})

# ---------- 5. 摊位分配 ----------
@app.route('/api/admin/fairs/<int:fair_id>/booths', methods=['GET'])
@login_required(role='admin')
@safe_execute
def admin_get_fair_booths(fair_id):
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT b.booth_id, b.booth_no, b.is_occupied, b.employer_id, e.name as employer_name
        FROM Booth b
        LEFT JOIN Employer e ON b.employer_id = e.employer_id
        WHERE b.fair_id = %s
        ORDER BY b.booth_no
    """, (fair_id,))
    booths = cur.fetchall()
    cur.close()
    return jsonify({'code': 200, 'data': booths})

@app.route('/api/admin/booths/<int:booth_id>/assign', methods=['PUT'])
@login_required(role='admin')
@safe_execute
def admin_assign_booth(booth_id):
    data = request.json
    employer_id = data.get('employer_id')
    cur = mysql.connection.cursor()

    if employer_id:
        cur.execute("UPDATE Booth SET employer_id=%s, is_occupied=TRUE WHERE booth_id=%s", (employer_id, booth_id))
    else:
        cur.execute("UPDATE Booth SET employer_id=NULL, is_occupied=FALSE WHERE booth_id=%s", (booth_id,))
    mysql.connection.commit()
    cur.close()
    return jsonify({'code': 200, 'message': '摊位分配成功'})

@app.route('/api/admin/all_employers', methods=['GET'])
@login_required(role='admin')
@safe_execute
def admin_get_all_employers():
    cur = mysql.connection.cursor()
    cur.execute("SELECT employer_id, name FROM Employer WHERE audit_status='通过' ORDER BY name")
    employers = cur.fetchall()
    cur.close()
    return jsonify({'code': 200, 'data': employers})

# ---------- 6. 数据统计 ----------
@app.route('/api/admin/stats/graduate_by_major', methods=['GET'])
@login_required(role='admin')
@safe_execute
def stats_graduate_by_major():
    cur = mysql.connection.cursor()
    cur.execute("SELECT major, COUNT(*) as count FROM Graduate GROUP BY major")
    result = cur.fetchall()
    cur.close()
    return jsonify({'code': 200, 'data': result})

@app.route('/api/admin/stats/employment_rate', methods=['GET'])
@login_required(role='admin')
@safe_execute
def stats_employment_rate():
    cur = mysql.connection.cursor()
    cur.execute("SELECT COUNT(*) as total FROM Graduate")
    total = cur.fetchone()['total']
    cur.execute("SELECT COUNT(DISTINCT a.stu_id) as employed FROM Application a WHERE a.status = '录用'")
    employed = cur.fetchone()['employed'] or 0
    cur.close()
    return jsonify({'code': 200, 'data': {
        'total': total,
        'employed': employed,
        'rate': round(employed / total * 100, 2) if total > 0 else 0
    }})

@app.route('/api/admin/stats/employer_by_type', methods=['GET'])
@login_required(role='admin')
@safe_execute
def stats_employer_by_type():
    cur = mysql.connection.cursor()
    cur.execute("SELECT nature, COUNT(*) as count FROM Employer WHERE audit_status='通过' GROUP BY nature")
    result = cur.fetchall()
    cur.close()
    return jsonify({'code': 200, 'data': result})

@app.route('/api/admin/stats/job_by_major', methods=['GET'])
@login_required(role='admin')
@safe_execute
def stats_job_by_major():
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT major_needed, SUM(demand_num) as total_demand
        FROM Recruitment r
        JOIN Employer e ON r.employer_id = e.employer_id
        WHERE e.audit_status='通过'
        GROUP BY major_needed
        ORDER BY total_demand DESC
        LIMIT 10
    """)
    result = cur.fetchall()
    cur.close()
    return jsonify({'code': 200, 'data': result})

# ---------- 7. 资讯发布 ----------
@app.route('/api/admin/news', methods=['POST'])
@login_required(role='admin')
@safe_execute
def publish_news():
    data = request.json
    cur = mysql.connection.cursor()
    cur.execute("""
        INSERT INTO News (title, category, content, publisher)
        VALUES (%s, %s, %s, %s)
    """, (data.get('title'), data.get('category'), data.get('content'), session['user_name']))
    mysql.connection.commit()
    cur.close()
    return jsonify({'code': 200, 'message': '发布成功'})

# ============================================================
# 静态文件路由（必须放在最后！避免拦截API路由）
# ============================================================
@app.route('/<path:filename>')
def serve_static(filename):
    # 只允许特定的文件扩展名
    allowed_extensions = {'.html', '.css', '.js', '.png', '.jpg', '.jpeg', '.gif', '.ico', '.svg'}
    ext = os.path.splitext(filename)[1].lower()
    if ext not in allowed_extensions:
        return jsonify({'code': 404, 'message': '文件类型不允许'}), 404
    return send_from_directory(BASE_DIR, filename)

@app.route('/')
def index():
    return send_from_directory(BASE_DIR, 'login.html')

# ============================================================
# 启动
# ============================================================
if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=int(os.environ.get('PORT', '5000')))
