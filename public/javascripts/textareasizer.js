<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
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
<<<<<<< HEAD
=======
=======
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
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
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
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
