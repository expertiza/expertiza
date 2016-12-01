jQuery(document).ready(function($) {
  const fbOptions = {
    subtypes: {
      text: ['datetime']
    },
    onSave: function(formData) {
      toggleEdit();
      $('.render-wrap').formRender({formData});
      window.sessionStorage.setItem('formData', JSON.stringify(formData));
    },
    dataType: 'json', // use json as data format 
    stickyControls: true, // allow the question selector to follow the scroll
    sortableControls: false, // can not swap questions 
    disableFields: ['autocomplete', 'button', 'paragraph', 'number', 
		    'date', 'file', 'hidden'], // disabled fileds
    editOnAdd: true, // allow editing after adding to the stage
    showActionButtons: false // get rid of 'save', 'clear', 'data' buttons
  };
    
  let formData = window.sessionStorage.getItem('formData');
  let editing = true;

  /**
   * Toggles the edit mode for the demo
   * @return {Boolean} editMode
   */
  function toggleEdit() {
    document.body.classList.toggle('form-rendered', editing);
    return editing = !editing;
  }

  const formBuilder = $('.build-wrap')
                      .formBuilder(fbOptions)
                      .data('formBuilder');

  document.getElementById('edit-form').onclick = function() {
    toggleEdit();
  };

  document.getElementById('get-data').onclick = function() {
    console.log(formBuilder.actions.getData());
  };
});
