function checkRows(textArea){
	if(textArea.name!='digital_signature' && textArea.name!='private_key'){
		   
	while(textArea.rows > 1 && textArea.scrollHeight < textArea.offsetHeight)
	   textArea.rows--;
	   
	while(textArea.scrollHeight > textArea.offsetHeight)
	   textArea.rows++;
}
}

function loopRows(){
	var textareas = document.getElementsByTagName('textarea')
	for( var x in textareas)
	   checkRows(textareas[x]);
}
 
// Multiple onload function created by: Simon Willison
// http://simon.incutio.com/archive/2004/05/26/addLoadEvent
function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      if (oldonload) {
        oldonload();
      }
      func();
    }
  }
}

addLoadEvent(function() {
  loopRows();
});
