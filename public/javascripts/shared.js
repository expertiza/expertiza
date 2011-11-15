<<<<<<< HEAD
<<<<<<< HEAD
function checkIfFileExists(filename, flag)
{
    if(filename=='')
    {
	if (flag == 1)
	        alert('Please select a file to upload');
	else
		alert('Please enter a link to upload');
	return false;
    }
    else {
	return true;
    }
	
}

function checkIfFileSelected(operation){
        var tbl = document.getElementById("file_table");
        var numChecks = 0;
	var flag = 0;
        for(i=0; i<document.forms[2].elements.length; i++){
                if(document.forms[2].elements[i].type=="radio" &&
                   document.forms[2].elements[i].id.substring(0,9)=="chk_files"){
                        if(document.forms[2].elements[i].checked==true){
                                flag = 1;
				return true;
                        }
                }
        }
	if (flag == 0)
	{
		alert("Please select a file to perform "+operation+" operation");
		return false;
	}
}

=======
function checkIfFileExists(filename, flag)
{
    if(filename=='')
    {
	if (flag == 1)
	        alert('Please select a file to upload');
	else
		alert('Please enter a link to upload');
	return false;
    }
    else {
	return true;
    }
	
}

function checkIfFileSelected(operation){
        var tbl = document.getElementById("file_table");
        var numChecks = 0;
	var flag = 0;
        for(i=0; i<document.forms[2].elements.length; i++){
                if(document.forms[2].elements[i].type=="radio" &&
                   document.forms[2].elements[i].id.substring(0,9)=="chk_files"){
                        if(document.forms[2].elements[i].checked==true){
                                flag = 1;
				return true;
                        }
                }
        }
	if (flag == 0)
	{
		alert("Please select a file to perform "+operation+" operation");
		return false;
	}
}

>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
function checkIfFileExists(filename, flag)
{
    if(filename=='')
    {
	if (flag == 1)
	        alert('Please select a file to upload');
	else
		alert('Please enter a link to upload');
	return false;
    }
    else {
	return true;
    }
	
}

function checkIfFileSelected(operation){
        var tbl = document.getElementById("file_table");
        var numChecks = 0;
	var flag = 0;
        for(i=0; i<document.forms[2].elements.length; i++){
                if(document.forms[2].elements[i].type=="radio" &&
                   document.forms[2].elements[i].id.substring(0,9)=="chk_files"){
                        if(document.forms[2].elements[i].checked==true){
                                flag = 1;
				return true;
                        }
                }
        }
	if (flag == 0)
	{
		alert("Please select a file to perform "+operation+" operation");
		return false;
	}
}

>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
