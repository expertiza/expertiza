  function toggleAll(numteams){    
    var maintag = document.getElementById('teamAll');
    hidden = maintag.innerHTML == 'Show all teams';    
    if (hidden) {maintag.innerHTML = 'Hide all teams';}
    else {maintag.innerHTML = 'Show all teams';}    
   	toggleTeams(numteams,hidden);       
  }
  
  function collapseObj(obj, atag){
	obj.style.display = 'none';
  	atag.innerHTML = '<img src="/assets/expand.png">';  	    	
  	   	
  	files = document.getElementById(obj.id+'_files');
  	if (files) {
  		files.style.display = 'none';
  	    files_tag = document.getElementById(obj.id+'_filesLink');
  	    if (files_tag){files_tag.innerHTML = 'show submission';}
  	}  
  	reviews = document.getElementById(obj.id+'_reviews');
  	if (reviews) {
  		reviews.style.display = 'none';
  	   	reviews_tag = document.getElementById(obj.id+'_reviewsLink');
  	   	if (reviews_tag){reviews_tag.innerHTML = 'show reviews';}
	} 
  	mreviews = document.getElementById(obj.id+'_mreviews');
  	if (mreviews) {
  		mreviews.style.display = 'none';
  	   	mreviews_tag = document.getElementById(obj.id+'_mreviewsLink');
  	   	if(mreviews_tag){mreviews_tag.innerHTML = 'show metareviews';}
	}
	previews = document.getElementById(obj.id+'_previews');
  	if (previews) {
  		previews.style.display = 'none';
  	   	previews_tag = document.getElementById(obj.id+'_previewsLink');
  	   	if(previews_tag){previews_tag.innerHTML = 'show teammate reviews';}
	}		 	
  }
  
  function toggleTeams(numteams,hidden){
  	for (var i = 0; i < numteams; i++){
  	  elementId = 'team'+i;
  	  var atag = document.getElementById(elementId+'Link');
  	  var sublistsize = 1;
  	  while (document.getElementById(elementId+"_"+sublistsize) != null){
  	    var obj = document.getElementById(elementId+"_"+sublistsize);
  	    if (hidden) {
  	    	obj.style.display = '';
  	    	atag.innerHTML = '<img src="/assets/collapse.png">';}
  	    else {
  	    	collapseObj(obj, atag);  	    	  	       
  	    }  	    
  	    sublistsize += 1;  	    
  	  }
  	}
  } 
  
  function toggleTeam(elementId){
	var sublistsize = 1;
	var obj = document.getElementById(elementId+"_"+sublistsize);	
	var atag = document.getElementById(elementId+'Link');	
        var header = document.getElementById(elementId+'_header');
	
  	while (obj != null){ 

      header.style.backgroundColor = 'white';
      header.style.color = "#000000";
  	  var bExpand = obj.style.display.length == 0;	  	   	  
  	  if (bExpand) {
            collapseObj(obj, atag);
  	  }
  	  else {
				obj.style.display = '';
				//E1877: changes made to adjust width of expandables
				var offsets = obj.getBoundingClientRect();
				obj.style.width="calc(100vw - 103px)";
  	  	atag.innerHTML = '<img src="/assets/collapse.png">';
            header.style.backgroundColor = '#a90201';
            header.style.color = "#ffffff";
  	  }  	    
  	  sublistsize += 1;  
  	  var obj = document.getElementById(elementId+"_"+sublistsize);	    
  	}  	  
  }  
