"""
Django settings for webapp project.

For more information on this file, see
https://docs.djangoproject.com/en/1.9/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.9/ref/settings/
"""

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
import os, json
DJ_PROJECT_DIR = os.path.dirname(__file__)
BASE_DIR = os.path.dirname(DJ_PROJECT_DIR)
WSGI_DIR = os.path.dirname(BASE_DIR)
REPO_DIR = os.path.dirname(WSGI_DIR)
DATA_DIR = os.environ.get('ENV_BASE_DATA_DIR', BASE_DIR)

# Ignore this:
# py.warnings - WARNING - /usr/lib/python2.7/site-packages/django/shortcuts.py:45: RemovedInDjango110Warning: The context_instance argument of render_to_string is deprecated.
#  using=using)
SILENCED_SYSTEM_CHECKS = ["1_8.W001"]

import sys

SECRET_KEY = "asvCA21Cdac32r32n9iun98c32in"
import sys
DJ_PROJECT_DIR = os.path.dirname(__file__)
BASE_DIR = "/opt/containerfiles/django/"
WSGI_DIR = "/opt/containerfiles/django/wsgi/"
REPO_DIR = "/opt/containerfiles/django/wsgi/"
DATA_DIR = os.environ.get('ENV_BASE_DATA_DIR', BASE_DIR)

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = os.environ.get('ENV_DJANGO_DEBUG_MODE') == 'True'

from socket import gethostname
ALLOWED_HOSTS = [
    gethostname(), 
    os.environ.get('ENV_BASE_DOMAIN'), 
    "0.0.0.0",
    "localhost",
    #'example.com', # First DNS alias (set up in the app)
    #'www.example.com', # Second DNS alias (set up in the app)
]

# For deploying locally without Docker and without uWSGI mode set this value to "DEV":
if os.environ.get("ENV_SERVER_MODE") == "DEV":
    BASE_DIR = "/opt/containerfiles/django/"
    WSGI_DIR = "../"
    REPO_DIR = "/opt/containerfiles/django/wsgi/"
    DATA_DIR = os.environ.get('ENV_BASE_DATA_DIR', BASE_DIR)
    DEBUG = True
    ALLOWED_HOSTS = [
        "0.0.0.0",
        "localhost",
    ]
# end of local vs inside docker

# Application definition

INSTALLED_APPS = (
    #'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
)

MIDDLEWARE_CLASSES = (
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

# GETTING-STARTED: change 'webapp' to your project name:
ROOT_URLCONF = 'webapp.urls'
BASE_DIR     = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) 
TEMPLATES    = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [
                    os.path.join(BASE_DIR, 'webapp/templates')
        ],
        'OPTIONS': {
            'loaders': [
                ('django.template.loaders.cached.Loader', [
                    'django.template.loaders.filesystem.Loader',
                    'django.template.loaders.app_directories.Loader',
                ]), 
            ],  
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.template.context_processors.debug',
                'django.template.context_processors.i18n',
                'django.template.context_processors.media',
                'django.template.context_processors.static',
                'django.template.context_processors.tz',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'webapp.wsgi.application'


# Database
# https://docs.djangoproject.com/en/1.9/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        # GETTING-STARTED: change 'db.sqlite3' to your sqlite3 database:
        'NAME': os.path.join(DATA_DIR, 'db.sqlite3'),
    }
}

# Internationalization
# https://docs.djangoproject.com/en/1.9/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.9/howto/static-files/
#
STATIC_URL              = '/static/'
# Deploy to Static Root:
STATIC_ROOT             = os.environ.get("ENV_STATIC_OUTPUT_DIR")
STATICFILES_DIRS = [
                        os.path.join(WSGI_DIR, 'static'),
]


MEDIA_URL               = '/media/'
MEDIA_ROOT              = os.environ.get("ENV_MEDIA_DIR")


TYPE_OF_SERVER          = "DEV"
SEND_EX_TO_SLACK        = os.environ.get("ENV_SEND_EX_TO_SLACK") == "True"
SESSION_COOKIE          = {}
META_PAGE_DATA          = {}
LOG_NAME                = TYPE_OF_SERVER
LOG_LEVEL               = "DEBUG"
LOGGING                 = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': LOG_NAME + " %(levelname)s [%(process)d]: %(message)s"
        },
        'simple': {
            'format': LOG_NAME + " %(levelname)s [%(process)d]: %(message)s"
        },
    },
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse',
        },
        'require_debug_true': {
            '()': 'django.utils.log.RequireDebugTrue',
        },
    },
    'handlers': {
        'console': {
            'level': 'INFO',
            'filters': ['require_debug_true'],
            'class': 'logging.StreamHandler',
        },
        'mail_admins': {
            'level': 'ERROR',
            'class': 'django.utils.log.AdminEmailHandler'
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console', 'mail_admins'],
            'level': 'INFO',
        },
        'core.handlers': {
            'level': 'INFO',
            'handlers': ['console']
        },
        'webapp': {
            'handlers': ['console'],
            'level': 'INFO',
        },
        'py.warnings': {
            'handlers': ['console'],
        },
    }
}

SITE_ID                     = 1
GA_TRACKING_CODE            = os.environ.get("ENV_GOOGLE_ANALYTICS_CODE")
META_DATA_SEO_FILE          = BASE_DIR + "/webapp/meta_data_seo.json"
META_DATA_SEO_JSON          = json.loads(open(META_DATA_SEO_FILE).read())
META_PAGE_DATA              = META_DATA_SEO_JSON["SEO"]
USE_THIS_SLACK_CONFIG       = {
                                "BotName"     : str(os.environ.get("ENV_SLACK_BOTNAME")),
                                "ChannelName" : str(os.environ.get("ENV_SLACK_CHANNEL")),
                                "NotifyUser"  : str(os.environ.get("ENV_SLACK_NOTIFY_USER")),
                                "Token"       : str(os.environ.get("ENV_SLACK_TOKEN")),
                                "EnvName"     : str(os.environ.get("ENV_SLACK_ENVNAME"))
                            }
