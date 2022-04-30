$ = jQuery;

jQuery(document).ready(function () {
    
    jQuery("#submit_btn").click(function(e) {
        var max_team_size = jQuery('#assignment_form_assignment_max_team_size').val();
        if (max_team_size == '1' && jQuery('#team_assignment').is(':checked')) {
            alert("Maximum number of members per team must be greater than 1!");
            e.preventDefault()
        }
    })

    jQuery("#tabs").tabs({
        // Changing from one tab to another is sort of like a "save" action
        beforeActivate: function (event, ui) {
            var deleteTeam = 0;
            var frm = jQuery("#assignment_form");
            var max_team_size = jQuery('#assignment_form_assignment_max_team_size').val();
            if (max_team_size == '1' && jQuery('#team_assignment').is(':checked')) {
                deleteTeam = 1;
                alert("Maximum number of members per team must be greater than 1!");
            }
            if (deleteTeam == 0) {
                jQuery.ajax({
                url: frm.attr('action'),
                method: frm.attr('method'),
                data: frm.serialize(),
                success: function(data, textStatus, xhr){
                // REFRESH the topics tab after changing tabs
                // Specifically useful when switching between vary-do-not-vary by topic on the Rubrics tab
                // This changes how the Topics tab should appear
                // We only refresh the Topics tab if that is the tab we are switching to
                // Followed instructions at:
                // https://atlwendy.ghost.io/render-a-partial-view-tutorial-for-beginners/
                    if (ui.newPanel.attr('id') == 'tabs-2') {
                    jQuery("#tabs-2").html(data);
                    }
                },
            });
            // Update the flash messages onscreen
            // we are performing an action that could result in important info put in flash,
            // but we will not see this without requesting it explicitly because we don't do a full page re-load
            
            jQuery.ajax({
                url: "/assignments/instant_flash",
                method: "get",
                data: "",
                success: function(data, textStatus, xhr){
                    jQuery("#application-flash-div").html(data);
                },
            });
            }else{
                event.preventDefault();
            }
        }   
    });
});

$('#go_to_tabs2').click(function(){
    $('#Rubrics').click();
});

