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

function checkIfUserColumnDuplicate() {

    var sel1 = document.getElementById("select1");
    var sel2 = document.getElementById("select2");
    var sel3 = document.getElementById("select3");

    var val1 = sel1.options[sel1.selectedIndex].value;
    var val2 = sel2.options[sel2.selectedIndex].value;
    var val3 = sel3.options[sel3.selectedIndex].value;

    if(val1 == val2 || val2 == val3 || val1 == val3) {
        alert("No two columns can have same value.")
    } else {
      column_form.submit();
    }
}

function checkForParticipantColumnDuplicate() {

    var sel1 = document.getElementById("select1");
    var sel2 = document.getElementById("select2");
    var sel3 = document.getElementById("select3");
    var sel4 = document.getElementById("select4");

    var val1 = sel1.options[sel1.selectedIndex].value;
    var val2 = sel2.options[sel2.selectedIndex].value;
    var val3 = sel3.options[sel3.selectedIndex].value;
    var val4 = sel4.options[sel4.selectedIndex].value;

    if(val1 == val2 || val1 == val3 || val1 == val4 || val2 == val3 || val2 == val4 || val3 == val4) {
        alert("No two columns can have same value.")
    } else {
        column_form.submit();
    }
}

function checkTopicForDuplicatesAndRequiredColumns(optional_count) {

    var sel1 = document.getElementById("select1");
    var sel2 = document.getElementById("select2");
    var sel3 = document.getElementById("select3");

    var val1 = sel1.options[sel1.selectedIndex].value;
    var val2 = sel2.options[sel2.selectedIndex].value;
    var val3 = sel3.options[sel3.selectedIndex].value;

    var val_array = [val1, val2, val3];

    for (var i = 0; i < optional_count; i++) {
        var sel = document.getElementById("select" + (i + 4).toString());
        val_array[i + 3] = sel.options[sel.selectedIndex].value;
    }

    var sorted_val_array = val_array.slice().sort();
    var has_duplicates = false;

    for (var i = 0; i < sorted_val_array.length - 1; i++) {
        if (sorted_val_array[i + 1] == sorted_val_array[i]) {
            has_duplicates = true;
        }
    }

    if (!val_array.includes('topic_identifier') || !val_array.includes('topic_name') || !val_array.includes('max_choosers')) {
        alert("Topic Identifier, Topic Name, and Max Choosers are required columns.");
    } else if (has_duplicates) {
        alert("No two columns can have the same value.");
    } else {
        column_form.submit();
    }
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

