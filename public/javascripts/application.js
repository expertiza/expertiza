// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function addElement() {
  
  var ni = document.getElementById('extra_deadlines');
  var numi = document.getElementById('numSubmitReviewPeriods');
  var authHTML = "";
   //alert (numi.value);
  var limit=numi.value;
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
		submission_var= 'Re-submission-'+j+' deadline'
		rereview_var = 'Re-review-'+j+' deadline'
	}
  	ni.innerHTML = ni.innerHTML + 
  	                    '<TR><TD ALIGN=LEFT WIDTH=20%>'+submission_var+'</TD>'+
  	                    '<TD ALIGN=CENTER WIDTH=5%><input type="text" id="additional_submit_deadline_'+j+'_due_at" name ="additional_submit_deadline['+j+'][due_at]"  onClick=\"NewCal(\'additional_submit_deadline_'+j+'_due_at\',\'YYYYMMDD\',true,24); return false;"/></TD>'+
  	                    
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_submission_allowed_id" name ="additional_submit_deadline['+j+'][submission_allowed_id]">'+
						'<option value=2 SELECTED>Late</option<option value=1>No</option>'+
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
						'</TR>'+
						
						'<TR><TD ALIGN=LEFT WIDTH=20%>'+rereview_var+'</TD>'+
						
						'<TD ALIGN=CENTER WIDTH=5%><input type="text" id="additional_review_deadline_'+j+'_due_at" name ="additional_review_deadline['+j+'][due_at]" onClick="NewCal(\'additional_review_deadline_'+j+'_due_at\',\'YYYYMMDD\',true,24); return false;"/></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_review_deadline_'+j+'_submission_allowed_id" name ="additional_review_deadline['+j+'][submission_allowed_id]">'+
						'<option value=2 SELECTED >Late</option<option value=1>No</option>'+
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
						'</TR>';
  }
}