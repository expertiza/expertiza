$=jQuery;

$(function () {
    $("[data-toggle='tooltip']").tooltip();
    // Change to this was done as part of E1788_OSS_project_Maroon_Heatmap_fixes
    //
    // scoreTable was assigned to as classes for the table which required to be sortable
    // tablesorter is initialised on all the elements having class scoreTable
    //
    // fix comment end
    $(".scoresTable").tablesorter();
});

var lesser = false;
// Function to sort the columns based on the total review score
function col_sort(m) {
    lesser = !lesser
    // Swaps two columns of the table
    jQuery.moveColumn = function (table, from, to) {
        var rows = jQuery('tr', table);

        var hidden_child_row = table.find('tr.tablesorter-childRow');

        hidden_child_row.each(function () {
            inner_table = jQuery(this).find('table.tbl_questlist')
            hidden_table = inner_table.eq(0).find('tr')


            hidden_table.eq(from - 1).detach().insertBefore(hidden_table.eq(to - 1));
            if (from - to > 1) {
                hidden_table.eq(to - 1).detach().insertAfter((hidden_table.eq(from - 2)));

            }

        });


        var cols;
        rows.each(function () {
            cols = jQuery(this).children('th, td');
            cols.eq(from).detach().insertBefore(cols.eq(to));
            if (from - to > 1) {
                cols.eq(to).detach().insertAfter((cols.eq(from - 1)));

            }
        });
    }

    // Gets all the table with the class "tbl_heat"
    var tables = $("table.tbl_heat");
    // Get all the rows with the class accordion-toggle
    var tbr = tables.eq(m).find('tr.accordion-toggle');
    // Get the cells from the last row of the table
    var columns = tbr.eq(tbr.length - 1).find('td');
    // Init an array to hold the review total
    var sum_array = [];
    // iterate through the rows and calculate the total of each review
    for (var l = 2; l < columns.length - 2; l++) {
        var total = 0;
        for (var n = 0; n < tbr.length; n++) {
            var row_slice = tbr.eq(n).find('td');
            if (parseInt(row_slice[l].innerHTML) > 0) {
                total = total + parseInt(row_slice[l].innerHTML)
            }
        }
        sum_array.push(total)
    }

    // The sorting algorithm
    for (var i = 3; i < columns.length - 2; i++) {
        var j = i;
        while (j > 2 && compare(sum_array[j - 2], sum_array[j - 3], lesser)) {
            var tmp
            tmp = sum_array[j - 3]
            sum_array[j - 3] = sum_array[j - 2]
            sum_array[j - 2] = tmp
            jQuery.moveColumn($("table.tbl_heat").eq(m), j, j - 1);
            // This part is repeated since the table is updated
            tables = $("table.tbl_heat")
            tbr = tables.eq(m).find('tr.accordion-toggle');
            columns = tbr.eq(tbr.length - 1).find('td')
            j = j - 1;

        }
    }
}

// Function to return boolean based on lesser or greater operator
function compare(a, b, less) {
    if (less) {
        return a < b
    } else {
        return a > b
    }
}

// Revisions In MARCH 2021 FOR E2100 Tagging Report for Students Below This Line.


// Initialize Tag Report Heat grid and hide if empty.
function tagActionOnLoad() {
    let tagPrompts = countTags();
    generateTable(tagPrompts);
    // Hide heatgrid on load if no tags or if all tags done.
    if(tagsOnOffTotal(tagPrompts)) {
        document.getElementById("tagHeatMap").style.display = 'none';
    }

}

// Update Tag Report Heat grid each time a tag is changed
function tagActionOnUpdate() {
    let tagPrompts = countTags();
    updateTable(tagPrompts);
    tagsOnOffTotal(tagPrompts);
}

// Count tags and put into a one d vector. Need to refactor to populate as an array.
function countTags() {
    var tagPrompts = document.getElementsByName("tag_checkboxes[]")
    //Go ahead and run the generate table function now. This call needs to be changed.
    // generateTable(tagPrompts);
    return tagPrompts;
    //countTagsByQuestion();
}

/* Handle calculation of number of toggled review tags
   Returns: True if all tags have been clicked; False if more tags available to click.
 */
function tagsOnOffTotal(tagPrompts) {
    var offTags = 0;
    var onTags = 0;
    for (index = 0; index < tagPrompts.length; ++index) {
        if (tagPrompts[index].value == 0) {
            ++offTags;
        } else {
            ++onTags;
        }
    }
    document.getElementById("tagsSuperNumber").innerText = onTags + "/" + tagPrompts.length;
    if(tagPrompts.length == 0 || offTags == 0) return true;
    return false;
}

// Turn on and off the Review Tag heat grid and toggle button text
function toggleTagGrid(elementID) {
    toggleFunction(elementID);
    let button = document.getElementById("tagHGButton")
    if (button.innerText == "Show Tag HeatGrid") {
        button.innerText = "Hide Tag HeatGrid";
    } else {
        button.innerText = "Show Tag HeatGrid";
    }
}

