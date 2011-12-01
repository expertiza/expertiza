actHover = function() {
	// Attempt to load the action menu, and stop if it fails
	var amenu = document.getElementById("actionmenu");
	if(typeof(amenu) === 'undefined') return;
	
	var actEls = amenu.getElementsByTagName("LI");
	for (var i=0; i<actEls.length; i++) {
		actEls[i].onmouseover=function() {
			this.className+=" acthover";
		}
		actEls[i].onmouseout=function() {
			this.className=this.className.replace(new RegExp(" acthover\\b"), "");
		}
	}
}
if (window.attachEvent) window.attachEvent("onload", actHover);
