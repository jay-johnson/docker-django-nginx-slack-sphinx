url_addr        = "/webapi/";
debug_jobs      = true;
debug_ajax_res  = false;

////////////////////////////
//
// Common Methods
//
// logger function:
function lg(msg, lt)
{
    if (lt == 0)
    {
        console.error(msg);
    }
    else if (lt == 1)
    {
        console.warn(msg);
    }
    else if (lt == 2)
    {
        console.info(msg);
    }
    else
    {
        console.log(msg);
    }
} // end of lg


////////////////////////////////////////////////////////
//
// Class Event Helpers
//
function on_ready_page_method()
{
    // Define html elements that you want to handle js events:

    // Set the 'Run Ajax Demo' button to the js function
    addClassEvent("ajax-run-demo", "click", ajax_run_demo,   false, true);
    
    // Set the 'Run Error Demo' button to the js function
    addClassEvent("ajax-err-demo", "click", ajax_error_demo, false, true);

} // end of on_ready_page_method

function addEvent(element, eventType, handler) {
    return ((element.attachEvent) ? element.attachEvent('on' + eventType, handler) : element.addEventListener(eventType, handler, false));
} // end of addEvent

function removeEvent(element, eventType, handler) {
    if (element.removeEventListener) {
        element.removeEventListener(eventType, handler, false);
    } else if (element.detachEvent) {
        element.detachEvent("on" + eventType, handler);
    } else {
        element["on" + eventType] = null;
    }
} // end of removeEvent

function addClassEvent(classname, eventType, handler, bubble, reset_first)
{
    if (reset_first)
    {
        $("." + classname).each(function(j) {
            removeEvent(this, eventType, handler);
            addEvent(this, eventType, handler, bubble);
        });
    }
    else
    {
        $("." + classname).each(function(j) {
            addEvent(this, eventType, handler, bubble);
        });
    }

} // end of addClassEvent

function removeClassEvent(classname, eventType, handler)
{
    $("." + classname).each(function(j) {
        removeEvent(this, eventType, handler);
    });

} // end of removeClassEvent


////////////////////////////////////////////////////////
//
// Ajax Helpers
//

// User Logout Handler
function user_logout_method()
{
    lg("Handle User Logout");
} // end of user_logout_method

function create_spinner(msg)
{
    return "<div class='row'><div class='col-lg-12 col-md-12 col-sm-12 col-xs-12'>" + msg + " <i class='fa fa-spin fa-circle-o-notch fa-1x'></i></div></div>";
} // end create_spinner

// Shared Ajax POST function
function handle_job_request(job_payload, success_cb, disp_error_cb, gen_error_cb, completion_cb, status_message)
{
    results = {}
    if (debug_jobs)
    {
        lg("Job(" + job_payload["Action"] + ")");
    }

    if (status_message != "")
    {
        $("." + job_payload["StatusDiv"]).html(create_spinner(status_message));
    }

    xhr = $.ajax({
                type: 'POST',
                url: url_addr,
                data: JSON.stringify(job_payload),
                beforeSend: function(xhr, settings) {
                    function getCookie(name) {
                        var cookieValue = null;
                        if (document.cookie && document.cookie != '') {
                            var cookies = document.cookie.split(';');
                            for (var i = 0; i < cookies.length; i++) {
                                var cookie = jQuery.trim(cookies[i]);
                                // Does this cookie string begin with the name we want?
                                if (cookie.substring(0, name.length + 1) == (name + '=')) {
                                    cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                                    break;
                                }
                            }
                        }
                        return cookieValue;
                    } // end getCookie

                    if (!(/^http:.*/.test(settings.url) || /^https:.*/.test(settings.url))) {
                        // Only send the token to relative URLs i.e. locally.
                        xhr.setRequestHeader("X-CSRFToken", getCookie('csrftoken'));
                    }
                },
                success: function(results, textStatus, jqXHR){

                    if (debug_ajax_res)
                    {
                        lg("- Handler Results: " + results.Status + " and Error: " + results.Error + " Status: " + textStatus);
                    }
                    if (results.Status == "SUCCESS")
                    {
                        success_cb(results.Record);
                    }
                    else if (results.Status == "Display Error")
                    {
                        disp_error_cb(results.Record);
                    }
                    // Useful for sites needing login-required access
                    else if (results.Status == "User not Logged in")
                    {
                        user_logout_method();
                    }
                    else
                    {
                        // This can return html so only turn it on when debugging
                        if (debug_jobs)
                        {
                            gen_error_cb(results);
                        }
                    }
                },
                complete: function(){
                    $("." + job_payload["StatusDiv"]).html("");
                    completion_cb(job_payload);
                    return;
                }
    }); // end AJAX Request
} // end of handle_job_request

