# WordPress Docker Setup با IonCube و SFTP

یک راه‌حل حرفه‌ای Docker برای WordPress با پشتیبانی از:

- ✅ PHP 8.2
- ✅ IonCube Loader
- ✅ SFTP Access (atmoz/sftp)
- ✅ دیتابیس خارجی
- ✅ ابزارهای توسعه (wget, unzip, vim)
- ✅ مدیریت خودکار Permissions

## 📋 پیش‌نیازها

- Docker و Docker Compose نصب شده
- دسترسی به یک دیتابیس MySQL/MariaDB خارجی
- پورت‌های 80 و 2026 آزاد باشند (قابل تغییر در `.env`)

## 🚀 راه‌اندازی اولیه

### 1. کپی فایل Environment

```bash
cp .env.example .env
```

### 2. ویرایش فایل `.env`

فایل `.env` را با ویرایشگر دلخواه باز کنید و موارد زیر را تنظیم کنید:

#### اطلاعات دیتابیس خارجی

```env
WORDPRESS_DB_HOST=your-database-host.com:3306
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wp_user
WORDPRESS_DB_PASSWORD=your_secure_password
```

#### اطلاعات SFTP

```env
SFTP_USER=ftpuser
SFTP_PASSWORD=your_sftp_password
SFTP_PORT=2026
```

#### کلیدهای امنیتی WordPress

کلیدهای امنیتی را از این لینک دریافت کنید:
<https://api.wordpress.org/secret-key/1.1/salt/>

### 3. Build و اجرای کانتینرها

```bash
# Build کردن image
docker-compose build

# اجرای سرویس‌ها
docker-compose up -d
```

### 4. بررسی وضعیت سرویس‌ها

```bash
docker-compose ps
```

### 5. نصب WordPress

در مرورگر خود به آدرس زیر بروید:

```
http://localhost
```

یا آدرس دامنه/IP سرور خود را وارد کنید.

## 🔧 تنظیمات پیشرفته

### تغییر سطح دسترسی SFTP

فایل `docker-compose.yml` دو حالت دسترسی SFTP دارد:

#### حالت 1: دسترسی کامل (پیش‌فرض)

```yaml
volumes:
  - wordpress_data:/home/${SFTP_USER}/wordpress:rw
```

#### حالت 2: دسترسی محدود

برای محدود کردن دسترسی به `wp-content` و `wp-config.php`:

```yaml
volumes:
  - wordpress_data/wp-content:/home/${SFTP_USER}/wp-content:rw
  - wordpress_data/wp-config.php:/home/${SFTP_USER}/wp-config.php:rw
```

> **نکته:** برای اعمال تغییرات، سرویس SFTP را restart کنید:

```bash
docker-compose restart sftp
```

## 📁 اتصال به SFTP

### استفاده از FileZilla

```
Host: sftp://your-server-ip
Port: 2026
Username: ftpuser (مقدار SFTP_USER در .env)
Password: your_sftp_password (مقدار SFTP_PASSWORD در .env)
```

### استفاده از WinSCP

```
File protocol: SFTP
Host name: your-server-ip
Port number: 2026
User name: ftpuser
Password: your_sftp_password
```

### استفاده از خط فرمان (sftp)

```bash
sftp -P 2026 ftpuser@your-server-ip
```

## 🔍 دستورات مفید

### مشاهده لاگ‌ها

```bash
# همه سرویس‌ها
docker-compose logs -f

# فقط WordPress
docker-compose logs -f wordpress

# فقط SFTP
docker-compose logs -f sftp
```

### بررسی نصب IonCube

```bash
docker-compose exec wordpress php -v
```

خروجی باید شامل IonCube باشد:

```
with the ionCube PHP Loader + ionCube24...
```

### اجرای دستورات داخل WordPress container

```bash
# دسترسی به shell
docker-compose exec wordpress bash

# بررسی ابزارهای نصب شده
docker-compose exec wordpress which wget
docker-compose exec wordpress which unzip
docker-compose exec wordpress which vim
```

### تنظیم مجدد Permissions

```bash
docker-compose up permission-fixer
```

