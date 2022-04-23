jQuery(document).ready(function () {
    jQuery("#set_rounds").click(function () {
        changeReviewRounds();
        jQuery("#set_pressed_bool").val(true)
        console.log(jQuery("#set_pressed_bool").val())
        event.preventDefault(); // Prevent link from following its href
    });

    jQuery("#assignment_form_assignment_rounds_of_reviews").change(function () {
        jQuery("#set_pressed_bool").val(false)
        console.log(jQuery("#set_pressed_bool").val())
    });

    //E1654. Improve date-picker and deadlines Code change starts
    //Hide date updater
    $("#date_updater_inner").hide();
    //This on-click function toggles date updater div
    jQuery("#show_date_updater").click(function () {
        $("#date_updater_inner").toggle();
    });
    //The functions below update the required parameter for the assignments that have their check-boxes marked for updation.

    //This function adds days to the date
    jQuery("#addDays_btn").click(function () {
        //calls the function addDaysOrMonth
        addDaysOrMonth(1, "days");
        event.preventDefault();
    });

    //This function removes days from the date
    jQuery("#subDays_btn").click(function () {
        addDaysOrMonth(-1, "days");
        event.preventDefault();
    });

    //E1654. Improve date-picker and deadlines Code change starts

});

function removeDueDateTableElement(deadline_type, round_no) {
    var element_id;
    if (round_no == 0) {
        element_id = '#' + deadline_type;
    } else {
        element_id = '#' + deadline_type + '_round_' + round_no;
    }
    jQuery(element_id).remove();
}

//E1654. Improve date-picker and deadlines Code change starts
//This is a generic funtion to add and substract days and months
function addDaysOrMonth(mul, type) {
    var days = parseInt($('#days').val(), 10); // days variable stores the number of days to change the deadline
    var months = parseInt($('#months').val(), 10);  // days variable stores the number of days to change the deadline
    for (var i = 1; i < jQuery('#due_dates_table>tbody>tr:not(#due_date_heading)').length / 2; i++) {
        if ($('#use_updator_review_round_' + i).is(':checked')) {
            var date = $('#datetimepicker_review_round_' + i).val().split("/");
            // curDate reads the date currently in the field
            var curDate = new Date(parseInt(date[0], 10), parseInt(date[1], 10) - 1, parseInt(date[2].split(" ")[0], 10));
            if (type == "days") {//checks if type is date then sets dates
                curDate.setDate(curDate.getDate() + (days * mul));//sets the date
            } else {
                curDate.setMonth(curDate.getMonth() + (months * mul));//sets the months
            }
            $("#datetimepicker_review_round_" + i).val(curDate.getFullYear() + "/" + (curDate.getMonth() + 1) + "/" + curDate.getDate() + " " + date[2].split(" ")[1]);
        }
        if ($('#use_updator_submission_round_' + i).is(':checked')) {
            var date = $('#datetimepicker_submission_round_' + i).val().split("/");
            var curDate = new Date(parseInt(date[0], 10), parseInt(date[1], 10) - 1, parseInt(date[2].split(" ")[0], 10));
            if (type == "days") {
                curDate.setDate(curDate.getDate() + (days * mul));
            } else {
                curDate.setMonth(curDate.getMonth() + (months * mul));
            }
            $("#datetimepicker_submission_round_" + i).val(curDate.getFullYear() + "/" + (curDate.getMonth() + 1) + "/" + curDate.getDate() + " " + date[2].split(" ")[1]);
        }
    }
}


function createPreviousElement(deadline_type, round_no) {
    var previous_element;
    if (round_no == 0) {
        if (deadline_type == 'team_formation') {
            if (jQuery('#signup').length != 0) {
                previous_element = jQuery("#signup");
            } else {
                previous_element = jQuery('#due_date_heading')
            }
        } else if (deadline_type == 'drop_topic') {
            if (jQuery('#team_formation').length != 0) {
                previous_element = jQuery("#team_formation");
            } else {
                previous_element = jQuery('#signup');
            }
        } else if (deadline_type == 'signup') {
            previous_element = jQuery('#due_date_heading')
        } else {
            previous_element = jQuery('#due_dates_table>tbody>tr:not(#due_date_heading)').last();
        }
        element_id = deadline_type;
        if (jQuery('#' + element_id).length != 0) {
            return
        }
    }
    else {
        if (deadline_type == 'submission') {
            if (round_no == 1) {
                previous_element = jQuery('#due_dates_table>tbody>tr:not(#due_date_heading)').last();
            } else {
                previous_element = jQuery('#review_round_' + (round_no - 1));
            }
        } else if (deadline_type == 'review') {
            previous_element = jQuery('#submission_round_' + round_no);
        } else {
            console.log('error: addDueDateTableElement');
        }
        element_id = deadline_type + '_round_' + round_no;
        if (jQuery('#' + element_id).length != 0) {
            return
        }
    }
}

function jQueryCreations(due_date, element_id) {
    jQuery('#due_date_submission_allowed_id').val(due_date.submission_allowed_id).attr('id', '');
    jQuery('#due_date_review_allowed_id').val(due_date.review_allowed_id).attr('id', '');
    jQuery('#due_date_review_of_review_allowed_id').val(due_date.review_of_review_allowed_id).attr('id', '');
    jQuery('#due_date_quiz_allowed_id').val(due_date.quiz_allowed_id).attr('id', '');
    jQuery('#due_date_teammate_review_allowed_id').val(due_date.teammate_review_allowed_id).attr('id', '');
    jQuery('#due_date_threshold').val(due_date.threshold).attr('id', '');
    jQuery('#due_date_name').val(due_date.deadline_name).attr('id', '');
    jQuery('#due_date_description_url').val(due_date.description_url).attr('id', '');

    jQuery('#datetimepicker_' + element_id).datetimepicker({
        dateFormat: 'yy/mm/dd',
        timeFormat: 'HH:mm:ss z',
        controlType: 'select',
        timezoneList: [
            { value: -000, label: 'GMT' },
            { value: -300, label: 'Eastern' },
            { value: -360, label: 'Central' },
            { value: -420, label: 'Mountain' },
            { value: -480, label: 'Pacific' }
        ]
    });
}
