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

			buttons.on("click",function(e){
				var _d = jQuery(this);
				var updatedVisibility = _d.attr("data-visibility");
				var responseId = _d.attr("data-response-id");
				
				// request to change status of this response
				jQuery.ajax({
					"url":"sample_reviews/mark_unmark/"+responseId, // URL to be discussed
					"type":"POST",
					"dataType":"json",
					"responseType":"json",
					"data":{
						"visibility":updatedVisibility
					},
					"success":function(result){
						if(result.success){
							openPopup(result.similarAssignmentsMap);
							// hide and show remove and mark
						}else{
							markUnmarkFail(_d);
						}
					},
					"failure":function(res){markUnmarkFail(_d);},
					"error":function(res){markUnmarkFail(_d);}
				});
			});
		});
		
	}
})();