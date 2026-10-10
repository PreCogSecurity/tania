# Tania - Farm Management System
# Multi-stage Docker build for production deployment

# Build stage
FROM php:8.1-fpm-alpine AS builder

# Install system dependencies
RUN apk add --no-cache \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    icu-dev \
    oniguruma-dev \
    postgresql-dev \
    mysql-client \
    nodejs \
    npm

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    zip \
    gd \
    intl \
    opcache \
    bcmath \
    mbstring

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy composer files first for better caching
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts

# Copy application source
COPY . .

# Run composer scripts
RUN composer run-script post-install-cmd

# Install and build frontend assets
RUN npm ci && npm run build 2>/dev/null || true

# Production stage
FROM php:8.1-fpm-alpine AS production

# Install runtime dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    libzip \
    libpng \
    libjpeg-turbo \
    freetype \
    icu \
    oniguruma \
    postgresql-libs \
    mysql-client \
    tzdata

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    zip \
    gd \
    intl \
    opcache \
    bcmath \
    mbstring

# Configure PHP
COPY docker/php.ini /usr/local/etc/php/conf.d/tania.ini
COPY docker/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Configure Nginx
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx-site.conf /etc/nginx/conf.d/default.conf

# Configure Supervisor
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create application user
RUN addgroup -g 1000 -S tania \
    && adduser -u 1000 -S tania -G tania

# Set working directory
WORKDIR /app

# Copy application from builder
COPY --from=builder --chown=tania:tania /app /app

# Create necessary directories
RUN mkdir -p /app/var/cache /app/var/logs /app/var/sessions /app/web/uploads \
    && chown -R tania:tania /app/var /app/web/uploads

# Switch to non-root user
USER tania

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]