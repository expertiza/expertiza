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
  	                    '<TR><TD ALIGN=LEFT WIDTH=10%>'+submission_var+'</TD>'+
  	                    '<TD ALIGN=CENTER WIDTH=30%><%= datetime_select(:submission, :due_on,:include_blank=>true)%></TD>'+
						
  	                    '<TD ALIGN=CENTER WIDTH=10%><%= select(:submit_deadline_s, +j+, [ ["No", 1],["Late", 2],["OK", 3]],:selected =>3 )%></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><%= select(:review_deadline_s, +j+, [ ["No", 1],["Late", 2],["OK", 3]],:selected =>2 )%></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><%= select(:resubmit_deadline_s, +j+, [ ["No", 1],["Late", 2],["OK", 3]],:selected =>2 )%></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><%= select(:rereview_deadline_s, +j+, [ ["No", 1],["Late", 2],["OK", 3]],:selected =>2 )%></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><%= select(:reviewofreview_deadline_s, +j+, [ ["No", 1],["Late", 2],["OK", 3]],:selected =>2 )%></TD>'+
						
						'</TR>'+
						
						'<TR><TD ALIGN=LEFT WIDTH=20%>'+rereview_var+'</TD>'+
						'<TD ALIGN=CENTER WIDTH=10%><%= datetime_select(:submission, :due_on,:include_blank=>true)%></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=30%><%= select(:submit_deadline_r, +j+, [ ["No", 1],["Late", 2],["OK", 3]],:selected =>2 )%></TD>'+
												
                        '<TD ALIGN=CENTER WIDTH=10%><%= select(:review_deadline_r, +j+, [ ["No", 1],["Late", 2],["OK", 3]],:selected =>2 )%></TD>'+
					
						'<TD ALIGN=CENTER WIDTH=10%><%= select(:resubmit_deadline_r, +j+, [ ["No", 1],["Late", 2],["OK", 3]],:selected =>2 )%></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><%= select(:rereview_deadline_r, +j+, [ ["No", 1],["Late", 2],["OK", 3]],:selected =>3 )%></TD>'+
                       
						'<TD ALIGN=CENTER WIDTH=10%><%= select(:reviewofreview_deadline_r, +j+, [ ["No", 1],["Late", 2],["OK", 3]],:selected =>2 )%></TD>'+
						
						'</TR>';
  }
}