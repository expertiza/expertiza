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
                        '<TD ALIGN=LEFT WIDTH=20%> '+submission_var+' </TD>'+
  	                    '<TD ALIGN=CENTER WIDTH=20%>' +
                        '<table><tr>' +
                        '<TD><input type="text" id="additional_submit_deadline_'+j+'_due_at" name ="additional_submit_deadline['+j+'][due_at]" value='+submit_due+' ></TD>' +
                        '<TD><img src="/images/cal.gif" onClick=\"NewCal(\'additional_submit_deadline_'+j+'_due_at\',\'YYYYMMDD\',true,24); return false;"></TD>' +
                        '</TR></table>' +
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
                        '<TD ALIGN=LEFT WIDTH=20%>'+rereview_var+'</TD>'+
						
						//'<TD ALIGN=CENTER WIDTH=5%><input type="text" id="additional_review_deadline_'+j+'_due_at" name ="additional_review_deadline['+j+'][due_at]" onClick="NewCal(\'additional_review_deadline_'+j+'_due_at\',\'YYYYMMDD\',true,24); return false;"/></TD>'+
                        '<TD ALIGN=CENTER WIDTH=20%><input type="text" id="additional_review_deadline_'+j+'_due_at" name ="additional_review_deadline['+j+'][due_at]" value='+review_due+'>' +
                        ' <img src="/images/cal.gif" onClick=\"NewCal(\'additional_review_deadline_'+j+'_due_at\',\'YYYYMMDD\',true,24); return false;"></TD>'+
						
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