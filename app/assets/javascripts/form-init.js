//= require vendor.min
//= require form-builder.min
//= require form-render.min

function getFieldsForEdit(){
	var fieldMap = {"Scale": "radio-group", 
					"Dropdown": "select", 
					"Checkbox": "checkbox",
                  "TextArea" : "textarea", 
				  "TextField": "text", 
				  "SectionHeader" : "header",
                  "Criterion": "criterion"};

  var questionsData = $('.questions_class').data().questions;
  var length = questionsData.length;
  //console.log(length);
  //console.log(questionsData);

  var defaultFields = [];
  for(var i=0; i<length; i++){
       var obj = {};
       var type = fieldMap[questionsData[i].type];
       obj["type"] = type;
       obj["label"] = questionsData[i].txt;
       //obj["id"] = questionsData[i].questionnaire_id;
       obj["order"] = questionsData[i].seq;

       switch(type){
          case "criterion": {
              break;
          }
          case "text":{
              obj["maxlength"] = questionsData[i].size;
              break;
          }
          case "textarea":{
              var rc = questionsData[i].size.split(', ');
              obj["maxlength"] = rc[0];
			  obj["rows"] = rc[1];
              obj["values"] = ""; 
              break;
          }
          case "select":{
              var options = questionsData[i].alternatives ? questionsData[i].alternatives.split("|") : [];
              var vals = [];
              for(var j=0; j<options.length; j++){
                  var valObj = {};
                  valObj["label"] = options[j];
                  valObj["value"] = options[j];
                  vals.push(valObj);
              }
              obj["values"] = vals;
              break;
          }
          case "checkbox":{
              break;
          }
          case "radio-group":{
              obj["multiple"] = true;
              var values = [{
                  label: questionsData[i]["min_label"],
                  value: questionsData[i]["min_label"]
                }, {
                  label: 1,
                  value: 1
                }, 
                {
                  label: 2,
                  value: 2
                }, 
                {
                  label: 3,
                  value: 3
                }, 
                {
                  label: questionsData[i]["max_label"],
                  value: questionsData[i]["max_label"]
                }];
              obj["values"] = values;
              break;
          }
          default: break;
      } // end of switch
      defaultFields.push(obj);
  } // end of for 
  return defaultFields;
}

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
				//alert('quit editing');
				setEdit(elmt, false);
				onUpdate(elmt);  
			}
			else
			{
				//alert('start editing');
				setEdit(elmt, true);
			}
			});
		});
			
		$('a[id^="del_"]').off('click').on('click', function(e) {
			onRemove($(this).parents('li'));
		});

		// remove unwanted input fields from form
		removeUnwantedFields();
		
		// change labels
		$('.label-wrap').find('label').text('Question');

		// remove certain fields in the form depending on the field type
    };

	var fieldReverseMap = {"radio-group": "Scale", "select": "Dropdown", "checkbox": "Checkbox",
							"textarea": "TextArea", "text": "TextField", "header": "SectionHeader",
						    "criterion": "Criterion"};

    // !!!
    // fill the remove_question form
    // remove from db and hidden form
    var onRemove = function(fld) {
		var order = $(fld).attr('id').split('-')[3];
		var _tr = $('#questions_table').find('tr')[order];
		var _td = $(_tr).find('td')[0];
		
		setTimeout(function() {
			$('.button-wrap').find('button.yes').on('click', function(){
				//console.log('yes..');
				$(_td).find('a')[0].click();
			});
		}, 100);
	};
    
    // save to db and hidden form
    var onSave = function() {};
    
    // update question
	var onUpdate = function(fld) { 
		var _li = $(fld).parent('div').parent('li');
		var order = $(_li).attr('id').split('-')[3];
		var type = $(_li).attr('type');
		var _tr = $('#questions_table').find('tr')[order];
		// update tr fields with the data in _li
		updateHiddenFields(_li, type, _tr);
	};
 
 	var defaultFields = getFieldsForEdit();
	console.log(defaultFields);

	var onAddHandler = {
		onadd: function(fld)
		{
			disableFormEditorFields(fld);
			var userDrop = false;
			if($(fld).attr('id').split('-')[3] > defaultFields.length){
				// user drops
				userDrop = true;
			}

			// user drags and drops the elements
			if(userDrop){
				$("#question_type").val(fieldReverseMap[$(fld).attr('type')]);
				$("#addQuestionBtn").trigger('click');	
			} else{
				// don't do anything, loading the fields on edit
			}
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
			    'paragraph', 'number', 'checkbox-group', 
			    'date', 'file', 'hidden', 'header'], 
	    editOnAdd: false, 
	    showActionButtons: true, 
		defaultFields: defaultFields, // edit will load the fields from db
		fieldRemoveWarn: true,
	    typeUserEvents: {
			'checkbox': onAddHandler,
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

function updateHiddenFields(li, type, tr){
	console.log(li);
	console.log(type);
	console.log(tr);

	var _form = $(li).find('.frm-holder');
	console.log(_form);

	switch(type){
		case "criterion": {
			break;
		}
		case "text":{
			var _question = $(_form).find('.label-wrap').find('input[type="text"]').val();
			var _maxlen = $(_form).find('.maxlength-wrap').find('input[type="number"]').val();
			console.log(_question);
			console.log(_maxlen);
			//update in tr
			var _q = $(tr).find('td')[2];
			var _m = $(tr).find('td')[5];
			$(_q).find('textarea').val(_question);
			$(_m).find('input[type="text"]').val(_maxlen);
			break;
		}
		case "textarea":{
			var _question = $(_form).find('.label-wrap').find('input[type="text"]').val();
			var _maxlen = $(_form).find('.maxlength-wrap').find('input[type="number"]').val();
			var _rows = $(_form).find('.rows-wrap').find('input[type="number"]').val();
			console.log(_question);
			console.log(_maxlen);
			console.log(_rows);
			//update in tr
			var _q = $(tr).find('td')[2];
			var _m = $(tr).find('td')[5];
			$(_q).find('textarea').val(_question);
			$(_m).find('input[type="text"]').val(_maxlen + ", "+ _rows);
			break;
		}
		case "select":{
			var _question = $(_form).find('.label-wrap').find('input[type="text"]').val();
			// console.log(_question);
			var _options = $(_form).find('.field-options').find('ol.sortable-options');

			var alternatives = "";
			$(_options).find('li').each(function(){
				var _li = $(this);
				var optn = $(_li).find('input')[1];
				alternatives += $(optn).val();
				alternatives += "|";
			});
			alternatives = alternatives.substr(0, alternatives.length-1);
			// console.log(alternatives);
			//update in tr
			var _q = $(tr).find('td')[2];
			var _m = $(tr).find('td')[5];
			$(_q).find('textarea').val(_question);
			$(_m).find('input[type="text"]').val(alternatives);
			break;
		}
		case "checkbox":{
			var _question = $(_form).find('.label-wrap').find('input[type="text"]').val();
			console.log(_question);
			//update in tr
			var _q = $(tr).find('td')[2];
			$(_q).find('textarea').val(_question);
			break;
		}
		case "radio-group":{
			var _question = $(_form).find('.label-wrap').find('input[type="text"]').val();
			// console.log(_question);
			var _options = $(_form).find('.field-options').find('ol.sortable-options');
			var _liCount = $(_options).find('li').length;
			console.log(_liCount);

			var _firstli = $(_options).find('li')[0];
			var _lastli = $(_options).find('li')[_liCount-1];
			
			var firstInp = $(_firstli).find('input')[1];
			var lastInp = $(_lastli).find('input')[1];
			
			var min_label = $(firstInp).val();
			var max_label = $(lastInp).val();
			
			//console.log(min_label);
			//console.log(max_label);
			//update in tr
			var _q = $(tr).find('td')[2];
			var _m = $(tr).find('td')[5];
			var f1 = $(_m).find('input[type="text"]')[0];
			var f2 = $(_m).find('input[type="text"]')[1];

			$(_q).find('textarea').val(_question);
			$(f1).val(max_label);
			$(f2).val(min_label);
			break;
		}
		default: break;
	}
}

function removeUnwantedFields(){
	switch(fld){
			case "criterion": {
			break;
		}
		case "text":{
			if ($('.required-wrap').length > 0) $('.required-wrap').remove();
			if($('.description-wrap').length > 0) $('.description-wrap').remove();
			if($('.className-wrap').length > 0) $('.className-wrap').remove();
			if($('.name-wrap').length > 0) $('.name-wrap').remove();
			if($('.access-wrap').length > 0) $('.access-wrap').remove();
			if($('.placeholder-wrap').length > 0) $('.placeholder-wrap').remove();
			if($('.value-wrap').length > 0) $('.value-wrap').remove();
			break;
		}
		case "textarea":{
			if ($('.required-wrap').length > 0) $('.required-wrap').remove();
			if($('.description-wrap').length > 0) $('.description-wrap').remove();
			if($('.className-wrap').length > 0) $('.className-wrap').remove();
			if($('.name-wrap').length > 0) $('.name-wrap').remove();
			if($('.access-wrap').length > 0) $('.access-wrap').remove();
			if($('.placeholder-wrap').length > 0) $('.placeholder-wrap').remove();
			if($('.value-wrap').length > 0) $('.value-wrap').remove();
			break;
		}
		case "select":{
			if ($('.required-wrap').length > 0) $('.required-wrap').remove();
			if($('.description-wrap').length > 0) $('.description-wrap').remove();
			if($('.className-wrap').length > 0) $('.className-wrap').remove();
			if($('.name-wrap').length > 0) $('.name-wrap').remove();
			if($('.access-wrap').length > 0) $('.access-wrap').remove();
			if($('.placeholder-wrap').length > 0) $('.placeholder-wrap').remove();
			if($('.value-wrap').length > 0) $('.value-wrap').remove();
			break;
		}
		case "checkbox":{
			if ($('.required-wrap').length > 0) $('.required-wrap').remove();
			if($('.description-wrap').length > 0) $('.description-wrap').remove();
			if($('.className-wrap').length > 0) $('.className-wrap').remove();
			if($('.name-wrap').length > 0) $('.name-wrap').remove();
			if($('.access-wrap').length > 0) $('.access-wrap').remove();
			if($('.value-wrap').length > 0) $('.value-wrap').remove();
			if($('.toggle-wrap').length > 0) $('.toggle-wrap').remove();
			break;
		}
		case "radio-group":{
			if ($('.required-wrap').length > 0) $('.required-wrap').remove();
			if($('.description-wrap').length > 0) $('.description-wrap').remove();
			if($('.className-wrap').length > 0) $('.className-wrap').remove();
			if($('.name-wrap').length > 0) $('.name-wrap').remove();
			if($('.access-wrap').length > 0) $('.access-wrap').remove();
			if($('.placeholder-wrap').length > 0) $('.placeholder-wrap').remove();
			if($('.multiple-wrap').length > 0) $('.multiple-wrap').remove();
			break;
		}
		default: break;
		}
}