# Create your views here.
from django.shortcuts import render_to_response
from django.template import RequestContext
from django.contrib import auth
from django.conf import settings
from django.template.context_processors import csrf
from django.shortcuts import render
from django.http import Http404
from django.http import HttpResponse
from django.http import HttpResponseRedirect
import json as simplejson

import urllib, urllib2, re, logging, json, uuid, ast, datetime, os.path
from   time   import time, sleep
from   datetime import timedelta
from   HTMLParser import HTMLParser

# Custom imports
from slack_messenger import SlackMessenger

# Setup logging
logging.basicConfig(level=logging.DEBUG, format='[%(asctime)s] %(levelname)s api - %(message)s', datefmt='%Y-%m-%d %H:%M:%S')

################################################################################################
#
# Django Helpers
#
################################################################################################


def lg(msg, level=6):
    if level == 0:
        logging.error(str(msg))
    else:
        logging.info(str(msg))
    return None
# end of lg
        
        
def process_exception(ex):
    if settings.SEND_EX_TO_SLACK:
        slack_msg = SlackMessenger(settings.USE_THIS_SLACK_CONFIG)
        slack_msg.handle_send_slack_internal_ex(ex)
        lg("Sent Slack Message", 0)
    else:
        lg("Hit Exception(" + str(ex) + ")", 0)
    return None
# end of process_exception


def build_def_result(status="FAILED", error="Not Asssigned", record={}):

    results = {
                "Status"    : status,
                "Error"     : error,
                "Record"    : record
            }
    return results
# end of build_def_result


################################################################################################
#
# Django Rendering Helper
#
################################################################################################


def shared_handle_render_to_response(request, short_name, normal_template, error_template, template_context):
    
    try:
        lg("Building Sharing Context", 6)
        context = build_shared_template_content(request, normal_template)
        lg("Returning Sharing Context", 6)
        return render_to_response(normal_template, context, context_instance=RequestContext(request))

    except Exception,k:
        lg("Failed to render response: " + str(k), 0)
        process_exception(k)
    # end of try/ex

    return None
# end of shared_handle_render_to_response


def build_shared_template_content(request, template):

    try:
        context = {
                    "ENV"               : settings.TYPE_OF_SERVER,
                    "GA_TRACKING_CODE"  : settings.GA_TRACKING_CODE
        }

        lg("Finding Meta(" + str(request.path) + ")", 6)
        if str(request.path) in settings.META_PAGE_DATA:
            for meta_name in settings.META_PAGE_DATA[str(request.path)]:
                context[str(meta_name)] = settings.META_PAGE_DATA[str(request.path)][str(meta_name)]
        # end of if this has seo meta data

        session_hash    = {}

        if str(settings.SESSION_COOKIE) == "{}":
            build_new_session(request, context, False)
        else:
            if str(settings.SESSION_COOKIE) in request.session and str(request.session[str(settings.SESSION_COOKIE)]) != "{}":
                try:
                    session_hash        = json.loads(request.session[str(settings.SESSION_COOKIE)])
                    return context
                except Exception,sess:
                    lg("Invalid Session(" + str(request.session[str(settings.SESSION_COOKIE)]) + ") Ex(" + str(sess) + ")", 0)
                    # end of trying to decode session
            # end of building the context for this user's identity for the template

        # end of if/else existing session to check

        return context
    except Exception,k:
        lg("Failed to build shared template content: " + str(k), 0)
        process_exception(k)
    # end of try/ex

    return None
# end of build_shared_template_content


################################################################################################
#
# Django Session Helpers
#
################################################################################################


def build_new_session(request, session_hash, debug=False):

    if debug:
        lg("New Session Values(" + str(request.session) + ")", 6)

    if str(settings.SESSION_COOKIE) in request.session:
    
        if debug:
            lg("Existing Session Cookie(" + str(request.session[settings.SESSION_COOKIE]) + ") Value(" + str(session_hash) + ")", 6)

        request.session[str(settings.SESSION_COOKIE)] = session_hash

        request.session.modified = True
        return True
    else:
        request.session[str(settings.SESSION_COOKIE)] = session_hash

        request.session.modified = True
        return True
    # end of Session Lite Checks

    return False
# end of build_new_session


################################################################################################
#
# Django URL Handlers
#
################################################################################################


def internal_sitemap_xml(request):
    return HttpResponse(open(str(settings.BASE_DIR) + "/webapp/sitemap.xml").read(), content_type='application/xhtml+xml')
