/**
* Script for managing events in review form page
* To be moved back here once the javascripts can be loaded to seperate pages, instead of globaly
**/

var vis = (function(){
    var stateKey, eventKey, keys = {
        hidden: "visibilitychange",
        webkitHidden: "webkitvisibilitychange",
        mozHidden: "mozvisibilitychange",
        msHidden: "msvisibilitychange"
    };
    for (stateKey in keys) {
        if (stateKey in document) {
            eventKey = keys[stateKey];
            break;
        }
    }
    return function(c) {
        if (c) document.addEventListener(eventKey, c);
        return !document[stateKey];
    }
})();

// AUTO SAVE: triggers every 60 seconds to save the draft version of the review
var interval = 60000
var last_save = new Date()
var autoSavePost = function() {
    //if it's was in the background, don't auto save to reduce bandwidth
    var autosave_cbx = document.getElementById("autosave_cbx");
    if(autosave_cbx){
        if(vis() && document.getElementById("autosave_cbx").checked) {
            executeSave();
        }
        setTimeout(autoSavePost, interval);
    }
};

function executeSave(){
    diff = (new Date().getTime() - last_save.getTime())/1000;
    // ignore saving unless the last save was more than 5s
    if (diff>5 && $('.review_form').length > 0) {
        $('form').attr('data-remote', 'true');
        document.getElementById('save_review').click();
        last_save = new Date;
        if ($('input[name=saved]').value = "0")$('input[name=saved]').val("1");
        $('form').removeAttr('data-remote');
    }
    $('#save_progress').html('<span id="tick"> &#10004; </span>' + 'Draft was saved at ' + last_save.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', second: 'numeric', hour12: true }));
}

jQuery(document).ready(function(){
    // workaround because all script are loaded in every pages now. need to clean it up
    if (document.title.indexOf("response") > -1){
        // start saving review every interval of time
        setTimeout(autoSavePost, interval);
        autosave_lbl = document.getElementById("autosave_cbx_lbl")
        if (autosave_lbl)
            autosave_lbl.innerHTML = "&nbsp;Auto save your respond every " + interval / 1000 + " seconds?&nbsp;&nbsp;"
        vis(function () {
            // save review when the window is sent to background
            if (!vis()) {
                executeSave();
            }
        });
    }
});
// END AUTO SAVE

// add star rating option to each dropdown box in review form
jQuery(document).ready(function($){
    $('.review-rating').each(function(index, el) {
        var $El;
        $El = $(el);
        $El.barrating({
            theme: 'fontawesome-stars',
            initialRating: $El.attr('data-current-rating'),
            showSelectedRating: true
        });
    });
});