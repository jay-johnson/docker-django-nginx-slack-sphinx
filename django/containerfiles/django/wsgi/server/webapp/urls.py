import os, glob

from django.conf.urls import patterns, include, url
from django.conf.urls import handler404
from django.conf import settings
from django.contrib import admin
from django.views.decorators.csrf import csrf_exempt
from django.views.generic import TemplateView, RedirectView
from django.conf.urls.static import static

from webapp import api

urlpatterns = [

    # Demo Site with Web interaction:
    url(r'^home/',          api.handle_home,                    name='home'),
    
    # Technical Docs:
    url(r'^slackerror/',    api.handle_show_slack_error,        name='slackerror'),
    
    # Technical Docs:
    url(r'^docs/',          api.handle_docs,                    name='docs'),

    # AJAX Server-side Processing URLs:
    url(r'^webapi/',        api.handle_ajax_request,            name="ajaxhandler"),

    # Sitemap:
    url(r'^sitemap\.xml$',  api.internal_sitemap_xml,           name="sitemapxml"),

    # Robots.txt:
    url(r'^robots\.txt$',   api.internal_robots_txt,            name="robotstxt"),

    # Catch all 404s:
    url(r'^.*/$',           RedirectView.as_view(url='/home/', permanent=False)),
    url(r'^$',              RedirectView.as_view(url='/home/', permanent=False)),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
