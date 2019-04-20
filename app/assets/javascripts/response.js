/**
 * Script for managing events in review form page
 * To be moved back here once the javascripts can be loaded to seperate pages, instead of globaly
 **/
(function(){
    if(typeof jQuery == "function"){
        // identify the buttons
        jQuery(document).on("ready",function(){
            // From an HTML element, get the integer value that represents "approve as sample".
            // Store the value in a local variable and remove the element from the page source.
            var markedAsSample = jQuery("#sampleReviewHold").attr("data-marked");
            jQuery("#sampleReviewHold").remove();

            // From an HTML element, get the size of each pagination request by reading its content.
            // Store the value in a local variable and remove the element from the page source.
            var pageSize = parseInt(jQuery("#pageSizeHold").html());
            jQuery("#pageSizeHold").remove();

            var assignmentId = jQuery("#similar_assignments_popup").attr("data-assignment-id");
            var buttons = jQuery(".mark-delete-sample").find("div").find("button");

            // A function that takes integer, boolean, boolean, string as parameters...
            // ..and toggles the button text and success/error message
            // ..for "mark as sample" or "remove as sample" buttons.
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

            // A function that updates the success/error message below mark/remove as sample buttons..
            // ...on every click of the button
            var toggleMarkUnmarkResultMessage = function(round,hasError,message){
                if(hasError){
                    jQuery("#mark_unmark_fail_"+round).removeClass("hide").html(message);
                    jQuery("#mark_unmark_success_"+round).addClass("hide").html("");
                }else{
                    jQuery("#mark_unmark_fail_"+round).addClass("hide").html("");
                    jQuery("#mark_unmark_success_"+round).removeClass("hide").html(message);
                }
            };

            // A function that hides the success/error message below mark/remove as sample buttons
            var hideMarkUnmarkResultMessage = function(round){
                jQuery("#mark_unmark_fail_"+round).addClass("hide");
                jQuery("#mark_unmark_success_"+round).addClass("hide");
            }

            // An object representing the similar assignments popup
            var AssignmentsPopup = {
                // initialize data for the popup HTML and object
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
                    this.morePages = true;
                    this.moreButton = jQuery(".popup_more");
                    this.recordsFetched = 0;
                    this.currentPageNumber = 0;
                    var self = this;
                    this.moreButton.on("click",function(){
                        if(self.morePages){
                            self.fetchAssignments();
                        }
                    });
                },
                // add an assignment to HTML list of assignments
                addToList:function(assignment){
                    var assignmentId = assignment.id;
                    var title = assignment.title;
                    var course = assignment.course_name;
                    var displayText = "<strong>"+course+": </strong>" +title;
                    var checked = assignment.checked;
                    var newRow = this.template.clone();
                    newRow.removeClass("hide").find("input").attr("data-id",assignmentId).attr("checked",checked);
                    newRow.find("span").html(displayText).on("click",function(){
                        newRow.find("input").click();
                    });
                    this.list.append(newRow.removeAttr("id"));
                },
                open:function(assignmentsMap){
                    // using map template, build the HTML list of assignments fetched
                    var self = this;
                    for(var i in assignmentsMap){
                        this.addToList(assignmentsMap[i]);
                    }
                    if(this.currentPageNumber == 0){
                        this._target.parent().removeClass("hide");
                    }
                },
                // function for success or error messages to be shown after fetching similar assignments
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
                // function to fetch similar assignments, given an assignment id
                fetchAssignments:function(){
                    var self = this;
                    var ajaxUrl = "/similar_assignments/"+assignmentId;
                    if(this.currentPageNumber > 0){
                        ajaxUrl += "?page="+this.currentPageNumber;
                    }
                    jQuery.ajax({
                        "url":ajaxUrl,
                        "type":"GET",
                        "dataType":"json",
                        "responseType":"json",
                        "beforeSend":function(){
                            self.hideSuccess();
                            self.hideError();
                        },
                        "success":function(result){
                            if(result.success && result.values.length){
                                self.onFetchSuccess(result.values);
                            }else if(result.success && self.currentPageNumber == 0){
                                self.onFetchFail("Cannot link this to any assignment!");
                            }else if(result.success){
                                self.onFetchSuccess(result.values);
                            }
                            else{
                                self.onFetchFail(result.error);
                            }
                        },
                        "failure": self.onFetchFail,
                        "error":self.onFetchFail
                    });
                },

                // on successful fetch of similar assigments, popuplate the HTML for the popup ...
                // .. and build the current popup object's data
                onFetchSuccess:function(assignmentsMap){
                    AssignmentsPopup.assignmentsMap = AssignmentsPopup.assignmentsMap.concat(assignmentsMap);
                    AssignmentsPopup.hideSuccess();
                    AssignmentsPopup.hideError();
                    AssignmentsPopup.open(assignmentsMap);
                    AssignmentsPopup.currentPageNumber++;
                    if(assignmentsMap.length < pageSize){
                        this.moreButton.html("No more results!").off();
                        this.morePages = false;
                    }
                },
                // function to show error message when similar assignments could not be fetched
                onFetchFail:function(message){
                    message = (typeof message != "undefined" && message.length)?message:"An error occurred";
                    AssignmentsPopup.assignmentsMap = [];
                    AssignmentsPopup.showError(message);
                    AssignmentsPopup.hideSuccess();
                },
                // close the popup.
                // Closing is defined as clearing popup's data, HTML, resetting error messages, ..
                // .. and resetting pagination counter
                close:function(){
                    this.assignmentsMap = [];
                    this.hideSuccess();
                    this.hideError();
                    this._target.parent().addClass("hide");
                    this.resetList();
                    this.recordsFetched = 0;
                    this.morePages = true;
                    this.currentPageNumber = 0;
                    var self = this;
                    this.moreButton.on("click",function(){
                        self.fetchAssignments();
                    }).html("More +");
                },
                // function that closes the popup on submit..
                // takes success/failure boolean result status of submission as param
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
                // clear the list of assignments from the popup
                resetList:function(){
                    this.list.html("").append(this.template);
                },
                // find out what rows have changed while selecting and unselecting similar assignments
                findDelta:function(){
                    var existingChecked = [], existingUnchecked = [];
                    // From the initial data of the popup...
                    // construct lists for 'linked' and 'not linked' assignments
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

                    // From the current data of the popup...
                    // construct lists for 'linked' and 'not linked' assignments
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
                    // find and return the difference between the two sets
                    var differenceCheckedSet = new Set([...newCheckedSet].filter(setElement => !existingCheckedSet.has(setElement)));
                    var differenceUncheckedSet = new Set([...newUncheckedSet].filter(setElement => !existingUncheckedSet.has(setElement)));
                    var differenceChecked = Array.from(differenceCheckedSet);
                    var differenceUnchecked = Array.from(differenceUncheckedSet);
                    return {
                        "checked":differenceChecked,
                        "unchecked":differenceUnchecked
                    };
                },
                // Function to submit linked and unlinked similar assignments and handle success or failure result
                submit:function(){
                    var delta = this.findDelta(); // find out what rows have changed
                    if(!delta.checked.length && !delta.unchecked.length){
                        this.close(); // if no overall change, simply close the popup
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
                            "success":function(result){
                                if(result.success){
                                    self.closeAfterSubmit(true,"Done!");
                                }else{
                                    self.onSubmitFail(result.error);
                                }
                            },
                            "failure":self.onSubmitFail,
                            "error":self.onSubmitFail
                        });
                    }
                },
                // function to handle failure of linking or unlinking assignments
                onSubmitFail:function(message){
                    message = (typeof message != "udefined" && message.length)?message:"An error occurred";
                    this.closeAfterSubmit(false,message);
                }

            };

            // Initialize the popup container
            AssignmentsPopup.init();

            // Event handler for click of Mark as Sample or Remove as Sample..
            buttons.on("click",function(e){
                var _d = jQuery(this);
                var round = _d.attr("data-round");
                var updatedVisibility = _d.attr("data-visibility");
                var responseId = _d.attr("data-response-id");
                var markUnmarkFailMessage = jQuery("mark_unmark_fail_"+round);
                var markUnmarkSuccessMessage = jQuery("mark_unmark_success_"+round);
                var linkAssignmentsText = jQuery("#link_assignments");
                var markUnmarkFail = function(){
                    toggleMarkUnmarkResultMessage(round,true,"Something went wrong!");
                };

                var updatingToMark = (updatedVisibility == markedAsSample);
                var resultMessage = (updatingToMark)?"Marked as sample!":"No more a sample!"

                // make the HTTP request to mark or unmark as sample
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
                            linkAssignmentsText.removeClass("hide");
                        }else{
                            toggleMarkUnmarkResultMessage(round,true,result.error);
                        }
                    },
                    "failure":markUnmarkFail,
                    "error":markUnmarkFail
                });
            });

            // Assign an opener element to the popup
            AssignmentsPopup.opener.on("click",function(event){
                AssignmentsPopup.fetchAssignments();
            });

            // Assign a closer to the popup
            AssignmentsPopup.closer.on("click",function(event){
                AssignmentsPopup.close();
            });

            // Assign the popup submitter
            AssignmentsPopup.submitter.on("click",function(event){
                AssignmentsPopup.submit();
            });
        });

    }
})();

