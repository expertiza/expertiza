jQuery(document).ready(function() {
    
    function teamAssignmentChanged() {

    }

    function microtaskChanged() {
        if (jQuery('#assignment_microtask').is(':checked')) {

        } else {

        }
    }

    function is_coding_assignmentChanged() {
        if (jQuery('#assignment_is_coding_assignment').is(':checked')) {

        } else {

        }
    }

    function hasTeamsChanged() {

    }

    function wikiAssignmentChanged() {
        if (jQuery('#assignment_wiki_assignment').is(':checked')) {
         jQuery('#assignment_wiki_type_field').removeAttr('hidden');
       } else {
         jQuery('#assignment_wiki_type_field').attr('hidden', true);
             jQuery('#assignment_wiki_type').val('1');
       }
    }

    function staggeredDeadlineChanged() {
        var msg = 'Warning! Unchecking all topics for this assignment will now have the same deadline.'
        if (jQuery('#assignment_staggered_deadline').is(':checked')) {
            jQuery('#assignment_days_between_submissions_field').removeAttr('hidden');
        } else {
            if (confirm(msg)) {
                jQuery('#assignment_days_between_submissions_field').attr('hidden', true);
            } else {
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

    var assignmentGeneralInfoTable = React.createClass({
        render: function() {
            var assignmentName = [];
            var courseID = [];
            var submissionDirectory = [];
            var specURL = [];

            return(
                <table id='assignment_general_info_table'>
                    <tr class='heading'>
                        <th width="30%"></th>
                        <th width="70%"></th>
                    </tr>

                    //hidden_field for instructorID, courseID, and assignmentID

                    <tr>
                        <td style='padding:5px'>
                            'Assignment name: '
                        </td>
                        <td style='padding:5px'>
                            <input id="assignment_name" type="text" className="form_control" defaultValue={this.props.assignment_form.assignment.name} width="250">
                        </td>
                    </tr>

                    <tr>
                        <td style='padding:5px'>
                            'Course: '
                        </td>
                        <td style='padding:5px'>
                            //Figure out dropdowns
                        </td>
                    </tr>

                    <tr>
                        <td style='padding:5px'>
                            'Submission Directory: '
                        </td>
                        <td style='padding:5px'>
                            <input id="submission_directory" type="text" className="form_control" defaultValue={this.props.assignment_form.assignment.directory_path} width="250"> (Mandatory field. No space or special chars.)
                            <img src="/assets/info.png" title='- DO NOT change this filed for an on-going assignment. This may cause lost of student submitted file.'>
                        </td>
                    </tr>

                    <tr>
                        <td style='padding:5px'>
                            'Description URL: '
                        </td>
                        <td style='padding:5px'>
                            <input id="spec_url" type="text" className="form_control" defaultValue={this.props.assignment_form.assignment.spec_location} width="250">
                        </td>
                    </tr>

                </table>
                
                )
        } 
    })

    var assignmentGeneralSettingTable = React.createClass({
        render: function() {

            return(
                <table id='assignment_general_settings_table'>
                    <tr class='heading'>
                        <th width="40%">
                        <th width="60%">
                    </tr>
            )
        }
    })

    // more jQuery crap
})