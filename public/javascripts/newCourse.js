/**
 * It's necessary to use "jQuery" rather than "$" since "$" has been claimed by Prototype
 */
jQuery(function() {
    /**
     * Handles when the user chooses to add restrictions on partners
     * by showing the text boxes for max_duplicate_pairings and min_unique_pairings.
     */
    jQuery("#restrictPartners").click(function() {
        var checked = jQuery(this).is(":checked");
        jQuery("#partnerRestrictionsWrapper").toggle(checked);

        if(!checked) {
            jQuery("#course_max_duplicate_pairings").val("");
            jQuery("#course_min_unique_pairings").val("");
            jQuery("#assignmentsWrapper").empty();
            jQuery("#addAssignmentsWrapper").hide();
        }
    });

    /**
     * Handles when a user enters a value for the min number of unique pairings
     * by showing the interface to add assignments.
     */
    jQuery("#course_min_unique_pairings").change(function() {
        var val = jQuery(this).val();
        jQuery("#addAssignmentsWrapper").toggle(val.length > 0 && parseInt(val) !== 0);
    });

    var allowedCodes = [8,9,13,37,38,39,40,46];

    jQuery("#course_max_duplicate_pairings,#course_min_unique_pairings").keydown(function(e){
        var modifiers = (e.altkey || e.shiftKey || e.ctrlKey || e.metaKey);

        if((!modifiers && e.keyCode >= 48 && e.keyCode <= 57) || allowedCodes.indexOf(e.keyCode) > -1) {
            return true;
        }
        e.preventDefault();
        return false;
    });

    /**
     * Handles the delete assignment click by first renaming all the assignments
     * that follow the one being deleted and then deleting it.
     */
    jQuery("#assignmentsWrapper a.deleteAssignment").live("click", function() {
        var pTag = jQuery(this).closest("p");
        var index = pTag.index();

        pTag.nextAll().each(function() {
            jQuery(this).find("input[name^=assignment]").each(function() {
                this.name = this.name.replace(/\d+/, index);

                if(this.id.length > 0) {
                    this.id = this.id.replace(/\d+/, index);
                }
            });
            ++index;
        });

        pTag.remove();
        return false;
    });

    /**
     * Handles when the user clicks the button to add another assignment.
     * Adds the inputs for the new assignment with the naming convention
     * that each assignment has an index in its name. (e.g. assignment0, assignment1, etc)
     */
    jQuery("#plus1Assignment").click(function() {
        var i = jQuery("#assignmentsWrapper > p").length;

        jQuery("#assignmentsWrapper").append(
            '<p>' +
                '<label for="assignment' + i + '_name">Name:</label> ' +
                '<input type="text" id="assignment' + i + '_name" name="assignment' + i + '[name]" /> ' +
                '<label for="assignment' + i + '_team_count">Team Size:</label> ' +
                '<input type="text" id="assignment' + i + '_team_count" name="assignment' + i + '[team_count]" /> ' +
                '<a href="#" class="deleteAssignment"><img src="/images/delete.png" /></a>' +
            '</p>');
    });
});