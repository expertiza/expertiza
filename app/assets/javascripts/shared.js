function checkForFile() {
    var file_value = $('#import_file').val();
    $(document).ready(function() {
        $('#import_form').submit(file_value)
        if (file_value.length <= 0) {
            alert('Please select a file before clicking Import.');
        } else {
            import_form.submit();
        };
    });
}

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

