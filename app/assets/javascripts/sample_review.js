/**
This JS is used in the page that lists out all sample reviews
*/
(function(){
	if(typeof jQuery == "function"){
		jQuery(document).on("ready",function(){
			// From an HTML element, get the size of each pagination request by reading its content.
			// Store the value in a local variable and remove the element from the page source.
			var pageSize = parseInt(jQuery("#pageSizeSpan").html());
			jQuery("#pageSizeSpan").remove();
			
			var ulList = jQuery(".samples");
			var assignmentId = parseInt(ulList.attr("data-id"));
			var pageNumber = 1;
			
			// Let a hidden HTML element (li) be a template for more li's
			// Store the template in a local variable and remove the template from the page source.
			var listTemplate = jQuery("#li_template").clone();
			$("#li_template").remove();
			var moreButton = jQuery("#more_button");
			var currentNumberOfRows = ulList.find("li").length;
			// if More button exists, define its on click handler..
			// it must fetch more sample reviews
			if(moreButton.length){
				moreButton.on("click",function(){
					var self = $(this);
					var url = "/sample_reviews/index/"+assignmentId+"?page="+pageNumber;
					jQuery.ajax({
						"url":url,
						"type":"GET",
						"dataType":"json",
						"responseType":"json",
						"success":function(result){
							if(result.success){
								var responseSize = result.sampleReviews.length;
								// for each sample review fetched, clone the template,.
								// ..add data to it, and add to page source
								for(var i in result.sampleReviews){
									currentNumberOfRows++;
									var review = result.sampleReviews[i];
									var newRow = listTemplate.clone();
									newRow.removeClass("hide").removeAttr("id").find("a").
									html("Sample Review "+currentNumberOfRows).attr("href",review);
									ulList.append(newRow);
								}
								// when lesser results than expected, no more pagination
								if(responseSize < pageSize){
									self.html("No more results!").off().css({"cursor":"default"});
								}else{
									pageNumber++;
								}
							}
						}
					});

				});
			}
		});
	}
})();