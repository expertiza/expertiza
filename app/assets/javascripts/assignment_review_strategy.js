function hasReviewChanged() {
    var checkbox = jQuery('#review');
    var reviews_allowed_field = jQuery('#reviews_allowed');
    if (checkbox.is(':checked')) {
        reviews_allowed_field.removeAttr('hidden');
        jQuery('#assignment_form_assignment_num_reviews_allowed').val('<%=@assignment_form.assignment.num_reviews_allowed ||= 3%>');
    } else {
        reviews_allowed_field.attr('hidden', true);
        jQuery('#assignment_form_assignment_num_reviews_allowed').val('-1');
    }
}
function hasDutiesChanged() {
    var checkbox = jQuery('#is_duty_checkbox');
    var add_duties_div = jQuery('#add_duties');

    if (checkbox.is(':checked')) {
        add_duties_div.removeAttr('hidden');
    }
    else {
        add_duties_div.attr('hidden', true);
    }
}
jQuery(document).ready(function () {
    var has_teams_checkbox = jQuery('#team_assignment');
    var duty_assignment_chkbx =  jQuery('#duty_assignment_chkbx')
    if (has_teams_checkbox.is(':checked')) {
        duty_assignment_chkbx.removeAttr('hidden');
    } else {
        duty_assignment_chkbx.attr('hidden', true);
    }
})