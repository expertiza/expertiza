// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
/**
 * Created by ferry on 6/26/17.
 */

save_tag = function(answer_id, tag_prompt_deployment_id, control){

    var xmlhttp = new XMLHttpRequest();   // new HttpRequest instance
    xmlhttp.open("POST", "/answer_tags/create_edit");
    xmlhttp.setRequestHeader("Content-Type", "application/json");
    xmlhttp.setRequestHeader("Accept", "application/json");
    xmlhttp.send(JSON.stringify({
        answer_id: answer_id.toString(),
        tag_prompt_deployment_id: tag_prompt_deployment_id.toString(),
        value: control.value.toString()
    }));
}

toggleLabel = function(range) {
    var val = range.value;
    var element_id = range.id.replace("tag_prompt_","")
    var no_text_id = "no_text_" + element_id
    var yes_text_id = "yes_text_" + element_id
    // Changing the value of particular tags dynamically
    if (val < 0) {
        $('#' + no_text_id).attr('class', 'toggle-false-msg textActive');
        $('#' + yes_text_id).attr('class', 'toggle-true-msg');
        $('#' + range.id).attr('value', '-1');
    } else if (val == 0) {
        $('#' + no_text_id).attr('class', 'toggle-false-msg');
        $('#' + yes_text_id).attr('class', 'toggle-true-msg');
        $('#' + range.id).attr('value', '0');
    } else if (val > 0) {
        $('#' + no_text_id).attr('class', 'toggle-false-msg');
        $('#' + yes_text_id).attr('class', 'toggle-true-msg textActive');
        $('#' + range.id).attr('value', '1');
    }

    // gray-out and allow student to override tag
    var toggle = $('#' + range.id);
    if (toggle.attr('class').indexOf('gray-out') >= 0 || toggle.attr('class').indexOf('overridden') >= 0) {
      $('#' + range.id).attr('class', 'rangeAll overridden');
    }
    $('#' + range.id).closest(".toggle-container").find('.toggle-caption').attr('class', 'toggle-caption');
}
