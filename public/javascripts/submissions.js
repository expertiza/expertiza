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
    image.src="/images/up.png"
  } else {
    image.src="/images/down.png"
  }
}
function createNewFolder(){
	var new_folder = prompt("Enter a name for a new folder","");
	input1 = document.createElement("input");
	var form = document.getElementsByTagName('form')[2];
	input1.type = "hidden";
	input1.name = "faction[create]";
	input1.value = new_folder;
	form.appendChild(input1);
	if ((new_folder!=null) && (new_folder!='')) {
		form.submit();
	}
	if (new_folder =='')
    {   
        alert("Please specify a filename");
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

function moveSelectedFile(){	
	var old_filename = getSelectedName();
	var new_filename = prompt("Enter a new location for " + old_filename + "\nExample: folder1/file.doc","");
	var form = document.getElementsByTagName('form')[2];
	input1 = document.createElement("input");
	input1.type = "hidden";
	input1.name = "faction[move]";
	input1.value = new_filename;
	form.appendChild(input1);
	if ((new_filename!=null) && (new_filename!='')) {
		form.submit();
	}
}

function copySelectedFile(){	
	var old_filename = getSelectedName();
	var new_filename = prompt("Enter a new location for the copy of " + old_filename + "\nExample: /folder1/file.doc","");
	var form = document.getElementsByTagName('form')[2];
	input1 = document.createElement("input");
	input1.type = "hidden";
	input1.name = "faction[copy]";
	input1.value = new_filename;
	form.appendChild(input1);
	if ((new_filename!=null) && (new_filename!='')) {
		form.submit();
	}
}

function renameFile(){        
	var old_filename = getSelectedName();
	var new_filename = prompt("Enter a new name for " + old_filename,"");
	var form = document.getElementsByTagName('form')[2];	
	if (navigator.appName == "Microsoft Internet Explorer") {
		input1 = document.createElement('<input type=hidden name="new_filename" value = "'+new_filename+'">');
		form.appendChild(input1);
	}
	else {
		input1 = document.createElement("input");
		input1.type = "hidden";
        input1.name = "faction[rename]";
        input1.value = new_filename;
		form.appendChild(input1);
	}
	if ((new_filename!=null) && (new_filename!='')) {
		form.submit();
	}
}

function deleteSelectedFile(){     
	if (confirm("Are you sure. If directory all its children will be deleted.  Do you want to delete?"))
		{
	        	var form = document.getElementsByTagName('form')[2];
	        	input1 = document.createElement("input");
	        	input1.type = "hidden";
	        	input1.name = "faction[delete]";
        		form.appendChild(input1);
        		form.submit();
		}
	else return false;	
}