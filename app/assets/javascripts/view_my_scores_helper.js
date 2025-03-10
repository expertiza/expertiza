/* Added as part of E2100, Tagging Report for Students, March 2021
 * Queries the page for completed tags and sets up the mini-tagging-report on Alternate View
 */

// Count total number of tag prompts on the page
function countTotalTags() {
    var tagPrompts = document.getElementsByName("tag_checkboxes[]");
    return tagPrompts.length;
}

// Count number of tags which have been clicked
function countTaggedTags() {
    var TaggedTags = 0;
    var tagPrompts = document.getElementsByName("tag_checkboxes[]");

    for (index = 0; index < tagPrompts.length; ++index) {
        if (tagPrompts[index].value != 0) {
            TaggedTags++;
        }
    }
    return TaggedTags;
}