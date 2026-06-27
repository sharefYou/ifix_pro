# رفع إصدار PHP إلى 8.3 ليتوافق مع متطلبات مشروعك
FROM php:8.3-cli

# تثبيت الحزم الأساسية وإضافة مكتبة libicu-dev المطلوبة لتشغيل intl
RUN apt-get update -y && apt-get install -y libmcrypt-dev unzip git libzip-dev libicu-dev

# تهيئة وتثبيت إضافات PHP المطلوبة (بما فيها intl)
RUN docker-php-ext-configure intl
RUN docker-php-ext-install pdo_mysql zip intl

# تثبيت Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# تحديد مجلد العمل
WORKDIR /app

# نسخ ملفات المشروع إلى السيرفر
COPY . /app

# تثبيت حزم لارافيل بنجاح بعد توفير المتطلبات
RUN composer install --no-dev --optimize-autoloader

# إعطاء الصلاحيات اللازمة لمجلدات التخزين
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache

# تحديد البورت وتشغيل المشروع
EXPOSE 8000
CMD php artisan serve --host=0.0.0.0 --port=8000