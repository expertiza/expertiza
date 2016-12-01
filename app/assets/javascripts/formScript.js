jQuery(document).ready(function($) {

    var initActionButtons = function()
    {
	$('button[id$="-view-data"]').remove();

	$('button[id$="-clear-all"]').remove();

	var previewing = true,
	togglePreview = function() {
	    document.body.classList.toggle('form-rendered', previewing);
	    previewing = !previewing;
	};

	$('button[id="edit-form"]').click(function() {
	    togglePreview();
	});
	
	$('button[id$="-save"]').each(function(index, elmt) {
	    $(elmt).html('preview');
	    $(elmt).click(function() {
		togglePreview();
		$(renderWrap).formRender({
		    dataType: 'json',
		    formData: formBuilder.formData
		});
		window.sessionStorage.setItem('formData', JSON.stringify(formBuilder.formData));
	    });
	});
    };

    var disableFormEditorFields = function(fld)
    {
	$('a[id$="-copy"]', fld).remove();

	$('a[class$="close-field"]', fld).remove();

	var setEdit = function(elmt, val){
	    $(elmt).data("editing", val);
	};
	
	$('a[id$="-edit"]').each(function(idx, elmt) {
	    
	    $(elmt).data("editing", false);
	    $(elmt).off('click').on('click', function(e) {
		
		e.preventDefault();
		
		console.log($(elmt).data("editing"));
		if ($(elmt).data("editing") === true)
		{
		    alert('quit editing');
		    setEdit(elmt, false);
		    onUpdate(fld);  
		}
		else
		{
		    alert('start editing');
		    setEdit(elmt, true);
		}
	    });
	});
	    
	$('a[id^="del_"]').off('click').on('click', function(e) {

	    e.preventDefault();
	    alert('delete');
	    onRemove(fld);
	});
    };

    // !!!
    // fill the remove_question form
    // remove from db and hidden form
    var onRemove = function(fld) {};
    
    // !!!
    // fill the save_all_questions form
    // save to db and hidden form
    var onSave = function() {};
    
    // !!!
    // update question
    var onUpdate = function(fld) { };
 
    var onAddHandler = {
	onadd: function(fld)
	{
	    disableFormEditorFields(fld);

	    // !!!
	    // get form to add to db
	    // fill form
	    // submit form

	    // fill the hidden form
    	}
    };

    var buildWrap = document.querySelector('.build-wrap'),
	renderWrap = document.querySelector('.render-wrap'),
	formData = window.sessionStorage.getItem('formData'),
	fbOptions = {
	    dataType: 'json',
	    sortableControls: false,
	    editOnAdd: false,
	    stickyControls: true, 
	    sortableControls: false, 
	    disableFields: ['autocomplete', 'button',
			    'paragraph', 'number', 
			    'date', 'file', 'hidden'], 
	    editOnAdd: false, 
	    showActionButtons: true, 
	    typeUserEvents: {
		'checkbox': onAddHandler,
		'checkbox-group': onAddHandler,
		'header': onAddHandler,
		'radio-group': onAddHandler,
		'select': onAddHandler,
		'text': onAddHandler,
		'textarea': onAddHandler
	    }
	};

    var formBuilder = $(buildWrap).formBuilder(fbOptions).data('formBuilder');

    initActionButtons();
    disableFormEditorFields(document);
   
});
