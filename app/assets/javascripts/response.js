/**
* Script for managing events in review form page
* To be moved back here once the javascripts can be loaded to seperate pages, instead of globaly
**/
(function(){
	if(typeof jQuery == "function"){
		// identify the buttons
		jQuery(document).on("ready",function(){
			
			var buttons = jQuery(".mark-delete-sample").find("button");

			var openPopup = function(similarAssignmentsMap){
				// global variable assume: currentAssignmentName
				// construct popup HTML
				
			};

			var markUnmarkFail = function(elem,result){
				elem.html(result);
				elem.removeClass("hide");
			};

			buttons.on("click",function(e){
				var _d = jQuery(this);
				var updatedVisibility = _d.attr("data-visibility");
				var responseId = _d.attr("data-response-id");
				var markUnmarkFailMessage = jQuery("#mark_unmark_fail");
				// request to change status of this response
				jQuery.ajax({
					"url":"/sample_reviews/mark_unmark/"+responseId, // URL to be discussed
					"type":"POST",
					"dataType":"json",
					"responseType":"json",
					"data":{
						"visibility":updatedVisibility
					},
					"success":function(result){
						if(result.success){
							markUnmarkFailMessage.html("").addClass("hide");
							openPopup(result.similarAssignmentsMap);

							// hide and show remove and mark
						}else{
							markUnmarkFail(markUnmarkFailMessage,result.error);
							// you are not allowed to make this review as sample
						}
					},
					"failure":function(res){markUnmarkFail(markUnmarkFailMessage,"Something Went Wrong");},
					"error":function(res){markUnmarkFail(markUnmarkFailMessage,"Something Went Wrong");}
				});
			});
		});
		
	}
})();

/*
In /sample_reviews/mark_unmark/:id

params[:id] is responseId
params[:visiblility] is the updated value

// fetch Course from response id (Response -> responseMap -> Assignment -> Course)
// check if current_user has access to Course
// if no access: return json { "success":false, "error":"Unauthorized" }
// if access, update (DB) Response.visiblity to param value, and insert 1 row (self-loop) to similar_assignments

// if DB operations fail, return json {"success":false, "error":"Something went wrong"}
// fetch similar assignments SA to this assignment from similar_assignments (in response, these must have checked = true)
// fetch all assignments (except this U SA) by course, in order of most recently created assignment first (in response, these must have checked = false)
// return json {"success":true, "similarAssignmentsMap":
// [{29:{title:"assignment title","checked":true},{90:{title:"tTitle 2","checked":false}}]


// on click of submit:

// POST request to similar_assignments/create/:id
// id is assignment_id
// params[:intent] = "review",
// params[:similar] = {
	"unchecked":[90,20], // read these and delete from similar_assignments
	"checked":[11,12]	// read these and insert into similar assignments (if not present!!)
}
// response: json as {"success":true/false, "error":"Something went wrong"}
// or {"succes":true}

// in method:
// fetch course from param assignment id and check if current_user has access to Course
// if no access: return json { "success":false, "error":"Unauthorized" }
// if access, db deletes and inserts (to similar_assignments)
// if db updates fail, return json {"success":false, "error":"Something went wrong"}
// if succeed: return json {"succes":true}

*/