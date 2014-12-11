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
//= require turbolinks
//= require jquery
//= require jquery_ujs
//= require jquery.datetimepicker
//= require jquery.datetimepicker/init
//= require hoverIntent
//= require superfish
//= require bootstrap
//= require jquery.ui.all
//= require_self
//= require_tree .
//= require jquery.datetimepicker

$(document).on('ready page:load', function() {
  jQuery(this).trigger('turbo:ready');
});

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
  var inputs = document.getElementsByTagName('input');
  var index = 0;
  for(i = 0; i < inputs.length; i++){
    if(inputs[i].id.match("due_date")){
      if (inputs[i].value == "") {
        alert("Please specify a date for each deadline before continuing.")
          return false
      }
      else
        dates[index++] = inputs[i]	  	   	     	    
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

function addElement() {

  var ni = document.getElementById('extra_deadlines');
  var numReviews = document.getElementById('assignment_helper_no_of_reviews');
  if (numReviews.value>10 ||numReviews.value<=0 ||!numReviews.value.toString().match(/^[-]?\d*\.?\d*$/))
  {
    alert("Please enter a value between 1 to 10")
      numReviews.value=2
      addElement()
      return
  }
  var authHTML = "";
  //alert (numi.value);
  var limit=numReviews.value;
  var i;
  ni.innerHTML = "";
  var submission_var='';
  var rereview_var='';
  if(limit==2)
  {
    submission_var="Final submission deadline";
    rereview_var="Final review deadline";
  }
  //alert(limit)
  for(i=1;i<limit;i++)
  {
    //alert (ni.innerHTML);
    var j = i+1;

    if(limit>2)
    {
      submission_var= 'Re-submission-'+j+' deadline '
        rereview_var = 'Re-review-'+j+' deadline '
    }

    if (document.getElementById('add_submit_due_at_'+i) != null){
      var submit_due = document.getElementById('add_submit_due_at_'+i).value;
      var submit_id = document.getElementById('add_submit_id_'+i).value;

    }else{
      var submit_due = " " ;
      var submit_id = " ";

    }

    if (document.getElementById('add_review_due_at_'+i) != null){
      var review_due = document.getElementById('add_review_due_at_'+i).value;
      var review_id = document.getElementById('add_review_id_'+i).value;

    } else {
      var review_due = " ";
      var review_id = " ";
    }

    ni.innerHTML = ni.innerHTML +
      '<table class="exp">'+
      '<TR> <input type="hidden" id="additional_submit_deadline_'+j+'_id" name ="additional_submit_deadline['+j+'][id]" value='+submit_id+' >' +
      '<input type=hidden name="due_date[id]" value="" />' +
      '<input type=hidden name="due_date[late_policy_id]" value="" />' +
      '<input type=hidden name="due_date[round]" value=' + j + ' /> ' +
      '<input type=hidden name="due_date[deadline_type_id]" value=' + window['_deadline_type_submission'] + ' />' +
      '<TD ALIGN=LEFT WIDTH=20%> '+submission_var+' </TD>'+
      '<TD ALIGN=CENTER WIDTH=20%>' +
      '<input type="text" id="additional_submit_deadline_'+j+'_due_at" name ="additional_submit_deadline['+j+'][due_at]" value='+submit_due+' >' +
      '<img src="/assets/cal.gif" onClick=\"NewCal(\'additional_submit_deadline_'+j+'_due_at\',\'YYYYMMDD\',true,24); return false;">' +
      '</TD>'+


      '<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_submission_allowed_id" name ="additional_submit_deadline['+j+'][submission_allowed_id]">'+
      '<option id="sub_sa_select2_'+i+'" value=2>Late</option>' +
      '<option id="sub_sa_select1_'+i+'" value=1>No</option>'+
      '<option id="sub_sa_select3_'+i+'" value=3>OK</option>'+
      '</select></TD>'+

      '<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_review_allowed_id" name ="additional_submit_deadline['+j+'][review_allowed_id]">'+
      '<option id="sub_ra_select2_'+i+'" value=2>Late</option>' +
      '<option id="sub_ra_select1_'+i+'" value=1>No</option>' +
      '<option id="sub_ra_select3_'+i+'" value=3>OK</option>'+
      '</select></TD>'+

      '<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_resubmission_allowed_id" name ="additional_submit_deadline['+j+'][resubmission_allowed_id]">' +
      '<option id="sub_rsa_select2_'+i+'" value=2>Late</option>'+
      '<option id="sub_rsa_select1_'+i+'" value=1>No</option>' +
      '<option id="sub_rsa_select3_'+i+'" value=3>OK</option>'+
      '</select></TD>'+

      '<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_rereview_allowed_id" name ="additional_submit_deadline['+j+'][rereview_allowed_id]">'+
      '<option id="sub_rra_select2_'+i+'" value=2>Late</option>' +
      '<option id="sub_rra_select1_'+i+'" value=1>No</option>'+
      '<option id="sub_rra_select3_'+i+'" value=3>OK</option>'+
      '</select></TD>'+

      '<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_review_of_review_allowed_id" name ="additional_submit_deadline['+j+'][review_of_review_allowed_id]">'+
      '<option id="sub_ror_select2_'+i+'" value=2>Late</option>' +
      '<option id="sub_ror_select1_'+i+'" value=1>No</option>' +
      '<option id="sub_ror_select3_'+i+'" value=3>OK</option>'+
      '</select></TD>'+

      '<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_threshold" name ="additional_submit_deadline['+j+'][threshold]">'+
      '<option id="sub_th_select1_'+i+'" value="1">1</option>' +
      '<option id="sub_th_select2_'+i+'" value="2">2</option>' +
      '<option id="sub_th_select3_'+i+'" value="3">3</option>' +
      '<option id="sub_th_select4_'+i+'" value="4">4</option>' +
      '<option id="sub_th_select5_'+i+'" value="5">5</option>' +
      '<option id="sub_th_select6_'+i+'" value="6">6</option>' +
      '<option id="sub_th_select7_'+i+'" value="7">7</option>' +
      '<option id="sub_th_select8_'+i+'" value="8">8</option>' +
      '<option id="sub_th_select9_'+i+'" value="9">9</option>' +
      '<option id="sub_th_select10_'+i+'" value="10">10</option>' +
      '<option id="sub_th_select11_'+i+'" value="11">11</option>' +
      '<option id="sub_th_select12_'+i+'" value="12">12</option></select>'+
      '</select></TD>'+                     

      '</TR>'+


      '<TR> <input type="hidden" id="additional_review_deadline_'+j+'_id" name ="additional_review_deadline['+j+'][id]" value='+review_id+' >' +
      '<input type=hidden name="due_date[id]" value="" />' +
      '<input type=hidden name="due_date[late_policy_id]" value="" />' +
      '<input type=hidden name="due_date[round]" value=' + j + ' /> ' +
      '<input type=hidden name="due_date[deadline_type_id]" value=' + window['_deadline_type_review'] + ' />' +
      '<TD ALIGN=LEFT WIDTH=20%>'+rereview_var+'</TD>'+

      //'<TD ALIGN=CENTER WIDTH=5%><input type="text" id="additional_review_deadline_'+j+'_due_at" name ="additional_review_deadline['+j+'][due_at]" onClick="NewCal(\'additional_review_deadline_'+j+'_due_at\',\'YYYYMMDD\',true,24); return false;"/></TD>'+
      '<TD ALIGN=CENTER WIDTH=20%><input type="text" id="additional_review_deadline_'+j+'_due_at" name ="additional_review_deadline['+j+'][due_at]" value='+review_due+'>' +
      ' <img src="/assets/cal.gif" onClick=\"NewCal(\'additional_review_deadline_'+j+'_due_at\',\'YYYYMMDD\',true,24); return false;"></TD>'+

      '<TD ALIGN=CENTER WIDTH=10%><select id="additional_review_deadline_'+j+'_submission_allowed_id" name ="additional_review_deadline['+j+'][submission_allowed_id]">'+
      '<option id="rev_sa_select2_'+i+'" value=2>Late</option>' +
      '<option id="rev_sa_select1_'+i+'" value=1>No</option>'+
      '<option id="rev_sa_select3_'+i+'" value=3>OK</option>'+
      '</select></TD>'+

      '<TD ALIGN=CENTER WIDTH=10%><select id="additional_review_deadline_'+j+'_review_allowed_id" name ="additional_review_deadline['+j+'][review_allowed_id]">'+
      '<option id="rev_ra_select2_'+i+'" value=2>Late</option>' +
      '<option id="rev_ra_select1_'+i+'" value=1>No</option>' +
      '<option id="rev_ra_select3_'+i+'" value=3>OK</option>'+
      '</select></TD>'+

      '<TD ALIGN=CENTER WIDTH=10%><select id="additional_review_deadline_'+j+'_resubmission_allowed_id" name ="additional_review_deadline['+j+'][resubmission_allowed_id]">'+
      '<option id="rev_rsa_select2_'+i+'" value=2>Late</option>'+
      '<option id="rev_rsa_select1_'+i+'" value=1>No</option>' +
      '<option id="rev_rsa_select3_'+i+'" value=3>OK</option>'+
      '</select></TD>'+

      '<TD ALIGN=CENTER WIDTH=10%><select id="additional_review_deadline_'+j+'_rereview_allowed_id" name ="additional_review_deadline['+j+'][rereview_allowed_id]">'+
      '<option id="rev_rra_select2_'+i+'" value=2>Late</option>' +
      '<option id="rev_rra_select1_'+i+'" value=1>No</option>'+
      '<option id="rev_rra_select3_'+i+'" value=3>OK</option>'+
      '</select></TD>'+

      '<TD ALIGN=CENTER WIDTH=10%>'+
      '<select id="additional_review_deadline_'+j+'_review_of_review_allowed_id" name ="additional_review_deadline['+j+'][review_of_review_allowed_id]">'+
      '<option id="rev_ror_select2_'+i+'" value=2>Late</option>' +
      '<option id="rev_ror_select1_'+i+'" value=1>No</option>' +
      '<option id="rev_ror_select3_'+i+'" value=3>OK</option>'+
      '</select></TD>'+

      '<TD ALIGN=CENTER WIDTH=10%>'+
      '<select id="additional_review_deadline_'+j+'_threshold" name ="additional_review_deadline['+j+'][threshold]">'+
      '<option id="rev_th_select1_'+i+'" value="1">1</option>' +
      '<option id="rev_th_select2_'+i+'" value="2">2</option>' +
      '<option id="rev_th_select3_'+i+'" value="3">3</option>' +
      '<option id="rev_th_select4_'+i+'" value="4">4</option>' +
      '<option id="rev_th_select5_'+i+'" value="5">5</option>' +
      '<option id="rev_th_select6_'+i+'" value="6">6</option>' +
      '<option id="rev_th_select7_'+i+'" value="7">7</option>' +
      '<option id="rev_th_select8_'+i+'" value="8">8</option>' +
      '<option id="rev_th_select9_'+i+'" value="9">9</option>' +
      '<option id="rev_th_select10_'+i+'" value="10">10</option>' +
      '<option id="rev_th_select11_'+i+'" value="11">11</option>' +
      '<option id="rev_th_select12_'+i+'" value="12">12</option></select>'+
      '</select></TD>'+


      '</TR>'+
      '</table>';

    if (document.getElementById('add_submit_due_at_'+i) != null){
      var submit_submit_allowed =  document.getElementById('add_submit_submit_allowed_id_'+i).value;
      document.getElementById('sub_sa_select'+submit_submit_allowed+'_'+i).selected = true;

      var submit_review_allowed =  document.getElementById('add_submit_review_allowed_id_'+i).value;
      document.getElementById('sub_ra_select'+submit_review_allowed+'_'+i).selected = true;

      var submit_resubmit_allowed =  document.getElementById('add_submit_resubmit_allowed_id_'+i).value;
      document.getElementById('sub_rsa_select'+submit_resubmit_allowed+'_'+i).selected = true;

      var submit_rereview_allowed =  document.getElementById('add_submit_rereview_allowed_id_'+i).value;
      document.getElementById('sub_rra_select'+submit_rereview_allowed+'_'+i).selected = true;

      var submit_review_of_review_allowed =  document.getElementById('add_submit_review_of_review_allowed_id_'+i).value;
      document.getElementById('sub_ror_select'+submit_review_of_review_allowed+'_'+i).selected = true;

      var submit_threshold =  document.getElementById('add_submit_threshold_'+i).value;
      document.getElementById('sub_th_select'+submit_threshold+'_'+i).selected = true;

    }else{

      document.getElementById('sub_sa_select2_'+i).selected = true;
      document.getElementById('sub_ra_select2_'+i).selected = true;
      document.getElementById('sub_rsa_select3_'+i).selected = true;
      document.getElementById('sub_rra_select1_'+i).selected = true;
      document.getElementById('sub_ror_select1_'+i).selected = true;
      document.getElementById('sub_th_select1_'+i).selected = true;
    }

    if (document.getElementById('add_review_due_at_'+i) != null){
      var review_submit_allowed =  document.getElementById('add_review_submit_allowed_id_'+i).value;
      document.getElementById('rev_sa_select'+review_submit_allowed+'_'+i).selected = true;

      var review_review_allowed =  document.getElementById('add_review_review_allowed_id_'+i).value;
      document.getElementById('rev_ra_select'+review_review_allowed+'_'+i).selected = true;

      var review_resubmit_allowed =  document.getElementById('add_review_resubmit_allowed_id_'+i).value;
      document.getElementById('rev_rsa_select'+review_resubmit_allowed+'_'+i).selected = true;

      var review_rereview_allowed =  document.getElementById('add_review_rereview_allowed_id_'+i).value;
      document.getElementById('rev_rra_select'+review_rereview_allowed+'_'+i).selected = true;

      var review_review_of_review_allowed =  document.getElementById('add_review_review_of_review_allowed_id_'+i).value;
      document.getElementById('rev_ror_select'+review_review_of_review_allowed+'_'+i).selected = true;

      var review_threshold =  document.getElementById('add_review_threshold_'+i).value;
      document.getElementById('rev_th_select'+review_threshold+'_'+i).selected = true;

    }else{

      document.getElementById('rev_sa_select1_'+i).selected = true;
      document.getElementById('rev_ra_select2_'+i).selected = true;
      document.getElementById('rev_rsa_select2_'+i).selected = true;
      document.getElementById('rev_rra_select3_'+i).selected = true;
      document.getElementById('rev_ror_select1_'+i).selected = true;
      document.getElementById('rev_th_select1_'+i).selected = true;
    }
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
