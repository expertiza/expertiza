github_token = '<%= @token %>';
$(document).ready(function () {
    $('#tag_prompt_toggler').click(function () {
        if ($('#tag_prompt_toggler').text() == "hide tags")
            $('#tag_prompt_toggler').text("show tags")
        else
            $('#tag_prompt_toggler').text("hide tags")
        $('.tag_prompt_container').toggle();
    });
});

function toggleFunction(elementId) {
    var target = document.getElementById(elementId);
    if (target.style.display === 'none') {
        target.style.display = 'block';
    } else {
        target.style.display = 'none';
    }
}