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
    // Update Heatmap -- Line added March 2021 Project E2100
    if (document.URL.includes("view_team")){ //Only display the heatmap on the view_team page, the update table only happens when conduct tag save action on view_team page.
        tagActionOnUpdate();
    }

    if (document.URL.includes("view_my_scores")){ //On view_my_scores page, no heatmap exists, should not update table, but a simple counter is displayed for tagging progress.
        var total_tags = countTotalTags();
        var tagged_tages = countTaggedTags();
        document.getElementById("tag_stats").innerHTML = "Tag Finished: " + tagged_tages + "/" + total_tags
    }
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