# end of handle_sitemap_xml


def internal_robots_txt(request):
    return HttpResponse(open(str(settings.BASE_DIR) + "/webapp/robots.txt").read(), content_type='text/plain')
# end of handle_robots_txt


def handle_home(request):

    try:
        lg("Home", 6)

        # Change these for new URL Request Handlers:
        short_name                      = "Home"
        normal_template                 = str(settings.BASE_DIR) + "/webapp/templates/index.html"
        if_there_is_an_error_template   = str(settings.BASE_DIR) + "/webapp/templates/index.html"
        template_context                = {}

        return shared_handle_render_to_response(request, short_name, normal_template, if_there_is_an_error_template, template_context)

    except Exception,k:
        lg("ERROR: " + str(k), 0)
        process_exception(k)
    # end of try/ex

    return None
# end of handle_home


def handle_docs(request):

    try:
        lg("Docs Path(" + str(request.path) + ")", 6)

        # Change these for new URL Request Handlers:
        short_name                      = "Docs"
        normal_template                 = str(settings.BASE_DIR) + "/webapp/templates/docs.html"
        if_there_is_an_error_template   = str(settings.BASE_DIR) + "/webapp/templates/docs.html"
        template_context                = {}
        
        if str(request.path) != "/docs/":

            filename                    = str(str(request.path).split("/")[-1])
            normal_template             = str(settings.STATIC_ROOT) + "/" + str(request.path).split("/")[-2] + "/" + str(request.path).split("/")[-1]
            if os.path.exists(normal_template):
    
                if ".txt" in filename:
                    lg("Docs(" + str(request.path) + ") Text(" + str(normal_template) + ")", 6)
                    return HttpResponse(open(normal_template).read(), content_type='text/plain')
                else:
                    lg("Docs(" + str(request.path) + ") HTML(" + str(normal_template) + ")", 6)
            else:
                lg("Failed Doc Template(" + str(normal_template) + ")", 6)
                normal_template         = str(settings.BASE_DIR) + "/webapp/templates/" + str(request.path).split("/")[-1]
                lg("Fallback-Docs(" + str(request.path) + ") Template(" + str(normal_template) + ")", 6)
        # end of docs routing

        return shared_handle_render_to_response(request, short_name, normal_template, if_there_is_an_error_template, template_context)

    except Exception,k:
        lg("ERROR: " + str(k), 0)
        process_exception(k)
    # end of try/ex

    return None
# end of handle_docs


def handle_show_slack_error(request):

    try:
        lg("Slack Error Demo", 6)

        try:
            # Show the error in slack:
            here_is_an_error_on_this_line # This will throw a 'not defined' error
        except Exception,k:
            lg("ERROR: " + str(k), 0)
            process_exception(k)
        # end of try/ex

        lg("Done Slack Error Demo - Rerouting to Home for now", 6)
        return handle_home(request)

    except Exception,k:
        lg("ERROR: " + str(k), 0)
        process_exception(k)
    # end of try/ex

    return None
# end of handle_show_slack_error


################################################################################################
#
# Django Ajax Handler
#
################################################################################################


def handle_ajax_request(request):

    status      = "FAILED"
    err_msg     = "Nothing was processed"
    record      = {}
    results     = build_def_result(status, err_msg, record)

    try:

        ################################################################################################
        #
        # Ajax handlers:
        #
        if request.is_ajax():
            if request.method == "POST": 
                lg("Processing POST-ed AJAX", 6)
                status      = "SUCCESS"
                err_msg     = ""
                record      = {}

            elif request.method == "GET": 
                lg("Processing GET AJAX", 6)
                status      = "SUCCESS"
                err_msg     = ""
                record      = {}

            else:
                lg("Processing " + str(request.method) + ")", 6)
                status      = "SUCCESS"
                err_msg     = ""
                record      = {}
        else:
            lg("Invalid Ajax Request Sent to API", 0)
            status          = "Display Error"
            err_msg         = "Invalid Ajax Request Sent to API"
            record          = {}
        # end of valid ajax post/get/other 

        results     = build_def_result(status, err_msg, record)
    
    except Exception,k:
        err_msg     = "Failed to handle AJAX Request with Ex(" + str(k) + ")"
        lg(err_msg)
        process_exception(k)
        results     = build_def_result("Display Error", err_msg, record)
    # end of try/ex

    return results
# end of handle_ajax_request


