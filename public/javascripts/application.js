// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
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
	
	var total = parseFloat(reviewWeight) + parseFloat(metareviewWeight) + parseFloat(feedbackWeight) + parseFloat(teammateWeight)
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
  	ni.innerHTML = ni.innerHTML + 
  	                    '<TR><TD ALIGN=LEFT WIDTH=20%> '+submission_var+' </TD>'+
  	                    '<TD ALIGN=CENTER WIDTH=20%><input type="text" id="additional_submit_deadline_'+j+'_due_at" name ="additional_submit_deadline['+j+'][due_at]"/>' +
                        ' <img src="/images/cal.gif" onClick=\"NewCal(\'additional_submit_deadline_'+j+'_due_at\',\'YYYYMMDD\',true,24); return false;"></TD>'+


						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_submission_allowed_id" name ="additional_submit_deadline['+j+'][submission_allowed_id]">'+
						'<option value=2 SELECTED>Late</option><option value=1>No</option>'+
                        '<option value=3>OK</option>'+
						'</select></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_review_allowed_id" name ="additional_submit_deadline['+j+'][review_allowed_id]">'+
						'<option value=2 SELECTED>Late</option><option value=1>No</option><option value=3>OK</option>'+
						'</select></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_resubmission_allowed_id" name ="additional_submit_deadline['+j+'][resubmission_allowed_id]"><option value=2>Late</option>'+
						'<option value=1>No</option><option value=3 SELECTED>OK</option>'+
						'</select></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_rereview_allowed_id" name ="additional_submit_deadline['+j+'][rereview_allowed_id]">'+
						'<option value=2>Late</option><option value=1 SELECTED >No</option>'+
						'<option value=3>OK</option>'+
						'</select></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_review_of_review_allowed_id" name ="additional_submit_deadline['+j+'][review_of_review_allowed_id]">'+
						'<option value=2>Late</option><option value=1 SELECTED>No</option><option value=3>OK</option>'+
						'</select></TD>'+

                        '<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_threshold" name ="additional_submit_deadline['+j+'][threshold]">'+
						'<option value="1" selected="selected">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option></select>'+
						'</select></TD>'+                     

						'</TR>'+
						
						'<TR><TD ALIGN=LEFT WIDTH=20%>'+rereview_var+'</TD>'+
						
						//'<TD ALIGN=CENTER WIDTH=5%><input type="text" id="additional_review_deadline_'+j+'_due_at" name ="additional_review_deadline['+j+'][due_at]" onClick="NewCal(\'additional_review_deadline_'+j+'_due_at\',\'YYYYMMDD\',true,24); return false;"/></TD>'+
                        '<TD ALIGN=CENTER WIDTH=20%><input type="text" id="additional_review_deadline_'+j+'_due_at" name ="additional_review_deadline['+j+'][due_at]">' +
                        ' <img src="/images/cal.gif" onClick=\"NewCal(\'additional_review_deadline_'+j+'_due_at\',\'YYYYMMDD\',true,24); return false;"></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_review_deadline_'+j+'_submission_allowed_id" name ="additional_review_deadline['+j+'][submission_allowed_id]">'+
						'<option value=2 SELECTED >Late</option><option value=1>No</option>'+
                        '<option value=3>OK</option>'+
						'</select></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_review_deadline_'+j+'_review_allowed_id" name ="additional_review_deadline['+j+'][review_allowed_id]">'+
						'<option value=2 SELECTED	>Late</option><option value=1>No</option><option value=3 	>OK</option>'+
						'</select></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_review_deadline_'+j+'_resubmission_allowed_id" name ="additional_review_deadline['+j+'][resubmission_allowed_id]"><option value=2 SELECTED>Late</option>'+
						'<option value=1>No</option><option value=3>OK</option>'+
						'</select></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_review_deadline_'+j+'_rereview_allowed_id" name ="additional_review_deadline['+j+'][rereview_allowed_id]">'+
						'<option value=2 >Late</option><option value=1 >No</option>'+
						'<option value=3 SELECTED>OK</option>'+
						'</select></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%>'+
						'<select id="additional_review_deadline_'+j+'_review_of_review_allowed_id" name ="additional_review_deadline['+j+'][review_of_review_allowed_id]">'+
						'<option value=2>Late</option><option value=1 SELECTED>No</option><option value=3>OK</option>'+
						'</select></TD>'+

                        '<TD ALIGN=CENTER WIDTH=10%>'+
						'<select id="additional_review_deadline_'+j+'_threshold" name ="additional_review_deadline['+j+'][threshold]">'+
						'<option value="1" selected="selected">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option></select>'+
						'</select></TD>'+


						'</TR>';
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