### Restart سرویس‌ها

```bash
# همه سرویس‌ها
docker-compose restart

# فقط WordPress
docker-compose restart wordpress

# فقط SFTP
docker-compose restart sftp
```

### توقف سرویس‌ها

```bash
# توقف بدون حذف volumes
docker-compose down

# توقف و حذف volumes (خطرناک - تمام داده‌ها حذف می‌شود!)
docker-compose down -v
```

## 🔒 نکات امنیتی

> [!WARNING]
> **نکات امنیتی مهم:**

1. **فایل `.env` را هرگز commit نکنید** - این فایل شامل اطلاعات حساس است
2. **رمزهای قوی استفاده کنید** - برای `SFTP_PASSWORD` و `WORDPRESS_DB_PASSWORD`
3. **کلیدهای یکتا استفاده کنید** - برای WordPress Security Keys
4. **محدود کردن دسترسی شبکه** - فقط IP‌های مورد اعتماد به SFTP دسترسی داشته باشند
5. **SSL/TLS برای HTTP** - در production از Traefik یا Nginx Proxy Manager استفاده کنید
6. **Backup منظم** - از دیتابیس و فایل‌های WordPress backup بگیرید

### استفاده با Dokploy و Traefik

این پروژه برای استفاده با Dokploy و Traefik بهینه شده است. Traefik مدیریت SSL/TLS را انجام می‌دهد.

## 🐛 عیب‌یابی

### مشکل در اتصال به دیتابیس

بررسی کنید:

1. اطلاعات دیتابیس در `.env` صحیح است
2. دیتابیس از IP سرور Docker قابل دسترسی است
3. User دیتابیس دسترسی‌های لازم را دارد

```bash
# تست اتصال
docker-compose exec wordpress mysql -h ${WORDPRESS_DB_HOST} -u ${WORDPRESS_DB_USER} -p${WORDPRESS_DB_PASSWORD}
```

### مشکل در اتصال SFTP

```bash
# بررسی لاگ SFTP
docker-compose logs sftp

# بررسی پورت
netstat -an | grep 2026
```

### مشکل در Permissions

```bash
# اجرای مجدد permission fixer
docker-compose up permission-fixer

# بررسی دستی permissions
docker-compose exec wordpress ls -la /var/www/html
```

### IonCube کار نمی‌کند

```bash
# بررسی نصب
docker-compose exec wordpress php -m | grep -i ioncube

# rebuild image
docker-compose build --no-cache wordpress
docker-compose up -d wordpress
```

## 📦 ساختار پروژه

```
wp-dockeriz/
├── Dockerfile              # Custom WordPress image با IonCube
├── docker-compose.yml      # تنظیمات سرویس‌ها
├── .env.example            # نمونه تنظیمات environment
├── .env                    # تنظیمات واقعی (git ignore)
├── .dockerignore           # فایل‌های ignore برای Docker
├── .gitignore              # فایل‌های ignore برای Git
└── README.md               # این فایل
```

## 📝 Volumes

- `wordpress_data`: تمام فایل‌های WordPress ذخیره می‌شوند

### Backup از Volume

```bash
# Backup
docker run --rm -v wp-dockeriz_wordpress_data:/data -v $(pwd):/backup ubuntu tar czf /backup/wordpress-backup.tar.gz /data

# Restore
docker run --rm -v wp-dockeriz_wordpress_data:/data -v $(pwd):/backup ubuntu tar xzf /backup/wordpress-backup.tar.gz -C /
```

## 🔄 به‌روزرسانی

```bash
# Pull آخرین تصویر WordPress
docker-compose pull wordpress

# Rebuild
docker-compose build --no-cache

# Restart با image جدید
docker-compose up -d
```

## 📞 پشتیبانی

برای مشکلات و سوالات:

- Issues را در مخزن Git ایجاد کنید
- مستندات WordPress: <https://wordpress.org/support/>
- مستندات Docker: <https://docs.docker.com/>

## 📄 مجوز

این پروژه برای استفاده آزاد است.

---

**ساخته شده با ❤️ برای توسعه‌دهندگان WordPress**
