function getIdPrefix(qs_id) {
    prefix = 'assignment_form[tag_prompt_deployments]['
    if (qs_id != null)
        return prefix + qs_id + ']'
    else
        return prefix + ']'
}

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function metareview_due_date() {
    var metareview = document.getElementById("metareview_due_date_label");
    var dropdownIndex = document.getElementById('metareview_quest').selectedIndex;
    var dropdownValue = document.getElementById('metareview_quest')[dropdownIndex].value;
    if (dropdownValue != "0") {
        metareview.style.display = "";
    } else {
        metareview.style.display = "none";
    }
}

function removeLastTagPromptDropdown(placeholder_id, deleted_input_id) {
    //var id_prefix = 'assignment_form[tag_prompt_deployments]'
    deleted_tag_dep_id = $("#" + placeholder_id + " div:last").find('input[type="hidden"]')[0].value
    html = "<input type='hidden' name='" + deleted_input_id + "' value='" + deleted_tag_dep_id + "' />"
    $("#" + placeholder_id + " div:last").remove()
    $("#" + placeholder_id).append(html)
}

function openAddNewTagPopup() {
    $.colorbox({
        iframe: true,
        href: "../../tag_prompts/view?popup=true",
        opacity: 0.8,
        innerWidth: 800,
        innerHeight: 500,
        transition: "fade",
        onClosed: function () {
            $.ajax({
                dataType: "json",
                url: "../../tag_prompts",
                data: "",
                success: function (tag_prompts) {
                    option = "<option value='none'>---</option><option value='new'>add new..</option>";
                    //put all prompts including the newly added as options, find the highest id to be selected by default
                    //This won't work if it's just an update
                    last_added_id = 0;
                    last_added_index = 0;
                    for (i = 0; i < tag_prompts.length; i++) {
                        if (tag_prompts[i].id > last_added_id) {
                            last_added_id = tag_prompts[i].id;
                            last_added_index = i + 2;
                        }
                        option += "<option value='" + tag_prompts[i].id + "'";
                        option += ">" + tag_prompts[i].prompt + "</option>";
                    }
                    //update all dropdown with the option, restore the selected option, unless for the dropdown that calls the popup
                    $('select[name*="\\[tag_prompt\\]"]').each(function () {
                        s = jQuery(this)
                        s_value = s[0].options[s[0].selectedIndex].value;
                        jQuery(this).empty().append(option);
                        for (i = 0; i < tag_prompts.length; i++) {
                            if (s_value == "new")
                                s[0].selectedIndex = last_added_index;
                            else if (s_value == tag_prompts[i].id.toString())
                                s[0].selectedIndex = i + 2
                        }
                    });
                }
            });
        }
    });
}

async function addTagPromptDropdown(placeholder_id, tag_dep_id, questionnaire_id, tag_prompt_id, question_type, text_len) {
    $("#" + placeholder_id).append("<div id='loading_image'><img src='/assets/loading.gif' /></div>")
    q_types_filled = false
    tag_prompts_filled = false
    if (!q_types) {
        $.ajax({
            dataType: "json",
            url: "../../questions/types",
            data: "",
            success: function (types) {
                q_types = types
                q_types_filled = true
            }
        });
    } else
        q_types_filled = true
    if (!tag_prompts) {
        $.ajax({
            dataType: "json",
            url: "../../tag_prompts",
            data: "",
            success: function (tp) {
                tag_prompts = tp
                tag_prompts_filled = true
            }
        });
    } else
        tag_prompts_filled = true
    while (!(tag_prompts_filled || q_types_filled)) {
        await sleep(2000);
    }
    $('#loading_image').remove()
    var id_prefix = getIdPrefix(questionnaire_id)
    var html = "<table><tr><td><div id='container_" + id_prefix + "'>"
    html += "<input type='hidden' name='" + id_prefix + "[id][]' value='" + tag_dep_id + "'>"
    html += "<div style='float: left;'>Tag prompt</div>"
    html += "<img src='/assets/info.png' title='Tag label that will be shown below the feedback' style='float: left;'/>"
    html += "&nbsp;<select name='" + id_prefix + "[tag_prompt][]' onchange='if (this.selectedIndex == 1)openAddNewTagPopup()' onfocus='if (this.selectedIndex == 1)this.selectedIndex = 0' class='form-control' style='float: left; max-width: 150px;'>"
    html += "<option value='none'>---</option>"
    html += "<option value='new'>add new..</option>"
    for (i = 0; i < tag_prompts.length; i++) {
        html += "<option value=" + tag_prompts[i].id
        if (tag_prompt_id == tag_prompts[i].id)
            html += " selected "
        html += ">" + tag_prompts[i].prompt + "</option>"
    }
    html += "</select>"
    html += "<div style='float: left;'>&nbsp;&nbsp; apply to question type </div>"
    html += "<img src='/assets/info.png' title='The tag prompt will only be shown below the answers of this particular question type. It is useful to exclude types of question that the tags are not relevant to' style='float: left;'/>"
    html += "&nbsp;<select name='" + id_prefix + "[question_type][]' class='form-control' style='float: left;max-width: 150px;'>"
    for (i = 0; i < q_types.length; i++) {
        html += "<option value=" + q_types[i]
        if (q_types[i] == question_type)
            html += " selected "
        html += ">" + q_types[i] + "</option>"
    }
    html += "</select>"
    html += "<div style='float: left;'>&nbsp;&nbsp; comment length threshold </div>"
    html += "<img src='/assets/info.png' title='This is only applicable to textual comments. The tag prompt will only be shown below textual comments whose length exceed the threshold. it is useful to exclude short comments that are not relevant' style='float: left;' />"
    html += "&nbsp;<input type='text' name='" + id_prefix + "[answer_length_threshold][]' size='4' value='" + text_len + "' style='float: left;'/>"
    html += "</div></td></tr></table>"
    $("#" + placeholder_id).append(html)
}