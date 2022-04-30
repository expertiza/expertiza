// function teamAssignmentChanged() {
//   var msg = 'Warning! Unchecking this box will hide teams that already exist.'

//   if (jQuery('#assignment_team_assignment').is(':checked')) {
//     jQuery('#assignment_team_count_field').removeAttr('hidden');
//      <% if due_date(@assignment_form.assignment, 'team_formation') %>
//       addDueDateTableElement('team_formation', 0, <%= due_date(@assignment_form.assignment, 'team_formation').to_json.html_safe %>)
//      <% end %>
//   } else {
//     if (confirm(msg)) {
//       jQuery('#assignment_team_count_field').attr('hidden', true);
//       removeDueDateTableElement('team_formation', 0);
//     } else {
//       jQuery('#assignment_team_assignment').prop('checked', true);
//     }
//   }
// }

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
  
  // <% if current_page?(action: 'edit') %>
  // jQuery(document).ready(function () {
  //     // This function determines whether the 'Topics' tab must be displayed when the page is re-loaded
  //     var checkbox = jQuery('#assignment_has_topics');
  //     if (checkbox.is(':checked')) {
  //         // If this checkbox is checked, show the 'Topics' tab
  //         jQuery("#topics_tab_header").show();
  //     } else {
  //         // Otherwise, hide topics tab
  //         jQuery("#topics_tab_header").hide();
  //     }
  // });
  
  // function topicsChanged() {
  //     var msg = 'Warning! Un-checking this box will remove all topics that have been created.';
  //     var checkbox = jQuery('#assignment_has_topics');
  
  //     // E2115 - bind enabled state of mentor checkbox to checked property
  //     // of topics checkbox
  //     var mentorCheckbox = jQuery("#auto_assign_mentor_checkbox");
  //     mentorCheckbox.prop("disabled", checkbox.is(':checked'));
  
  //     if (checkbox.is(':checked')) {
  //         // If this box is checked, display the 'Topics' tab
  //         jQuery("#topics_tab_header").show();
  //         // E2115 - if 'has topics' is checked, uncheck mentor
  //         mentorCheckbox.prop("checked", false);
  //     } else {
  //         if (confirm(msg)) {
  //             // If this box is un-checked, remove all topics and reload page
  //             jQuery.ajax({
  //                 url: '/sign_up_sheet/delete_all_topics_for_assignment',
  //                 method: 'POST',
  //                 data: {
  //                     assignment_id: <%= @assignment.id %>
  //                 },
  //                 success: function() {
  //                     // After topics are deleted, re-load page
  //                     window.location.href = '<%= edit_assignment_path(@assignment.id) %>';
  //                 }
  //             });
  //         } else {
  //             checkbox.prop('checked', true);
  //         }
  //     }
  // }
  // <% end %>
  
  // <!-- Violation of DRY principle, adds input field and handles checkboxes hidden states in other views -->
  // function hasTeamsChanged() {
  //     var msg = 'Warning! Unchecking this box will hide teams that already exist.';
  //     var checkbox = jQuery('#team_assignment');
  //     var team_count_field = jQuery('#assignment_team_count_field');
  //     var teammate_reviews_field = jQuery('#assignment_show_teammate_reviews');
  //     var team_formation_due_date_checkbox = jQuery('#team_formation_due_date_checkbox');
  //     var autoAssignMentorCheckbox = jQuery('#auto_assign_mentor_checkbox');
  
  //     jQuery("#questionnaire_table_TeammateReviewQuestionnaire").remove()
  //     if (checkbox.is(':checked')) {
  //         team_count_field.removeAttr('hidden');
  //         team_formation_due_date_checkbox.removeAttr('hidden')
  //         jQuery('#assignment_form_assignment_max_team_size').val('2');
  //         teammate_reviews_field.removeAttr('hidden');
  //         // E2115 hide auto assign mentor checkbox when an
  //         // an assignment does not have teams
  //         // what would the mentor be assigned to if there are no teams?
  //         autoAssignMentorCheckbox.hide();
  //         addDueDateTableElement(<%= @due_date_nameurl_not_empty==nil ? false:@due_date_nameurl_not_empty %>,'team_formation', 0,<%= due_date(@assignment_form.assignment, 'team_formation').to_json.html_safe %>);
  //     } else {
  //         if (confirm(msg)) {
  //             team_count_field.attr('hidden', true);
  //             team_formation_due_date_checkbox.attr('hidden', true)
  //             teammate_reviews_field.attr('hidden', true);
  //             // E2115 show auto assign mentor checkbox when an
  //             // an assignment has teams
  //             autoAssignMentorCheckbox.show();
  //             document.getElementById('assignment_form_assignment_max_team_size').value = '1';
  //             removeDueDateTableElement('team_formation', 0);
  //         } else {
  //             checkbox.prop('checked', true);
  //         }
  //         if (<%= !@assignment_form.assignment.team_assignment?%>){
  //             team_count_field.attr('hidden', true);
  //         }
  //         } 
  // }
  
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
      // jQuery('#first_submit_tag').add('#second_submit_tag').click(function(e){
      // if(<%= @participants_count == 0 &&  @teams_count == 0 &&  @assignment_form.assignment.max_team_size > 1 %>) {
      //     alert('Please create participants and teams for this assignment before assigning reviewers.');
      //     e.preventDefault();
      //     e.stopPropagation();
      // }
      // else if(<%= @participants_count == 0 %>){
      //     alert('Please create participants for this assignment before assigning reviewers.');
      //     e.preventDefault();
      //     e.stopPropagation();
      // }
      // else if(<%= @teams_count == 0 %> && <%= @assignment_form.assignment.max_team_size > 1 %>){
      //     alert('Please create teams for this assignment before assigning reviewers.');
      //     e.preventDefault();
      //     e.stopPropagation();
      // }
      // });
  });
  