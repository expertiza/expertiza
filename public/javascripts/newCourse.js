/**
 * It's necessary to use "jQuery" rather than "$" since "$" has been claimed by Prototype
 */
jQuery(function() {
    /**
     * Handles when the user chooses to add restrictions on partners
     * by showing the text boxes for max_duplicate_pairings and min_unique_pairings.
     */
    jQuery("#restrictPartnersCheckbox").change(function() {
        jQuery("#partnerRestrictionsWrapper").toggle(jQuery(this).is(":checked"));
    });

    /**
     * Handles when a user enters a value for the min number of unique pairings
     * by showing the interface to add assignments.
     */
    jQuery("#course_min_unique_pairings").keyup(function() {
        jQuery("#addAssignmentsWrapper").toggle(jQuery(this).val().length > 0);
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
                if(this.id.length > 0) {
                    this.id = replaceAssignmentNumber(this.id, index);
                }
                this.name = replaceAssignmentNumber(this.name, index);
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
        var id = "assignment" + jQuery("#assignmentsWrapper > p").length;

        var name = '<label>Name: <input type="text" id="' + id + '_name" name="' + id + '[name]" /></label>',
            teamCount = '<label>Team Size: <input type="text" id="' + id + '_team_count" name="' + id + '[team_count]" /></label>',
            isTeam = '<input type="hidden" name="' + id + '[team_assignment]" value="true" />',
            wikiType = '<input type="hidden" name="' + id + '[wiki_type_id]" value="1" />';

        jQuery("#assignmentsWrapper").append('<p>' + name + teamCount + isTeam + wikiType + '<a href="#" class="deleteAssignment"><img src="/images/delete.png" /></a></p>')
    });
});

/**
 * Helper function to re-index the inputs for an assignment.
 * @param identifier
 * @param number
 */
function replaceAssignmentNumber(identifier, number) {
    var i = identifier.search(/[^a-zA-Z0-9]/);
    return "assignment" + number + identifier.substr(i);
}