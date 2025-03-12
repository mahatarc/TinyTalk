from pathlib import Path
import json
import os
from decouple import config
from datetime import timedelta

# Base Directory
BASE_DIR = Path(__file__).resolve().parent.parent

# Load config.json (if exists)
config_path = os.path.join(BASE_DIR, "config.json")
if os.path.exists(config_path):
    with open(config_path) as config_file:
        config_data = json.load(config_file)
else:
    config_data = {}
    
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


# Security and Debugging
SECRET_KEY = config_data.get("SECRET_KEY", "fallback-secret-key")
DEBUG = config_data.get("DEBUG", True)
ALLOWED_HOSTS = config_data.get("ALLOWED_HOSTS")

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


# Get allowed IPs for CORS and CSRF
IP_ADDRESSES = config_data["ALLOWED_HOSTS"]
CSRF_TRUSTED_ORIGINS = [f"http://{ip}:8000" for ip in IP_ADDRESSES]
CORS_ALLOWED_ORIGINS = CSRF_TRUSTED_ORIGINS

CORS_ALLOW_CREDENTIALS = True  # Secure session handling

#CSRF_COOKIE_SECURE = True  # Prevent CSRF attacks
CSRF_COOKIE_SECURE = False  # Set to True in production
CSRF_USE_SESSIONS = False
SESSION_COOKIE_SECURE = True  # Secure session handling

ROOT_URLCONF = 'LangProject.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],  # Add this line
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

        'NAME': config_data.get('DB_NAME'),
        'HOST': config_data.get('DB_HOST'),
        'USER': config_data.get('DB_USER'),
        'PASSWORD': config_data.get('DB_PASSWORD'),
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