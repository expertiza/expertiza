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
    //Get the previous value of this tag prompt from an HTML attribute
    var old_value = tag_prompt.attr(data-prev_value)
    //This is the new value of the tag prompt
    var new_value = tag_prompt.value
    //Store the new value back into the HTML attribute
    tag_prompt.attr('data-prev_value', 'new_value')
    //This is the current tag count for the round this tag is in
    var current_count = parseInt(document.getElementById('tag_counts_' + (round_number)).innerHTML);
    if(old_value != "0" && new_value == "0") {
      //The user has reset the value of this tag. Decrement the tag count
      document.getElementById('tag_counts_' + round_number).innerHTML = current_count - 1;
    } else if(old_value == "0" && new_value != "0"){
      //The user has set the value of this tag to something meaningful. Increment the count
      document.getElementById('tag_counts_' + round_number).innerHTML = current_count + 1;
    }
}
