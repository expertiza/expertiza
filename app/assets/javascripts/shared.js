function checkForFile() {
    var file_value = $('#import_file').val();
    $(document).ready(function() {
        if (file_value.length <= 0) {
            alert('Please select a file before clicking Import.');
        } else {
            import_form.submit();
        };
    });
}

function checkForDuplicates(field_count) {
    var val_array = [];
    var i = getElements(field_count, val_array);

    var sorted_val_array = val_array.slice().sort();
    var has_duplicates = false;
    for (var i = 0; i < sorted_val_array.length - 1; i++) {
        if (sorted_val_array[i + 1] == sorted_val_array[i]) {
            has_duplicates = true;
        }
    }

    if (has_duplicates) {
        alert("No two columns can have the same value.");
    } else {
        column_form.submit();
    }
}

function getElements(field_count, val_array) {
    for (var i = 1; i <= field_count; i++) {
        var sel = document.getElementById("select" + (i).toString());
        val_array[i] = sel.options[sel.selectedIndex].value;
    }
    return i;
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