//Currently NON WORKING search by question, then by row, then by tag/no tag per row
function countTagsByQuestion() {
    // get collection of questions
    let questionsArray = document.getElementsByClassName("tbl_questlist");
    let rowArray = new Array();
    // get collection of rows of review by question 0 .. n
    for(i=0;i<questionsArray.length;++i) {
        // rowArray.push(questionsArray.item(i).getElementsByName("tag_checkboxes[]"));
    }
    /*
      let tagArray = new Array();
      let tagExist = new Array();
      //get array of tags by review
      for(i=0;i<rowArray.length;++i) {
          let tempTags = rowArray[i].getElementsByName("tag_checkboxes[]");
          if (tempTags.length == 0) {
              tagArray.push("none");
          }
          else {
              tagArray.push(tempTags);
          }
      }*/
}

// Generates the Review Tag Heat Grid and populates it
function generateTable(tagPrompts) {
    //load table object
    let table = document.getElementById("tagHeatMap");
    //Set up header Labels
    let headerLabels = ["Probs?", "Solns?", "Praise?", "Tone?", "Mitig?"]
    let r = tagPrompts.length / headerLabels.length;
    //create the header
    let thead = table.createTHead();
    let row = thead.insertRow();
    // Create superhead label
    let th = document.createElement("th");
    let text = document.createTextNode("ReviewTags Completed: ");
    th.style.fontSize = "8px";
    th.style.padding = 0;
    th.style.borderSpacing = 0;
    th.setAttribute("id", "tagsSuperLabel");
    th.colSpan = 3;
    th.appendChild(text);
    row.appendChild(th);
    // create superhead numeric
    th = document.createElement("th");
    text = document.createTextNode("0/0");
    th.style.fontSize = "8px";
    th.style.padding = 0;
    th.style.borderSpacing = 0;
    th.setAttribute("id", "tagsSuperNumber");
    th.colSpan = 2;
    th.appendChild(text);
    row.appendChild(th);
    row = thead.insertRow();
    for(index = 0; index < headerLabels.length; ++index) {
        let th = document.createElement("th");
        //Label the header
        let text = document.createTextNode(headerLabels[index]);
        th.style.fontSize = "8px";
        th.style.padding = 0;
        th.style.borderSpacing = 0;
        th.appendChild(text);
        row.appendChild(th);
    }
    //create table body
    for(rIndex = 0; rIndex < r; ++rIndex) {
        let trow = table.insertRow();
        for(cIndex = 0; cIndex < headerLabels.length; ++cIndex) {
            let cell = trow.insertCell();
            //compute 1-d vector indices. Needs to be updated to 2-d
            let vectorIndex = (rIndex * headerLabels.length) + cIndex;
            // set TD tag ids as tag_heatmap_id_rownum_colnum
            let idString = "tag_heatmap_id_" + rIndex + "_" + cIndex;

            cell.setAttribute("id", idString);
            // set initial colors
            let text = document.createTextNode("\u0058");
            if(tagPrompts[vectorIndex].value == 0) {
                // Set color. Should probably be set with a stylesheet class yes?
                // Do we only care about coloring done/not done?
                cell.setAttribute("style", "background-color: red; text-align: center;");

            }
            else {
                // Set color. Should probably be set with a stylesheet class yes?
                // Do we only care about coloring done/not done?
                cell.setAttribute("style", "background-color: green; text-align: center;");
                text.data = "\u2713";
            }
            //add to table
            cell.style.fontSize = "8px";
            cell.appendChild(text);
        }
    }
}

// Updates the Review Tag Heat Grid each time a tag is changed
function updateTable(tagPrompts){
    let headerLength = 5;
    let r = tagPrompts.length / headerLength;
    for(rIndex = 0; rIndex < r; ++rIndex) {
        for (cIndex = 0; cIndex < headerLength; ++cIndex) {
            //compute 1-d vector indices. Needs to be updated to 2-d
            let vectorIndex = (rIndex * headerLength) + cIndex;
            // set TD tag ids as tag_heatmap_id_rownum_colnum
            let cell = document.getElementById("tag_heatmap_id_" + rIndex + "_" + cIndex);
            // set initial colors
            let text = "\u0058";
            if (tagPrompts[vectorIndex].value == 0) {
                // Set color. Should probably be set with a stylesheet class yes?
                // Do we only care about coloring done/not done?
                //cell.setAttribute("style", "background-color: red; text-align: center;");
                cell.style.backgroundColor = "red";
            } else {
                // Set color. Should probably be set with a stylesheet class yes?
                // Do we only care about coloring done/not done?
                //cell.setAttribute("style", "background-color: green; text-align: center;");
                cell.style.backgroundColor = "green";
                text = "\u2713";
            }
            //Update Cell to table
            cell.innerText = text;
        } // for cIndex
    } // for rIndex
} // updateTable()
