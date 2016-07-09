import os, sys
from django.core.wsgi import get_wsgi_application

sys.path.append(os.path.abspath(os.path.dirname(__file__)))
os.environ['DJANGO_SETTINGS_MODULE'] = 'webapp.settings'

application = get_wsgi_application()
