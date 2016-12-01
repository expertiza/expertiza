jQuery(document).ready(function($) {
    // form-builder options
    var fbOptions = {
	subtypes: {
	    text: ['datetime']
	},
	onSave: function(formData) {
	    togglePreivew();
	    $('.render-wrap').formRender({formData});
	    window.sessionStorage.setItem('formData', JSON.stringify(formData));
	},
	dataType: 'json', // use json as data format 
	stickyControls: true, // allow the question selector to follow the scroll
	sortableControls: false, // can not swap questions 
	disableFields: ['autocomplete', 'button', 'paragraph', 'number', 
			'date', 'file', 'hidden'], // disabled fields
	editOnAdd: true, // allow editing after adding to the stage
	showActionButtons: true // get rid of 'save', 'clear', 'data' buttons
    };

    var debug = function(s){
	alert(s);
    }
    
    // form-builder contrutor
    var formBuilder = $('.build-wrap')
        .formBuilder(fbOptions)
        .data('formBuilder');

    debug($('build[id$="-save"]').length);
    // action buttons
    $('button[id$="-save"]').each(function(index, elmt) {
	debug("save");
	$(elmt).html('preview');
	$(elmt).click(function(){alert('save');});
    });

    $('button[id$="-view-data"]').each(function(index, elmt) {
	debug("save");

	$(elmt).remove();
    });

    $('button[id$="-clear-all"]').each(function(index, elmt) {
	debug("clear");

	$(elmt).remove();
    });

    document.getElementById('edit-form').onclick = function() {
	togglePreview();
    };

    // sortable fields
    $('a[id$="-edit"]').each(function(index, elmt) {
	$(elmt).click(function(e) {
	    e.preventDefault();

	    if (editing)
	    {
		alert('quit editing');
		toggleEdit();
	    }
	    else
	    {
		alert('start editing');
		toggleEdit();
	    }
	});
    });
    
    $('a[class$="close-field"]').each(function(index, elmt) {
	$(elmt).remove();
    });

    document.getElementById('get-data').onclick = function() {
	console.log(formBuilder.actions.getData());
    };

    /**
     * Toggles the edit mode 
     * @return {Boolean} editMode
     */
    let editing = false;
    var toggleEdit = function() {
	editing = !editing;
    };
    
    let previewing = true;
    function togglePreview() {
	document.body.classList.toggle('form-rendered', previewing);
	return previewing = !previewing;
    }
  
});
