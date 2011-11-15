<<<<<<< HEAD
<<<<<<< HEAD
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
=======
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
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
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
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
