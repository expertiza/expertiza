// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function addElement() {
  
  var ni = document.getElementById('author');
  var numi = document.getElementById('numSubmitReviewPeriods');
  var authHTML = "";
   //alert (numi.value);
   var limit=numi.value;
   var i;
  ni.innerHTML = "";
  for(i=1;i<limit;i++)
  {
  	//alert (ni.innerHTML);
  	var j = i+1;
  	ni.innerHTML = ni.innerHTML + '<TABLE BORDER="1"><TR><TH>Date</TH><TH>Time</TH><TH>Submission Allowed</TH><TH>Review Allowed</TH>'+
						'<TH>Resubmission Allowed</TH><TH>Rereview Allowed</TH><TH>Review of Review Allowed</TH></TR>'+
						'<TR><TD ALIGN=CENTER><input type="text"/></TD><TD ALIGN=CENTER><input type="text"/></TD><TD ALIGN=CENTER>'+
						'<select name="deadlineSubmitAllowed0"><option value="Late" 	>Late</option<option value="NO" 	>NO</option>'+
                        '<option value="OK" SELECTED	>OK</option></select></TD><TD ALIGN=CENTER><select name="deadlineReviewAllowed0">'+
						'<option value="Late" SELECTED	>Late</option><option value="NO" 	>NO</option><option value="OK" 	>OK</option>'+
						'</select></TD><TD ALIGN=CENTER><select name="deadlineResubmitAllowed0"><option value="Late" 	>Late</option>'+
						'<option value="NO" 	>NO</option><option value="OK" SELECTED	>OK</option></select></TD><TD ALIGN=CENTER>'+
                        '<select name="deadlineRereviewAllowed0"><option value="Late" SELECTED	>Late</option><option value="NO" 	>NO</option>'+
						'<option value="OK" 	>OK</option></select></TD><TD ALIGN=CENTER><select name="deadlineReviewOfReviewAllowed0">'+
						'<option value="Late" SELECTED	>Late</option><option value="NO" 	>NO</option><option value="OK" 	>OK</option>'+
						'</select></TD></TR></TABLE>';
  }
}