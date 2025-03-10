// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require components
//= require jquery
//= require jquery-bar-rating/jquery.barrating
//= require jquery-colorbox
//= require jquery.colorbox
//= require jquery.datetimepicker
//= require jquery.datetimepicker/init
//= require jquery-tablesorter
//= require jquery.ui.all
//= require jquery_ujs
//= require react
//= require react_ujs
//= require react-simpletabs
//= require sisyphus
//= require_self
//= require_tree .
//= require Chart.min
//= require moment
//= require bootstrap-datetimepicker
// Eliminate the “element.dispatchEvent is not a function” error

jQuery.noConflict();

function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.substring(1).toLowerCase();
}

function checkForm()
{
  return checkWeights(); // && checkDeadlines();
}

function checkWeights()
{
  var reviewWeight = document.getElementById('weights_review').value
    var metareviewWeight = document.getElementById('weights_metareview').value
    var feedbackWeight = document.getElementById('weights_feedback').value
    var teammateWeight = document.getElementById('weights_teammate').value
    var bookmarkratingWeight = document.getElementById('weights_bookmarkrating').value
    var total = parseFloat(reviewWeight) + parseFloat(metareviewWeight) + parseFloat(feedbackWeight) + parseFloat(teammateWeight) + parseFloat(bookmarkratingWeight)
    if (total == 100) return true
    else {
      alert ("The total of the weights given to an assignment must equal 100%. Your total weight percentage is "+total+"%.")
        return false	   
    }
}	   

function getDate(invar)
{	
  var year = parseInt(invar.value.substring(0,4));
  var month = parseInt(invar.value.substring(5,7));
  var day = parseInt(invar.value.substring(8,10));

  var hour = parseInt(invar.value.substring(11,13));
  var minute = parseInt(invar.value.substring(14,16));
  var second = parseInt(invar.value.substring(17,19));

  var date = new Date();	
  date.setFullYear(year,month,day);
  date.setHours(hour,minute,second);
  return date
}	

function checkDeadlines()
{

  var dates = new Array();
  var array = document.getElementsByTagName('input');
  var index = 0;
  for(i = 0; i < array.length; i++){
    if(array[i].id.match("due_date")){
      if (array[i].value == "") {
        alert("Please specify a date for each deadline before continuing.")
          return false
      }
      else
        dates[index++] = array[i]	  	   	     	    
    }
  }

  for(i = 0; i < dates.length-1; i++){
    var date1 = getDate(dates[i]);
    var date2 = getDate(dates[i+1]);

    var error = false;
    if (date1 >= date2) error = true;		
    if (error) alert("At least one set of deadlines occur out of chronological order. Please correct this and try again.")
      return !error		
  }
}

function updateDropDownMenu(advice,question,min){			
  var id = 'responses_' + question + '_score'			
    document.getElementById(id).selectedIndex = advice - min
}

function toggleVis(id) {
  var elem = document.getElementById(id + "_myDiv");
  if (elem.style.display == 'none') {
    elem.style.display = '';
    document.getElementById(id + "_show").style.display = 'none';
    document.getElementById(id + "_hide").style.display = '';
  } else {
    elem.style.display = 'none';
    document.getElementById(id + "_show").style.display = '';
    document.getElementById(id + "_hide").style.display = 'none';
  }
}

/*
 * Date Format 1.2.3
 * (c) 2007-2009 Steven Levithan <stevenlevithan.com>
 * MIT license
 *
 * Includes enhancements by Scott Trenda <scott.trenda.net>
 * and Kris Kowal <cixar.com/~kris.kowal/>
 *
 * Accepts a date, a mask, or a date and a mask.
 * Returns a formatted version of the given date.
 * The date defaults to the current date/time.
 * The mask defaults to dateFormat.masks.default.
 */

