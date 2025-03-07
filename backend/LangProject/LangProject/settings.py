from pathlib import Path
import json
import os
from decouple import config
from datetime import timedelta


AUTHENTICATION_BACKENDS = [
    'django.contrib.auth.backends.ModelBackend',
]

SITE_ID = 1
REST_USE_JWT = True

# Email Configuration (Using Environment Variables for Security)
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = config('EMAIL_HOST_USER')  # Your Gmail address
EMAIL_HOST_PASSWORD = config('EMAIL_HOST_PASSWORD')  # Your Gmail app password
EMAIL_TIMEOUT = 10  # Prevent long waits
DEFAULT_FROM_EMAIL = EMAIL_HOST_USER  # Default sender email
ACCOUNT_EMAIL_VERIFICATION = 'mandatory'

PASSWORD_RESET_EMAIL_TEMPLATE = 'password_reset_confirm.html'

# Base Directory
BASE_DIR = Path(__file__).resolve().parent.parent

# Load config.json (if exists)
config_path = os.path.join(BASE_DIR, "config.json")
if os.path.exists(config_path):
    with open(config_path) as config_file:
        config = json.load(config_file)
else:
    config = {}

# Security and Debugging
SECRET_KEY = config.get("SECRET_KEY", "fallback-secret-key")
DEBUG = config.get("DEBUG", True)
ALLOWED_HOSTS = config.get("ALLOWED_HOSTS", ["127.0.0.1", "localhost","192.168.1.2"])

# Installed Applications
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'rest_framework_simplejwt',
    'LangApp',
    'corsheaders'
]

# Middleware
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'corsheaders.middleware.CorsMiddleware',
]

# CORS and CSRF Security
CORS_ALLOWED_ORIGINS = [
    'http://localhost:8000', 
    'http://10.10.11.100:8000',
    'http://192.168.1.3:8000'
]
CORS_ALLOW_CREDENTIALS = True  # Secure session handling

CSRF_COOKIE_SECURE = False  # Set to True for production with HTTPS
CSRF_COOKIE_HTTPONLY = True
CSRF_COOKIE_NAME = 'csrftoken'
SESSION_COOKIE_SECURE = True  # Secure session handling

ROOT_URLCONF = 'LangProject.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [os.path.join(BASE_DIR, 'templates')], 
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'LangProject.wsgi.application'

# Database Configuration
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': config.get("DB_NAME"),
        'USER': config.get("DB_USER"),
        'PASSWORD': config.get("DB_PASSWORD"),
        'HOST': config.get("DB_HOST"),
        'PORT': '3306',
    }
}

# Password Validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# Static Files
STATIC_URL = 'static/'

# Default Primary Key Type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Django REST Framework Authentication
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',
    ],
}

# JWT Token Configuration
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(days=1),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
}
