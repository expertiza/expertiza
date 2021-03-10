function countTotalTags() { //count total number of tags on the page
    var tagPrompts = document.getElementsByName("tag_checkboxes[]")
    return tagPrompts.length
}

function countTaggedTags() { //count finished tags on the page
    var TaggedTags = 0;
    var tagPrompts = document.getElementsByName("tag_checkboxes[]")

    for (index = 0; index < tagPrompts.length; ++index) {
        if (tagPrompts[index].value != 0) {
            TaggedTags++;
        }
    }
    return TaggedTags
}