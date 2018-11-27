/**
* Script for managing events in review form page
* To be moved back here once the javascripts can be loaded to seperate pages, instead of globaly
**/
(function(){
	if(typeof jQuery == "function"){
		// identify the buttons
		jQuery(document).on("ready",function(){
			var markedAsSample = jQuery("#sampleReviewHold").attr("data-marked");
			jQuery("#sampleReviewHold").remove();

			var assignmentId = jQuery("#similar_assignments_popup").attr("data-assignment-id");
			var buttons = jQuery(".mark-delete-sample").find("div").find("button");

			var toggleMarkUnmark = function(round,marked,hasError,message){
				var markButton = jQuery(jQuery(".mark-delete-sample.round"+round).find("div").find("button")[0]);
				var unmarkButton = jQuery(jQuery(".mark-delete-sample.round"+round).find("div").find("button")[1]);
				if(marked){
					markButton.addClass("hide");
					unmarkButton.removeClass("hide");
				}else{
					markButton.removeClass("hide");
					unmarkButton.addClass("hide");
				}
				toggleMarkUnmarkResultMessage(round,hasError,message);
			};

			var toggleMarkUnmarkResultMessage = function(round,hasError,message){
				if(hasError){
					jQuery("#mark_unmark_fail_"+round).removeClass("hide").html(message);
					jQuery("#mark_unmark_success_"+round).addClass("hide").html("");
				}else{
					jQuery("#mark_unmark_fail_"+round).addClass("hide").html("");
					jQuery("#mark_unmark_success_"+round).removeClass("hide").html(message);
				}
			};

			var hideMarkUnmarkResultMessage = function(round){
				jQuery("#mark_unmark_fail_"+round).addClass("hide");
				jQuery("#mark_unmark_success_"+round).addClass("hide");
			}

			var AssignmentsPopup = {
				init:function(){
					this._target = jQuery("#similar_assignments_popup");
					this.opener = jQuery("#link_assignments");
					this.closer = this._target.find(".closer");
					this.submitter = this._target.find(".submitter");
					this.successMessageSpan = jQuery("#link_assignments_success");
					this.errorMessageSpan = jQuery("#link_assignments_error");
					this.assignmentsMap = [];
					this.list = this._target.find("ul");
					this.template = jQuery("#popup_list_template");
					this.template.remove();
				},
				addToList:function(assignment){
					var assignmentId = assignment.id;
					var title = assignment.title;
					var checked = assignment.checked;
					var newRow = this.template.clone();
					newRow.removeClass("hide").find("input").attr("data-id",assignmentId).attr("checked",checked);
					newRow.find("span").html(title).on("click",function(){
						newRow.find("input").click();
					});
					this.list.append(newRow.removeAttr("id"));
				},
				open:function(){
					// using map template, build the HTML
					var self = this;
					for(var i in this.assignmentsMap){
						this.addToList(this.assignmentsMap[i]);
					}
					this._target.parent().removeClass("hide");
				},
				showError:function(message){
					this.errorMessageSpan.html(message).removeClass("hide");
				},
				hideError:function(){
					this.errorMessageSpan.html("").addClass("hide");
				},
				showSuccess:function(message){
					this.successMessageSpan.html(message).removeClass("hide");
				},
				hideSuccess:function(){
					this.successMessageSpan.html("").addClass("hide");
				},
				fetchAssignments:function(){
					var self = this;
					jQuery.ajax({
						"url":"/similar_assignments/"+assignmentId,
						"type":"GET",
						"dataType":"json",
						"responseType":"json",
						"beforeSend":function(){
							self.hideSuccess();
							self.hideError();
						},
						"success":function(result){
							if(result.success){
								self.onFetchSuccess(result.values);
							}else{
								self.onFetchFail(result.error);
							}
						},
						"failure": self.onFetchFail,

                         //    self.onFetchSuccess( // should be self.onFetchFail , this is a mocked response.. use result.map
						// 	[{
						// 		"title": "assignment title",
						// 		"checked": true,
						// 		"id": 29
						// 	},
						// 	{
						// 		"title": "assignment title 2",
						// 		"checked": false,
						// 		"id": 350
						// 	}
						// ])
						// "error":self.onFetchSuccess([{29:{title:"assignment title","checked":true},{90:{title:"tTitle 2","checked":false}}])

						"error":self.onFetchFail
					});
				},
				onFetchSuccess:function(assignmentsMap){
					AssignmentsPopup.assignmentsMap = assignmentsMap;
					AssignmentsPopup.hideSuccess();
					AssignmentsPopup.hideError();
					AssignmentsPopup.open();
				},
				onFetchFail:function(message){
					message = (typeof message != "undefined" && message.length)?message:"An error occurred";
					AssignmentsPopup.assignmentsMap = [];
					AssignmentsPopup.showError(message);
					AssignmentsPopup.hideSuccess();
				},
				close:function(){
					this.assignmentsMap = [];
					this.hideSuccess();
					this.hideError();
					this._target.parent().addClass("hide");
					this.resetList();
				},
				closeAfterSubmit:function(success,message){
					this.close();
					if(success){
						this.showSuccess(message);
						this.hideError();
					}else{
						this.showError(message);
						this.hideSuccess();
					}
				},
				resetList:function(){
					this.list.html("").append(this.template);
				},
				findDelta:function(){
					var existingChecked = [], existingUnchecked = [];
					// Current
					for(var i in this.assignmentsMap){
						var assignment = this.assignmentsMap[i];
						if(assignment.checked){
							existingChecked.push(assignment.id);
						}else{
							existingUnchecked.push(assignment.id);
						}
					}
					var existingCheckedSet = new Set(existingChecked);
					var existingUncheckedSet = new Set(existingUnchecked);
					// Changed
					var newChecked = [];
					var newUnchecked = [];
					var formLi = this.list.find("li").not("#popup_list_template");
					formLi.each(function(index,li){
						li = $(li);
						var liCheckbox = li.find("input");
						var isChecked = liCheckbox.is(":checked");
						var aId = parseInt(liCheckbox.attr("data-id"));
						if(isChecked){
							newChecked.push(aId);
						}else{
							newUnchecked.push(aId);
						}
					});
					var newCheckedSet = new Set(newChecked);
					var newUncheckedSet = new Set(newUnchecked);
					var differenceCheckedSet = new Set([...newCheckedSet].filter(setElement => !existingCheckedSet.has(setElement)));
					var differenceUncheckedSet = new Set([...newUncheckedSet].filter(setElement => !existingUncheckedSet.has(setElement)));
					var differenceChecked = Array.from(differenceCheckedSet);
					var differenceUnchecked = Array.from(differenceUncheckedSet);
					return {
						"checked":differenceChecked,
						"unchecked":differenceUnchecked
					};
				},
				submit:function(){
					// on submit:
					// function to find delta from fetch result
					var delta = this.findDelta();
					if(!delta.checked.length && !delta.unchecked.length){
						this.close();
					}else{
						// make Ajax call
						var self = this;
						jQuery.ajax({
							"url":"/similar_assignments/create/"+assignmentId,
							"type":"POST",
							"dataType":"json",
							"responseType":"json",
							"data":{
								"similar":delta
							},
							"success":function(result){	// should be success.. used for mocking

								if(result.success){
									self.closeAfterSubmit(true,"Done!");
								}else{
									self.onSubmitFail(result.error);
								}
							},
							"failure":self.onSubmitFail,
							"error":self.onSubmitFail
						});
						// on success: close, clear error message, show success message

						// on fail: close, clear success message, show error message
					}
				},
				onSubmitFail:function(message){
					message = (typeof message != "udefined" && message.length)?message:"An error occurred";
					this.closeAfterSubmit(false,message);
				}

			};

			AssignmentsPopup.init();
			
			buttons.on("click",function(e){
				var _d = jQuery(this);
				var round = _d.attr("data-round");
				var updatedVisibility = _d.attr("data-visibility");
				var responseId = _d.attr("data-response-id");
				var markUnmarkFailMessage = jQuery("mark_unmark_fail_"+round);
				var markUnmarkSuccessMessage = jQuery("mark_unmark_success_"+round);
				var markUnmarkFail = function(){
					toggleMarkUnmarkResultMessage(round,true,"Something went wrong!");
				};

				var updatingToMark = (updatedVisibility == markedAsSample);
				var resultMessage = (updatingToMark)?"Marked as sample!":"No more a sample!"
				jQuery.ajax({
					"url":"/sample_reviews/mark_unmark/"+responseId,
					"type":"POST",
					"dataType":"json",
					"responseType":"json",
					"data":{
						"visibility":updatedVisibility
					},
					"beforeSend":hideMarkUnmarkResultMessage(round),
					"success":function(result){
						if(result.success){
							toggleMarkUnmark(round,updatingToMark,false,resultMessage);
						}else{
							toggleMarkUnmarkResultMessage(round,true,result.error);
						}
					},
					"failure":markUnmarkFail,
					"error":markUnmarkFail
				});
			});

			AssignmentsPopup.opener.on("click",function(event){
				AssignmentsPopup.fetchAssignments();
			});

			AssignmentsPopup.closer.on("click",function(event){
				AssignmentsPopup.close();
			});

			AssignmentsPopup.submitter.on("click",function(event){
				AssignmentsPopup.submit();
			});
		});
		
	}
})();

