FROM php:8.2-cli

# تثبيت الحزم الأساسية لعمل النظام وقواعد البيانات
RUN apt-get update -y && apt-get install -y libmcrypt-dev unzip git libzip-dev
RUN docker-php-ext-install pdo_mysql zip

# تثبيت Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# تحديد مجلد العمل
WORKDIR /app

# نسخ ملفات المشروع إلى السيرفر
COPY . /app

# تثبيت حزم لارافيل
RUN composer install --no-dev --optimize-autoloader

# إعطاء الصلاحيات اللازمة لمجلدات التخزين
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache

# تحديد البورت وتشغيل المشروع
EXPOSE 8000
CMD php artisan serve --host=0.0.0.0 --port=8000