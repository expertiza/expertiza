//= require vendor.min
//= require form-builder.min
//= require form-render.min

function getFieldsForEdit(){
	var fieldMap = {"Scale": "radio-group", "Dropdown": "select", "Checkbox": "checkbox",
                  "TextArea" : "textarea", "TextField": "text", "SectionHeader" : "header",
                  "Criterion": "criterion"};

  var questionsData = $('.questions_class').data().questions;
  var length = questionsData.length;
  console.log(length);
  console.log(questionsData);

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
              obj["size"] = rc[0] * rc[1];
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
                  label: questionsData[i]["min_label"].split(' ')[1],
                  value: questionsData[i]["min_label"].split(' ')[1]
                }, 
                {
                  label: "Neutral",
                  value: "Neutral"
                }, 
                {
                  label: questionsData[i]["max_label"].split(' ')[1],
                  value: questionsData[i]["max_label"].split(' ')[1]
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
			onRemove($(this).parents('li'));
		});
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
				console.log('yes..');
				$(_td).find('a')[0].click();
			});
		}, 100);
	};
    
    // !!!
    // fill the save_all_questions form
    // save to db and hidden form
    var onSave = function() {};
    
    // !!!
    // update question
    var onUpdate = function(fld) { };
 
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
			// !!!
			// get form to add to db
			// fill form
			// submit form

			// fill the hidden form

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
