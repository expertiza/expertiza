$ = jQuery
function collapseSubDirectory(row) {
  var image = $('expand.'+row);
  var index = 0;
  var visible = true;
  while (true) {
    var partner = $('subdir.'+row+'.'+index++);
    if (partner==null) {
      break;
    }
    if (partner.visible()) {
      visible = false;
      Element.hide(partner);
    } else {
      Element.show(partner);
    }
  }
  if (visible) {
    image.src="/assets/up.png"
  } else {
    image.src="/assets/down.png"
  }
}

function getSelectedName(){
	var tbl = document.getElementById("file_table");
	var numChecks = 0;
	for(i=0; i<document.forms[2].elements.length; i++){
		if(document.forms[2].elements[i].type=="radio" &&
		   document.forms[2].elements[i].id.substring(0,9)=="chk_files"){
			if(document.forms[2].elements[i].checked==true){
				return document.getElementById("filenames_" + numChecks).value;
			}
			numChecks++;
		}
	}
}

function deleteSelectedFile(){     
	if (confirm("Are you sure?"))
		{
	        	var form = $('#folder-action-form')[0];
	        	input1 = document.createElement("input");
	        	input1.type = "hidden";
	        	input1.name = "faction[delete]";
        		form.appendChild(input1);
        		form.submit();
		}
	else return false;	
}

$(document).ready(function(){
	
	    // Function that confirms user action via a popup message.
	    // If confirmed, it creates the backend API request.
	    function confirmAndUpdate(confirmationMessage, event) {
	
	        if (confirm(confirmationMessage)) {
	            //Make changes to the DB via AJAX request
	            $.ajax({
	                type: 'PUT',
	                url: "publishing_rights_update",
	                data: {
	                    id: $(event.target).attr("id"),
	                    status: $(event.target).prop("checked")
	                }
	            });
	        }
	        else {
	            //Cancel checkbox checking/unchecking
	            event.preventDefault();
	        }
	    }
	
	    //Check the value of checkbox and take action accordingly
	    $(".make-permit-change").click(function (event) {
	        if (!$(this).prop("checked"))
	            confirmAndUpdate("Please press OK to revoke publishing rights permit.", event);
	        else
	            confirmAndUpdate("Please press OK to provide publishing rights .", event);
	    });
	});
