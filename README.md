# Tania - Farm Management System

![Tania](readme-assets/project-logo.png "Tania Logo")

[![Build Status](https://github.com/PreCogSecurity/tania/actions/workflows/ci.yml/badge.svg)](https://github.com/PreCogSecurity/tania/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![PHP Version](https://img.shields.io/badge/PHP-%3E%3D7.1-8892BF.svg)](https://php.net/)

Tania is a free and open source farming management system for everyone. You can manage your growing areas, reservoirs, farm tasks, inventories, and the crop growing progress.

It is developed on top of the Symfony PHP web framework.

## Architecture Overview

Tania follows a standard Symfony 3.4+ MVC architecture with the following components:

### Backend (PHP/Symfony)
- **Framework**: Symfony 3.3 LTS (planned upgrade to 4.4/5.4 LTS)
- **ORM**: Doctrine ORM 2.5+ with Doctrine Migrations
- **Authentication**: FOSUserBundle with bcrypt password hashing
- **Forms**: Symfony Form component with validation
- **Templating**: Twig
- **File Uploads**: VichUploaderBundle
- **Logging**: Monolog with configurable handlers

### Frontend
- **CSS Framework**: Bootstrap 3.3.7 with custom theme
- **JavaScript**: jQuery 3.1.1, Leaflet 1.1.0 for maps
- **MQTT Client**: Paho MQTT JavaScript client for IoT device communication
- **Charts**: Custom dashboard widgets

### Database
- **Primary**: MySQL 5.6+ / MariaDB 10.1+
- **Schema**: Managed via Doctrine Migrations

### Infrastructure
- **Containerization**: Docker with multi-stage build (PHP-FPM + Nginx)
- **Orchestration**: Docker Compose for development, Kubernetes-ready
- **CI/CD**: GitHub Actions with PHP linting, static analysis, security audit, and tests
- **Monitoring**: Health check endpoint at `/health`

## Requirements

- PHP >= 7.1 (7.4+ recommended)
- MySQL >= 5.6 or MariaDB >= 10.1
- Composer (install from [getcomposer.org](https://getcomposer.org))
- Node.js >= 18 (for frontend asset building)
- Docker (optional, for containerized deployment)

## Installation

### Traditional Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/PreCogSecurity/tania.git
   cd tania
   ```

2. Configure environment:
   ```bash
   cp .env-example .env
   # Edit .env with your database and mailer credentials
   ```

3. Install PHP dependencies:
   ```bash
   composer install --no-dev --optimize-autoloader
   ```

4. Install and build frontend assets:
   ```bash
   npm ci
   npm run build
   ```

5. Set up the database:
   ```bash
   php bin/console doctrine:migrations:migrate --no-interaction
   ```

6. Create an admin user:
   ```bash
   php bin/console fos:user:create admin admin@example.com securepassword --super-admin
   ```

7. Run the development server:
   ```bash
   php bin/console server:run
   ```

   Tania will run on `http://localhost:8000`.

### Docker Installation (Recommended for Production)

1. Clone and configure:
   ```bash
   git clone https://github.com/PreCogSecurity/tania.git
   cd tania
   cp .env-example .env
   # Edit .env with your configuration
   ```

2. Build and start:
   ```bash
   docker-compose up -d --build
   ```

3. Run migrations:
   ```bash
   docker-compose exec app php bin/console doctrine:migrations:migrate --no-interaction
   ```

4. Create admin user:
   ```bash
   docker-compose exec app php bin/console fos:user:create admin admin@example.com securepassword --super-admin
   ```

   Tania will be available at `http://localhost:8080`.

## Configuration

All configuration is managed through environment variables in `.env`. See `.env-example` for all available options.

### Key Configuration Options

| Variable | Description | Default |
|----------|-------------|---------|
| `SYMFONY_ENV` | Environment (dev/prod/test) | `dev` |
| `SYMFONY_SECRET` | Secret key for CSRF, encryption | **Required** |
| `SYMFONY_DB_HOST` | Database host | `127.0.0.1` |
| `SYMFONY_DB_PORT` | Database port | `3306` |
| `SYMFONY_DB_NAME` | Database name | **Required** |
| `SYMFONY_DB_USERNAME` | Database username | **Required** |
| `SYMFONY_DB_PASSWORD` | Database password | **Required** |
| `MAPBOX_ACCESS_TOKEN` | Mapbox token for map tiles | **Required for maps** |
| `SYMFONY_MAILER_*` | Mailer configuration | See `.env-example` |

### Security Recommendations

1. **Always use a strong `SYMFONY_SECRET`** in production (generate with `openssl rand -hex 32`)
2. **Use environment-specific `.env` files** (`.env.prod`, `.env.local`)
3. **Enable HTTPS** in production via reverse proxy (Nginx/Traefik)
4. **Restrict database access** to application servers only
5. **Rotate credentials regularly** and use secrets management in production

## Development

### Code Quality Tools

```bash
# PHP linting (PSR-12)
vendor/bin/phpcs --standard=phpcs.xml src

# PHP static analysis
vendor/bin/phpstan analyse --configuration=phpstan.neon

# JavaScript linting
npm run lint:js

# Auto-fix JavaScript issues
npm run lint:js:fix
```

### Running Tests

```bash
# PHP unit tests
vendor/bin/phpunit --configuration phpunit.xml.dist

# With coverage
vendor/bin/phpunit --coverage-html coverage
```

### Database Migrations

```bash
# Generate new migration
php bin/console doctrine:migrations:generate

# Run migrations
php bin/console doctrine:migrations:migrate

# Rollback last migration
php bin/console doctrine:migrations:migrate prev
```

## API & IoT Integration

Tania supports IoT device integration via MQTT:

- **MQTT Broker**: Configure host/port in settings
- **Device Topics**: `tania/{resource_id}` for sensor data
- **Dashboard**: Real-time sensor visualization on dashboard

## Deployment

### Production Checklist

- [ ] Set `SYMFONY_ENV=prod`
- [ ] Generate strong `SYMFONY_SECRET`
- [ ] Configure production database credentials
- [ ] Set up HTTPS/TLS termination
- [ ] Configure mail delivery (SMTP)
- [ ] Set up log aggregation
- [ ] Configure backup strategy for database
- [ ] Set up monitoring/alerting on `/health` endpoint
- [ ] Run `composer install --no-dev --optimize-autoloader`
- [ ] Clear and warm cache: `php bin/console cache:clear --env=prod`

### Docker Production Deployment

```bash
# Build production image
docker build -t tania:latest .

# Run with docker-compose (production override)
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Run code quality checks (`vendor/bin/phpcs`, `vendor/bin/phpstan`, `npm run lint:js`)
4. Write tests for new functionality
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Coding Standards

- PHP: PSR-12 (enforced via PHP_CodeSniffer)
- PHP: PHPStan Level 5 static analysis
- JavaScript: Airbnb Base (enforced via ESLint)
- Git: Conventional Commits

## Security

If you discover a security vulnerability, please report it privately to **security@precogsecurity.com**. Do not open public issues for security vulnerabilities.

### Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x     | ✅ Active |
| < 1.0   | ❌ End of Life |

## License

Tania is available under the Apache 2.0 open source license. See [LICENSE](LICENSE) for details.

## Maintainers

- PreCog Security Team - [GitHub](https://github.com/PreCogSecurity)

## Acknowledgments

- Original Tania project by [Tanibox](https://github.com/Tanibox)
- Symfony Framework
- All open source contributors