function microtaskChanged() {
    if (jQuery('#assignment_microtask').is(':checked')) {
  
    } else {
  
    }
  }
  
  //This function replaces whitespace ' ' in assignment name by '_' and assign to directory path field value
  $(function() {
      $("#assignment_form_assignment_name").change(function() {
          filename = $( "#assignment_form_assignment_name" ).val().replace(/ /g,"_").replace(/[/\\?%*:|"<>/$&!#%^@]/g, '');;
          $('#assignment_form_assignment_directory_path').val(filename);
      });
  });
  //E2138 added function
  function autogenerate_submission(){
    assignment_form.assignment.directory_path = assignment_form.assignment.name;
  }
  
  
  function staggeredDeadlineChanged() {
      var msg = 'Warning! Unchecking all topics for this assignment will now have the same deadline.'
      if (!jQuery('#assignment_staggered_deadline').is(':checked')) {
      if (!confirm(msg)) {
          jQuery('#assignment_staggered_deadline').prop('checked', true);
      }
      }
  }
  
  function reviewStrategyChanged() {
      var val = jQuery('#assignment_form_assignment_review_assignment_strategy').val();
      if (val == 'Auto-Selected') {
          jQuery('#assignment_review_topic_threshold_row').removeAttr('hidden');
          jQuery('#instructor_selected_review_mapping_mechanism').attr('hidden', true);
      } else {
          jQuery('#instructor_selected_review_mapping_mechanism').removeAttr('hidden');
          jQuery('#assignment_review_topic_threshold_row').attr('hidden', true);
      }
  }
  
  
  function hasQuizChanged() {
      if (jQuery('#assignment_form[assignment][require_quiz]').is(':checked')) {
      jQuery('#assignment_numbers_of_quiz_field').removeAttr('hidden');
      } else {
      jQuery('#assignment_numbers_of_quiz_field').attr('hidden', true);
      }
  }
  
  function useSimicheckChanged(){
      if (jQuery('#toggle_simicheck_setting').is(':checked')) {
      jQuery('#assignment_simicheck_field').show();
      jQuery('#assignment_simicheck_threshold').show();
      } else {
      jQuery('#assignment_simicheck_field').hide();
      jQuery('#assignment_simicheck_threshold').hide();
      }
  }
  
  jQuery(document).ready(function() {
      jQuery('input[type=radio][name=num_reviews]').change(function(){
      if (this.value == 'student'){
          jQuery('#num_reviews_per_student_threshold').removeAttr('hidden');
          jQuery('#num_reviews_per_submission_threshold').attr('hidden','hidden');
          jQuery('#calibrated_and_uncalibrated_artifacts_threshold').attr('hidden','hidden');
          jquery('#second_submit_tag').attr('disabled', 'disabled');
          jquery('#third_submit_tag').attr('disabled', 'disabled');
      } 
      else if(this.value == 'submission'){
          jQuery('#num_reviews_per_student_threshold').attr('hidden', 'hidden');
          jQuery('#num_reviews_per_submission_threshold').removeAttr('hidden');
          jQuery('#calibrated_and_uncalibrated_artifacts_threshold').attr('hidden','hidden');
          jquery('#first_submit_tag').attr('disabled', 'disabled');
          jquery('#third_submit_tag').attr('disabled', 'disabled');
      }
      else if(this.value == 'calibrated_and_uncalibrated'){
          jQuery('#num_reviews_per_student_threshold').attr('hidden', 'hidden');
          jQuery('#num_reviews_per_submission_threshold').attr('hidden', 'hidden');
          jQuery('#calibrated_and_uncalibrated_artifacts_threshold').removeAttr('hidden');
          jquery('#first_submit_tag').attr('disabled', 'disabled');
          jquery('#second_submit_tag').attr('disabled', 'disabled');
      }
      });
  });
  