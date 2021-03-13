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
    //generateTable(tagPrompts);
    let rowData =  countTagsByQuestion();
    drawTagGrid(rowData);

    // Hide heatgrid on load if no tags or if all tags done.
    if(tagsOnOffTotal(tagPrompts)) {
        // Disable for now; Will be replaced with collapsed version.
        //document.getElementById("tagHeatMap").style.display = 'none';
    }
}

// Update Tag Report Heat grid each time a tag is changed
function tagActionOnUpdate() {
    let tagPrompts = countTags();
    let qTagPrompts = countTagsByQuestion();
    updateTagGrid(qTagPrompts);
    tagsOnOffTotal(tagPrompts);
}

// Simple query of all review tags and put references into a one d vector.
function countTags() {
    return document.getElementsByName("tag_checkboxes[]");
}

/* Handle calculation of number of toggled review tags
   Returns: True if all tags have been clicked; False if more tags available to click.
 */
function tagsOnOffTotal(tagPrompts) {
    let offTags = 0;
    let onTags = 0;
    let length = tagPrompts.length;
    let ratio = 0;
    let ratio_class = 0;
    for (let index = 0; index < tagPrompts.length; ++index) {
        if (tagPrompts[index].value == 0) {
            ++offTags;
        } else {
            ++onTags;
        }
    }
    // Compute ratio as decimal
    ratio = onTags / length;
    // Scale ratio to 0 <= ratio <= 4
    ratio_class = ratio*4;
    // increment ratio so the range is 1 <= ratio_class <= 5
    ++ratio_class;
    // round ratio_class down to nearest int for class assignment
    ratio_class = Math.floor(ratio_class);

    // Never show a shade of green if we are less than  100% complete on tags
    if(ratio_class === 4) { --ratio_class; }

    // Get element to be updated
    let cell = document.getElementById("tagsSuperNumber");
    // Set text value with ratio
    cell.innerText = onTags + "/" + tagPrompts.length;
    // Set background color class based on ratio
    cell.className = "c"+ratio_class.toString();

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

// Populate an array with all review rows, their question and review number, whether they have tag prompts,
// and a reference to the tag prompts.
function countTagsByQuestion() {
    // Get all valid review rows
    let rowsList = $("[id^=rr]");
    // Set up matrix of questionNumber, reviewNumber, hasTag?, and pointer to tags if true
    let rowData = new Array(rowsList.length);
    $.each(rowsList, function(i) {
        rowData[i] = new Map();
        // Question Number
        rowData[i].set('question_num', $( this ).data("qnum"));
        // Review Number
        rowData[i].set('review_num',$( this ).data("rnum"));
        // Has tag bool?
        rowData[i].set('has_tag',$( this ).data("hastag"));
        // Reference to tag objects
        if (rowData[i].get('has_tag') == true) {
            rowData[i].set('tag_list', $( this ).find('input[name^="tag_checkboxes"]'));
        }
    });
    return rowData;
}

function addToolTip(element, text) {
    element.setAttribute("data-toggle", "tooltip");
    element.setAttribute("title", text);
}

// Renders the review tag heatgrid table based on the review rowData array.
function drawTagGrid(rowData) {
    //Configure text of tooltip Legend
    let tooltipText = "Color Legend:\nGrey: no tags available\nRed: tag not complete\nGreen: tag complete.";
    let headerTooltipText = "Tag Fraction Color Scaled by:\nRed: 0-30% tags completed\nOrange: 30-60% tags completed\nYellow: 60-99% Tags Completed\nGreen: All tags completed";
    //load table object
    let table = document.getElementById("tag_heat_grid");
    // Set basic table attributes
    //table.setAttribute("class", "scoresTable tbl_heat tablesorter");
    let gridWidth = determineGridWidth(rowData);
    //create the header
    let thead = table.createTHead();
    let row = thead.insertRow();
    row.setAttribute("class", "hide-scrollbar tablesorter-headerRow");
    // Create "Tags Completed:" Cell
    let th = document.createElement("th");
    let text = document.createTextNode("\u2195 Tags Completed");
   // th.setAttribute("class", "sorter-false tablesorter-header tablesorter-headerUnSorted");
    th.setAttribute("id", "tagsSuperLabel");
    th.colSpan = 3;
    addToolTip(th, "Click to collapse/expand");
    th.appendChild(text);
    row.appendChild(th);
    // create "# / #" Cell showing number of completed tags (initialize as 0 / 0 for now)
    th = document.createElement("th");
    text = document.createTextNode("0/0");
   // th.setAttribute("class", "sorter-false tablesorter-header tablesorter-headerUnSorted");
    th.setAttribute("id", "tagsSuperNumber");
    th.colSpan = 2;
    addToolTip(th, headerTooltipText);
    th.appendChild(text);
    row.appendChild(th);
    row.setAttribute("onClick", "toggleHeatGridRows()");
/*    // Create action row 1 "Show Only Incomplete Criteria"
    row = thead.insertRow();
    row.id = "incompleteActionRow";
    row.className = "action_row";
    row.setAttribute("onClick", "heatGridShowIncomplete()");
    row.textContent = "Map Incomplete Tags \U+25BC";
    // Create action row 2 "Show All Criteria"
    row = thead.insertRow();
    row.id = "allActionRow";
    row.className = "action_row";
    row.setAttribute("onClick", "heatGridShowAll()");
    row.textContent = "Map All Tags \U+25BC";*/



/*   Removed top row labels 3/11/21 to make grid more flexible for future changes in tag quantity

 row = thead.insertRow();
    for(index = 0; index < headerLabels.length; ++index) {
        let th = document.createElement("th");
        //Label the header
        let text = document.createTextNode(headerLabels[index]);
        th.setAttribute("class", "sorter-false tablesorter-header tablesorter-headerUnSorted");
        th.appendChild(text);
        row.setAttribute("class", "hide-scrollbar tablesorter-headerRow");
        row.appendChild(th);
    }*/



    //create table body
    let tbody = table.appendChild(document.createElement('tbody'));
    let priorQuestionNum = -1;
    for(let rIndex = 0; rIndex < rowData.length; ++rIndex) {
        let trow = tbody.insertRow();
        // Handle the backend inconsistency, Question Indices start with One and Review Indices start with Zero
        let questionNum = rowData[rIndex].get('question_num');
        let reviewNum = rowData[rIndex].get('review_num') + 1;
        // If this is a new question number, add a row indicating a new question.
        if(questionNum !== priorQuestionNum) {
            // Update prior question index
            priorQuestionNum = questionNum;
            // Draw a "Question: # " Row that spans all columns
            let cell = trow.insertCell();
            cell.colSpan = gridWidth;
            cell.className = "tag_heat_grid_criterion";
            //data-toggle="tooltip" title="Color Legend: Grey indicates no tags available, Red indicates tag not complete, Green indicates tag complete."
            addToolTip(cell, tooltipText);
            //cell.style.textAlign = "center";
            //cell.style.fontSize = "9px";
            //trow.className = "tag_hg_row";
            trow.id = "hg_row" + questionNum + "_" + reviewNum;
            trow.setAttribute("data-questionnum", questionNum);
            let text = document.createTextNode("Criterion # " + questionNum);
            cell.appendChild(text);
            // Initialize new row to be used by the inner loop for reviews.
            trow = tbody.insertRow();
            let temp = reviewNum - 1;
            trow.id = "hg_row" + questionNum + "_" + temp;
        }
        //trow.className = "tag_hg_row";
        trow.id = "hg_row" + questionNum + "_" + reviewNum;
        trow.setAttribute("data-questionnum", questionNum);
        for(let cIndex = 0; cIndex < gridWidth; ++cIndex) {
            let cell = trow.insertCell();
            // Set the text value of the grid cell
            let text = document.createTextNode( "R." + reviewNum);
            // If review doesn't have tag prompts
            if(rowData[rIndex].get('has_tag') == false){
                cell.setAttribute("class", "c0");
             //   cell.setAttribute("style", "text-align: center;");
            }
            else
            {
                let idString = "tag_heatmap_id_" + rIndex + "_" + cIndex;
                cell.setAttribute("id", idString);
               // cell.setAttribute('onClick', 'gotoTagPrompt(' + rowData[rIndex][3][cIndex].id + ')');
                if(rowData[rIndex].get('tag_list').get(cIndex).value == 0) {
                    // Set color as failing
                    cell.setAttribute("class", "c1");
                 //   cell.setAttribute("style", "text-align: center;");
                }
                else {
                    // Set color as successful
                    cell.setAttribute("class", "c5");
                //    cell.setAttribute("style", "text-align: center;");
                }
            }
            //add to table
          //  cell.style.fontSize = "8px";
            cell.appendChild(text);
            addToolTip(cell, tooltipText);
        }
    }
}

// Updates the Review Tag Heat Grid each time a tag is changed
function updateTagGrid(rowData){
    let headerLength = 5;
    for(rIndex = 0; rIndex < rowData.length; ++rIndex) {
        if (rowData[rIndex].get('has_tag') == true) {
            for (cIndex = 0; cIndex < headerLength; ++cIndex) {
                // set TD tag ids as tag_heatmap_id_rownum_colnum
                let cell = document.getElementById("tag_heatmap_id_" + rIndex + "_" + cIndex);
                if (rowData[rIndex].get('tag_list').get(cIndex).value == 0) {
                    // Set color as NOT completed.
                    cell.setAttribute("class", "c1");
                } else {
                    // Set color as COMPLETED.
                    cell.setAttribute("class", "c5");
                } //else
            } // for cIndex
        } // if rowData
    } // for rIndex
} // updateTable()


//Scroll to a tag entry prompt on click from the heatgrid
function gotoTagPrompt(tagPrompt) {
    // expand accordions to make scroll work
/*    let accordionable = document.getElementsByClassName("accordion-body collapse");
    for (i=0;i<accordionable.length;++i) {

        accordionable[i].setAttribute('accordion-body collapsearia-expanded', 'true');
    }*/
    //scroll to clicked tag prompt
    tagPrompt.scrollIntoView();
}

// Find the largest number of tags in a review, if any exist, and return the width that the grid should be drawn to.
function determineGridWidth(rowData) {
    let gridWidth = 0;
    for(let i=0; i<rowData.length; ++i) {
        if(rowData[i].get('has_tag') == true && rowData[i].get('tag_list').length > gridWidth) {
            gridWidth =  rowData[i].get('tag_list').length;
        }
    }
    return gridWidth;
}

// Expand only criteria with incomplete tags
function heatGridShowIncomplete(){
    let rowData = countTagsByQuestion();
    let incompleteQuestions = new Array();
    for(let i=0; i < rowData.length; ++i) {
        if(rowData[i][2] === true){
            for(let tag in rowData[i][3]){
                if(tag.value == 0) {
                    incompleteQuestions.push(i);
                }
            }
        }
    }
    for(let i = 0; i<incompleteQuestions.length; ++i) {
        let j = i+1; // Account for Criteria being indexed from 1 .. n
        // hide all rows first
        $("[id^=hg_row]").each(function() {
            $(this).css("display", "none");
        });
        $("[id^=hg_row]").each(function() {
            if($( this ).data("questionnum") === j) {
                $( this ).css("display", "");
            }
        });
    }
}

function heatGridShowAll() {
    //let rowsList = $("[id^=hg_row]");

    $("[id^=hg_row]").each(function () {
        $( this ).css("display", "");
            //.style.display = 'block';
    });
}

function toggleHeatGridRows() {
/*    let header = $("[id=tagsSuperLabel]");
    if(header.innerText === "\u25B2 Tags Completed: ") {
        header.innerText = "\u25BC Tags Completed: "
    }
    else{
        header.innerText = "\u25B2 Tags Completed: ";
    }*/

    $("[id^=hg_row]").each(function () {
        if($( this ).css("display") === "none") {
            $( this ).css("display", "");
        }
        else {
            $( this ).css("display", "none");
        }
        //.style.display = 'block';
    });
}

function hide(element) {
    element.style.display = 'none';
}