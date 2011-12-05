/**
 * It's necessary to use "jQuery" rather than "$" since "$" has been claimed by Prototype
 */
jQuery(function() {
    /**
     * Removes the unsaved "temp" assignments added by the user when creating or editing a course
     */
    function removeTempAssignments() {
        jQuery("#assignmentsWrapper").children("p").filter(function(){
            return jQuery(this).find("input[id$='id']").length < 1;
        }).remove();
    }

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
            removeTempAssignments();
            jQuery("#addAssignmentsWrapper").hide();
        }
    });

    /**
     * Handles when a user enters a value for the min number of unique pairings
     * by showing the interface to add assignments.
     */
    jQuery("#course_min_unique_pairings").keyup(function() {
        var val = jQuery(this).val();
        var show = val.length > 0 && parseInt(val) !== 0;
        jQuery("#addAssignmentsWrapper").toggle(show);

        if(!show) {
            removeTempAssignments();
        }
    });

    var allowedCodes = [8,9,13,37,38,39,40,46];

    /**
     * Returns true if the key being pressed is numeric or has a keycode in the
     * allowedCodes array, false otherwise.
     * @param e: the mouse event
     */
    function onlyAllowNumericInput(e) {
        var modifiers = (e.altkey || e.shiftKey || e.ctrlKey || e.metaKey);

        if((!modifiers && e.keyCode >= 48 && e.keyCode <= 57) || allowedCodes.indexOf(e.keyCode) > -1) {
            return true;
        }
        e.preventDefault();
        return false;
    }

    /**
     * The following binding make the text boxes only accept numeric input
     */
    jQuery("#course_max_duplicate_pairings,#course_min_unique_pairings").keydown(onlyAllowNumericInput);
    jQuery("input[id$='team_count']").live('keydown',onlyAllowNumericInput);

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
                '<input type="text" id="assignment' + i + '_team_count" name="assignment' + i + '[team_count]"  class="numeric" /> ' +
                '<a href="#" class="deleteAssignment"><img src="/images/delete.png" /></a>' +
            '</p>');
    });
});