var dateFormat = function () {
  var	token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,
      timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,
      timezoneClip = /[^-+\dA-Z]/g,
      pad = function (val, len) {
        val = String(val);
        len = len || 2;
        while (val.length < len) val = "0" + val;
        return val;
      };

  // Regexes and supporting functions are cached through closure
  return function (date, mask, utc) {
    var dF = dateFormat;

    // You can't provide utc if you skip other args (use the "UTC:" mask prefix)
    if (arguments.length == 1 && Object.prototype.toString.call(date) == "[object String]" && !/\d/.test(date)) {
      mask = date;
      date = undefined;
    }

    // Passing date through Date applies Date.parse, if necessary
    date = date ? new Date(date) : new Date;
    if (isNaN(date)) throw SyntaxError("invalid date");

    mask = String(dF.masks[mask] || mask || dF.masks["default"]);

    // Allow setting the utc argument via the mask
    if (mask.slice(0, 4) == "UTC:") {
      mask = mask.slice(4);
      utc = true;
    }

    var	_ = utc ? "getUTC" : "get",
        d = date[_ + "Date"](),
        D = date[_ + "Day"](),
        m = date[_ + "Month"](),
        y = date[_ + "FullYear"](),
        H = date[_ + "Hours"](),
        M = date[_ + "Minutes"](),
        s = date[_ + "Seconds"](),
        L = date[_ + "Milliseconds"](),
        o = utc ? 0 : date.getTimezoneOffset(),
        flags = {
          d:    d,
          dd:   pad(d),
          ddd:  dF.i18n.dayNames[D],
          dddd: dF.i18n.dayNames[D + 7],
          m:    m + 1,
          mm:   pad(m + 1),
          mmm:  dF.i18n.monthNames[m],
          mmmm: dF.i18n.monthNames[m + 12],
          yy:   String(y).slice(2),
          yyyy: y,
          h:    H % 12 || 12,
          hh:   pad(H % 12 || 12),
          H:    H,
          HH:   pad(H),
          M:    M,
          MM:   pad(M),
          s:    s,
          ss:   pad(s),
          l:    pad(L, 3),
          L:    pad(L > 99 ? Math.round(L / 10) : L),
          t:    H < 12 ? "a"  : "p",
          tt:   H < 12 ? "am" : "pm",
          T:    H < 12 ? "A"  : "P",
          TT:   H < 12 ? "AM" : "PM",
          Z:    utc ? "UTC" : (String(date).match(timezone) || [""]).pop().replace(timezoneClip, ""),
          o:    (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4),
          S:    ["th", "st", "nd", "rd"][d % 10 > 3 ? 0 : (d % 100 - d % 10 != 10) * d % 10]
        };

    return mask.replace(token, function ($0) {
      return $0 in flags ? flags[$0] : $0.slice(1, $0.length - 1);
    });
  };
}();

// Some common format strings
dateFormat.masks = {
  "default":      "ddd mmm dd yyyy HH:MM:ss",
  shortDate:      "m/d/yy",
  mediumDate:     "mmm d, yyyy",
  longDate:       "mmmm d, yyyy",
  fullDate:       "dddd, mmmm d, yyyy",
  shortTime:      "h:MM TT",
  mediumTime:     "h:MM:ss TT",
  longTime:       "h:MM:ss TT Z",
  isoDate:        "yyyy-mm-dd",
  isoTime:        "HH:MM:ss",
  isoDateTime:    "yyyy-mm-dd'T'HH:MM:ss",
  isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"
};

// Internationalization strings
dateFormat.i18n = {
  dayNames: [
    "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat",
  "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
    ],
  monthNames: [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
  "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
    ]
};

// For convenience...
Date.prototype.format = function (mask, utc) {
  return dateFormat(this, mask, utc);
};

function show_alert(alertMessage){
    $("#dialog-message").html(alertMessage);
    $("#dialog-message").dialog({
        modal: true,
        draggable: true,
        resizable: true,
        position: ['center', 'center'],
        show: 'blind',
        hide: 'blind',
        width: 400,
        dialogClass: 'ui-dialog-osx',
        buttons: {
            "Ok": function() {
                $(this).dialog("close");
            }
        }
    });
}


/*
Files I've removed for which I couldn't find any use:
  1.  hoverIntent
  2.  superfish
  3.  awesomplete
  4.  bootstrap-sass/assets/javascripts/bootstrap-sprockets
  5.  tinymce-jquery
  6.  awesome_input
If at any point of time the application does not renders required page correctly, open the console and see if the above files 
are what causing the error. I might have also messed up the ordering of the files listed above (they are processed in top to down
. If that is the case, update the ordering and/or add as follows at the requires on the top of page.
"//= require filename"

Naman Shrimali <namanshrimali@gmail.com>
*/