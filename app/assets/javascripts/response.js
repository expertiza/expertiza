/**
* Script for managing events in review form page
*
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

// triggers in every 10 seconds to save the draft version of the review
var interval = 90000
var autoSavePost = function() {
    var dt, time;
    dt = new Date;
    time = dt.getHours() + ':' + dt.getMinutes() + ':' + dt.getSeconds();

    //if it's was in the background, don't autosae to save bandwi
    if(vis() && document.getElementById("autosave_cbx").checked) {
        if ($('.review_form').length > 0) {
            $('form').attr('data-remote', 'true');
            document.getElementById('save_review').click();
            if ($('input[name=saved]').value = "0")$('input[name=saved]').val("1");
            $('form').removeAttr('data-remote');
        }
        $('#save_progress').html('<span id="tick"> &#10004; </span>' + 'Draft Autosaved at ' + time);
    }
    setTimeout(autoSavePost, interval);
};

jQuery(document).ready(function(){setTimeout(autoSavePost, interval)});

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

