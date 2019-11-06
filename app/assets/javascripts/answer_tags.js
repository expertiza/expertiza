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
    if (val < 0) {
        $('#' + no_text_id).attr('class', 'toggle-false-msg textActive');
        $('#' + yes_text_id).attr('class', 'toggle-true-msg');
    } else if (val == 0) {
        $('#' + no_text_id).attr('class', 'toggle-false-msg');
        $('#' + yes_text_id).attr('class', 'toggle-true-msg');
    } else if (val > 0) {
        $('#' + no_text_id).attr('class', 'toggle-false-msg');
        $('#' + yes_text_id).attr('class', 'toggle-true-msg textActive');
    }
}

/**
 * Updates the tag count on the page when a tag is changed
 * E1953 
 * http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2019_-_E1953._Tagging_report_for_student
 */
update_tag_count = function(tag_prompt, round_number) {
    //This is the new value of the tag
    var val = tag_prompt.value;
    console.log("val: " + val);
    //This is the current tag count for the round this tag is in
    var current_count = $('#tag_counts_' + (round_number - 1)).innerHTML;
    console.log("current_count: " + current_count);
    if(val == 0) {
      //The user has reset the value of this tag. Decrement the tag count
      $('#tag_counts_' + round_number).innerHTML = current_count - 1;
    } else {
      //The user has set the value of this tag to something meaningful. Increment the count
      $('#tag_counts_' + round_number).innerHTML = current_count + 1;
    }
}
