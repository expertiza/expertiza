function alternate(id){
  if(document.getElementsByTagName){
    var table = document.getElementById(id);
    var rows = table.getElementsByTagName("tr");
    var displayedRows = [];
    index = 0;
    for (i=0; i < rows.length; i++){       
       if (rows[i].style.display != 'none' && rows[i].id != "header"){
          displayedRows[index] = rows[i];
          index += 1; 
       }
    }
    for (i=0; i < displayedRows.length; i++){
      if (i % 2 == 0){
        displayedRows[i].className = "even";        
      } else {
        displayedRows[i].className = "odd";
      }           
    }
  }
}

function toggleElement(elementId, linkText) {	
	var obj = document.getElementById(elementId);
	if (obj == null) { return; }	
	var bExpand = obj.style.display.length == 0;	
	obj.style.display = (bExpand ? 'none' : '');           
	var objLinks = document.getElementsByName(elementId+'Link')
	for (var i = 0; i < objLinks.length; i++) {
		if (Element.visible(obj)) {
			objLinks[i].innerHTML = 'hide ' + linkText
		}
		else {
			objLinks[i].innerHTML = 'show ' + linkText
		}
	}
}
        
function toggleList(elementId,listSize) {
	if (listSize == 0) {return;}		
	for (var i = 1; i <= listSize; i++){
		var obj = document.getElementById(elementId+"_"+i);
		if (obj == null) { return; }
		var bExpand = obj.style.display.length == 0;
		obj.style.display = (bExpand ? 'none' : '');			
		if (obj.style.display == 'none') {	
			var sublistsize = 1;
			while (document.getElementById(obj.id+"_"+sublistsize) != null){
				sublistsize += 1;
		}
		sublistsize = sublistsize - 1;
	
		if (sublistsize > 0 && document.getElementById(obj.id+"_"+sublistsize).style.display != 'none')
			toggleList(obj.id,sublistsize);			
		}
	}
  		  	
	var objLinks = document.getElementsByName(elementId+'Link')
	for (var i = 0; i < objLinks.length; i++) {
		if (Element.visible(obj)) {		    
			objLinks[i].innerHTML = '<img src="/images/collapse.png">'
		}
		else {		    
			objLinks[i].innerHTML = '<img src="/images/expand.png">'
		}
	}
}  