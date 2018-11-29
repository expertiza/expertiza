(function(){
	if(typeof jQuery == "function"){
		jQuery(document).on("ready",function(){
			var pageSize = parseInt(jQuery("#pageSizeSpan").html());
			jQuery("#pageSizeSpan").remove();
			var ulList = jQuery(".samples");
			var assignmentId = parseInt(ulList.attr("data-id"));
			var pageNumber = 1;
			var listTemplate = jQuery("#li_template").clone();
			$("#li_template").remove();
			var moreButton = jQuery("#more_button");
			var currentNumberOfRows = ulList.find("li").length;
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
								for(var i in result.sampleReviews){
									currentNumberOfRows++;
									var review = result.sampleReviews[i];
									var newRow = listTemplate.clone();
									newRow.removeClass("hide").removeAttr("id").find("a").
									html("Sample Review "+currentNumberOfRows).attr("href",review);
									ulList.append(newRow);
								}
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