// Necessary for Django to prevent CSRF errors
function prepare_for_ajax() {
    $.ajaxSetup({
        beforeSend: function(xhr, settings) {
            function getCookie(name) {
                var cookieValue = null;
                if (document.cookie && document.cookie != '') {
                     var cookies = document.cookie.split(';');
                     for (var i = 0; i < cookies.length; i++) {
                        var cookie = jQuery.trim(cookies[i]);
                        // Does this cookie string begin with the name we want?
                        if (cookie.substring(0, name.length + 1) == (name + '=')) {
                            cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                            break;
                        }
                    }
                }
                return cookieValue;
            } // end getCookie

            if (!(/^http:.*/.test(settings.url) || /^https:.*/.test(settings.url))) {
                // Only send the token to relative URLs i.e. locally.
                xhr.setRequestHeader("X-CSRFToken", getCookie('csrftoken'));
                lg("CSRF Token: " + getCookie('csrftoken'), 6);
            }
        } // end beforeSend

    }); // end ajaxSetup
} // end of prepare_for_ajax

// On Document 'Ready' 
$(document).ready(function() {

    // Prepare for ajax
    prepare_for_ajax();

    // Assign JS Events:
    on_ready_page_method();
}); // end of on document ready


////////////////////////////
//
// Custom Ajax Methods
//
function ajax_run_demo()
{
    target_json     = {
                        "SendToServer"  : "Hello World"
                    };
    proc_status_msg = "Running Ajax Demo";
    var job_payload = {
        "Action"    : "AjaxDemo",
        "Data"      : JSON.stringify(target_json),
        "StatusDiv" : "ajax-run-demo-status",
        "ResultDiv" : "ajax-run-demo-results",
    };

    function handle_success(results)
    {
        if (debug_jobs)
        {
            lg("Success: " + JSON.stringify(results), 6);
            lg(results, 6);
        }
        response  = results.ResData.Response;
        rs_div    = results.ResultDiv;

        if (debug_jobs)
        {
            lg("Updating Div(" + rs_div + ") with Response(" + response + ")", 6);
        }
        // Show the result in the browser
        $("." + rs_div).html(response).removeClass("error-field");
    } // end of test_success

    function handle_display_error(results)
    {
        lg("Display Error: " + JSON.stringify(results), 0);

        response  = results.ResData.Response;
        rs_div    = results.ResultDiv;

        if (debug_jobs)
        {
            lg("Updating Div(" + rs_div + ") with Response(" + response + ")", 6);
        }
        // Show the result in the browser
        $("." + rs_div).html(response).addClass("error-field");
    } // end of handle_display_error

    function handle_general_error(results)
    {
        lg("General Error: " + JSON.stringify(results), 0);
    } // end of handle_display_error

    function handle_completion(job_payload)
    {
        if (debug_jobs)
        {
            lg("Completed(" + job_payload["Action"] + ")");
        }
    } // end of handle_completion

    // POST Job:
    handle_job_request(job_payload, handle_success, handle_display_error, handle_general_error, handle_completion, proc_status_msg);

} // end of ajax_run_demo

function ajax_error_demo()
{
    target_json     = {
                        "TheServerDoesNotSupportThisKey"  : "Hello World"
                    };

    proc_status_msg = "Running Error Demo";
    var job_payload = {
        "Action"    : "AjaxDemo",
        "Data"      : JSON.stringify(target_json),
        "StatusDiv" : "ajax-err-demo-status",
        "ResultDiv" : "ajax-err-demo-results",
    };

    function handle_success(results)
    {
        if (debug_jobs)
        {
            lg("Success: " + JSON.stringify(results), 6);
            lg(results, 6);
        }
        response  = results.ResData.Response;
        rs_div    = results.ResultDiv;

        if (debug_jobs)
        {
            lg("Updating Div(" + rs_div + ") with Response(" + response + ")", 6);
        }
        // Show the result in the browser
        $("." + rs_div).html(response).removeClass("error-field");
    } // end of test_success

    function handle_display_error(results)
    {
        lg("Display Error: " + JSON.stringify(results), 0);

        response  = results.ResData.Response;
        rs_div    = results.ResultDiv;

        if (debug_jobs)
        {
            lg("Updating Div(" + rs_div + ") with Response(" + response + ")", 6);
        }
        // Show the result in the browser
        $("." + rs_div).html(response).addClass("error-field");
    } // end of handle_display_error

    function handle_general_error(results)
    {
        lg("General Error: " + JSON.stringify(results), 0);
    } // end of handle_display_error

    function handle_completion(job_payload)
    {
        if (debug_jobs)
        {
            lg("Completed(" + job_payload["Action"] + ")");
        }
    } // end of handle_completion


    // POST Job:
    handle_job_request(job_payload, handle_success, handle_display_error, handle_general_error, handle_completion, proc_status_msg);

} // end of ajax_error_demo