/*
In /sample_reviews/mark_unmark/:id

params[:id] is responseId
params[:visiblility] is the updated

fetch Course from response id (Response -> responseMap -> Assignment -> Course)
check if current_user has access to Course
if no access: return json { "success":false, "error":"Unauthorized" }
if access, update (DB) Response.visiblity to param value, and insert 1 row (self-loop) to similar_assignments

if DB operations fail, return json {"success":false, "error":"Something went wrong"}
fetch similar assignments SA to this assignment from similar_assignments (in response, these must have checked = true)
fetch all assignments (except this U SA) by course, in order of most recently created assignment first (in response, these must have checked = false)
return json {"success":true, "similarAssignmentsMap":
[{29:{title:"assignment title","checked":true},{90:{title:"tTitle 2","checked":false}}]




POST request to similar_assignments/create/772
id is assignment_id X
params[:intent] = "review",
params[:similar] = {
	"unchecked":[90,20], // read these and delete from similar_assignments
	"checked":[11,12]	// read these and insert into similar assignments (if not present!!)
}
params[:similar] will send those rows that the user has changed

params[:similar] = {"checked":[350,80,290],"unchecked":[20,340,10]}

response: json as {"success":true/false, "error":"Something went wrong"}
or {"succes":true}

in method:
fetch course from param assignment id and check if current_user has access to Course
if no access: return json { "success":false, "error":"Unauthorized" }
if access, db deletes and inserts (to similar_assignments)
if db updates fail, return json {"success":false, "error":"Something went wrong"}
if succeed: return json {"succes":true}

*/