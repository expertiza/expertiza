function alternate(id) {
    if (document.getElementsByTagName) {
        var table = document.getElementById(id);
        var rows = table.getElementsByTagName("tr");
        var displayedRows = [];
        index = 0;
        for (i = 0; i < rows.length; i++) {
            if (rows[i].style.display != 'none' && rows[i].id != "header") {
                displayedRows[index] = rows[i];
                index += 1;
            }
        }
        for (i = 0; i < displayedRows.length; i++) {
            if (i % 2 == 0) {
                displayedRows[i].className = "even";
            } else {
                displayedRows[i].className = "odd";
            }
        }
    }
}

function toggleElement(elementId, linkText, mode='') {
    console.log("mode =" + mode);
    var obj = document.getElementById(elementId);
    if (obj == null) {
        return;
    }
    var bExpand = obj.style.display.length == 0;
    obj.style.display = (bExpand ? 'none' : '');
    if (mode == 'show')
        obj.style.display = ''
    else if (mode == 'hide')
        obj.style.display = 'none'
    var objLinks = document.getElementsByName(elementId + 'Link')
    for (var i = 0; i < objLinks.length; i++) {
        if (obj.style.display != 'none') {
            objLinks[i].innerHTML = 'hide ' + linkText
        }
        else {
            objLinks[i].innerHTML = 'show ' + linkText
        }
    }
}

function toggleAllElement(elementIdList, mode) {
    var res = elementIdList.split(",");
    var childText = 'review';

    for (var y = 0; y < res.length - 1; y++) {
        toggleElement(res[y], childText, mode);
    }

}

function toggleList(elementId, listSize) {
    if (listSize == 0) {
        return;
    }
    for (var i = 1; i <= listSize; i++) {
        var obj = document.getElementById(elementId + "_" + i);
        if (obj == null) {
            return;
        }
        var bExpand = obj.style.display.length == 0;
        obj.style.display = (bExpand ? 'none' : '');
        if (obj.style.display == 'none') {
            var sublistsize = 1;
            while (document.getElementById(obj.id + "_" + sublistsize) != null) {
                sublistsize += 1;
            }
            sublistsize = sublistsize - 1;

            if (sublistsize > 0 && document.getElementById(obj.id + "_" + sublistsize).style.display != 'none')
                toggleList(obj.id, sublistsize);
        }
    }

    var objLinks = document.getElementsByName(elementId + 'Link')
    for (var i = 0; i < objLinks.length; i++) {
        if (obj.style.display != 'none') {
            objLinks[i].innerHTML = '<img src="/assets/collapse.png">'
        }
        else {
            objLinks[i].innerHTML = '<img src="/assets/expand.png">'
        }
    }
}

function toggleCourseList(elementId, child_nodes, child_size, listSize) {
    var child_nodes_no = child_nodes.split(",");
    var child_node_size = child_size.split(",");
    for (var i = 0; i < listSize; i++) {
        if (child_node_size[i] != 0) {
            toggleList(child_nodes_no[i], child_node_size[i]);
        }
    }
    toggleList(elementId, listSize);
}
