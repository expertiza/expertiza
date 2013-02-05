actHover = function() {
	var actEls = document.getElementById("actionmenu").getElementsByTagName("LI");
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
