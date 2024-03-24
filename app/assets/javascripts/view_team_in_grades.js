$ = jQuery;

$(function () {
    // Changed as part of E1788_OSS_project_Maroon_Heatmap_fixes
    // scoreTable was assigned as classes for the table which is required to be sortable
    // tablesorter is initialised on all the elements having class scoreTable
    $("[data-toggle='tooltip']").tooltip();
    $(".scoresTable").tablesorter();
});

// This function receives the clicked metric checkbox as parameter, then it receives the id of that checkbox and queries the table cells which class name corresponding to the id
// Based on the state of the checkbox, it handles the display of the table cells
function onMetricToggle(clicked_metric) {
    if (clicked_metric.checked == true) {
        var hide = false
    } else {
        var hide = true
    }
    var metric_cells = document.getElementsByClassName(clicked_metric.id)
    for (let i = 0; i < metric_cells.length; i++) {
        if (hide == true)
            metric_cells[i].style.display = "none";
        else {
            metric_cells[i].style.display = "table-cell";
        }
    }
}

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
    // Iterate through the rows and calculate the total of each review
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
/**************************** GLOBAL SYMBOLS AND PREFIXES **********************************/

// Symbols added for users who cannot see the R/G Color spectrum well. Note that white spacing is added here as well.
var symNoTag = "  " + "\u2298";        // Unicode Symbol: No Tag (universal "NO" circle-line)
var symTagNotDone = " " + "\u26A0";    // Unicode Symbol: To-do ("Warning" Symbol)
var symTagDone = " " + "\u2714";       // Unicode Symbol: Done (Heavy Check-Mark)

/********************************** ACTION HANDLERS ****************************************/

// Initialize Tag Report Heat grid and hide if empty.
function tagActionOnLoad() {
    // Get an HTMLCollection of all tag prompts on the page
    let tagPrompts = getTagPrompts();

    // Hide heatgrid and stop load action if no tags exist.
    if (tagPrompts.length == 0) {
        document.getElementById("tagHeatMap").style.display = 'none';
    } else {
        // Get a HashMap count of all, on, and off tags, and the ratio of done tags to total in decimal and
        // (special rounding) integer form to associate with existing heatgrid color classes.
        let countMap = calcTagRatio(tagPrompts);

        // Get a HashMap containing all review rows, their round, question, and review numbers, whether they have tags,
        // and a reference to an array containing the tag prompt object references.
        let rowData = getRowData();

        // Generate the dynamic tagging report heatgrid
        drawTagGrid(rowData);

        // Update the "12 out of 250" Cell text and color
        updateTagsFraction(countMap);
    }
}

// Update Tag Report Heat grid each time a tag is changed
function tagActionOnUpdate() {
    // Get an HTMLCollection of all tag prompts on the page
    let tagPrompts = getTagPrompts();

    // Get a HashMap count of all, on, and off tags, and the ratio of done tags to total in decimal and
    // (special rounding) integer form to associate with existing heatgrid color classes.
    let countMap = calcTagRatio(tagPrompts);

    // Update the body of the tagging report (review rows)
    updateTagGrid(tagPrompts);

    // Update the "12 out of 250" cell of the tagging report
    updateTagsFraction(countMap);
}

/********************************** ELEMENT GETTERS ****************************************/

// Simple query of all review tags and put references into a one d vector.
function getTagPrompts() {
    return document.getElementsByName("tag_checkboxes[]");
}

// Populate an array with all review rows, their question and review number, whether they have tag prompts,
// and a reference to the tag prompts.
function getRowData() {
    // Get all valid review rows
    let rowsList = $("[id^=rr]");
    // Set up matrix of questionNumber, reviewNumber, hasTag?, and reference to tags if true
    let rowData = new Array(rowsList.length);
    $.each(rowsList, function (i) {
        rowData[i] = new Map();
        //Round Number
        rowData[i].set('round_num', $(this).data("round"));
        // Question Number
        rowData[i].set('question_num', $(this).data("question_num"));
        // Review Number
        rowData[i].set('review_num', $(this).data("review_num"));
        // Has tag bool?
        rowData[i].set('has_tag', $(this).data("has_tag"));
        // Reference to tag objects
        if (rowData[i].get('has_tag') == true) {
            rowData[i].set('tag_list', $(this).find('input[name^="tag_checkboxes"]'));
        }
    });
    return rowData;
}

/********************************** ELEMENT CHANGERS/UPDATERS ****************************************/

// Updates the tags complete fraction at the top of the tag heat grid
function updateTagsFraction(countMap) {
    // Get element to be updated, Set text of element, and set background color from ratio
    let cell = document.getElementById("tagsSuperNumber");
    cell.innerText = countMap.get("onTags") + " out of " + countMap.get("total");
    cell.className = "c" + countMap.get("ratioClass").toString();

    // If all tags are finished, collapse the heatgrid
    if (countMap.get("ratioClass") === 5) {
        $("[id^=hg_row]").each(function () {
            $(this).css("display", "none");
        });
    } else {
        $("[id^=hg_row]").each(function () {
            $(this).css("display", ""); // open the heatgrid if tags are unfinished
        });
    }
}

// Updates the Review Tag Heat Grid body each time a tag is changed
function updateTagGrid(tagPrompts) {
    for (let i = 0; i < tagPrompts.length; ++i) {
        // Get the heatmap cell associated with this tag
        let tempId = tagPrompts[i].getAttribute("data-tag_heatgrid_id");
        let gridCell = document.getElementById(tempId);

        // Change cell color by class and replace unicode icon
        if (tagPrompts[i].value == 0) {
            gridCell.setAttribute("class", "c1");
            gridCell.innerText = gridCell.innerText.replace(/[\u{0080}-\u{FFFF}]/u, symTagNotDone);
        }
        else {
            gridCell.setAttribute("class", "c5");
            gridCell.innerText = gridCell.innerText.replace(/[\u{0080}-\u{FFFF}]/u, symTagDone);
        }
    }
}

// Expand or collapse the heatgrid rows which make up the Map of tags.
function toggleHeatGridRows() {
    $("[id^=hg_row]").each(function () {
        if ($(this).css("display") === "none") {
            $(this).css("display", "");
        }
        else {
            $(this).css("display", "none");
        }
    });
}

/********************************** ELEMENT/CODE GENERATORS ****************************************/

// Renders the review tag heatgrid table based on the review rowData array.
function drawTagGrid(rowData) {
    //Configure text of tooltip Legend
    let tooltipText = "Color Legend:\nGrey: no tags available\nRed: tag not complete\nGreen: tag complete";
    let headerTooltipText = "Tag fraction color scaled by:\nRed: 0-30% tags completed\nOrange: 30-60% tags completed\nYellow: 60-99% tags completed\nGreen: all tags completed";

    // Handle multi-round reviews and initialize prefix which will become "Round # -- " if multiple rounds
    let numRounds = countRounds(rowData);
    let roundPrefix = "";

    // Load table object and set width attribute
    let table = document.getElementById("tag_heat_grid");
    let gridWidth = getGridWidth(rowData);

    //create the header
    drawHeader(table, headerTooltipText, gridWidth);

    //create table body
    let tBody = table.appendChild(document.createElement('tbody'));

    // Need to keep track of the question number of the previous row generated using priorQuestionNum
    let priorQuestionNum = -1;
    let roundNum = 1;

    // Loop through all review rows, generating appropriate table rows for each
    for (let rIndex = 0; rIndex < rowData.length; ++rIndex) {
        let tRow = tBody.insertRow();
        // Handle the backend inconsistency, Question Indices start with One and Review Indices start with Zero
        let questionNum = rowData[rIndex].get('question_num');
        let reviewNum = rowData[rIndex].get('review_num') + 1;

        // If this review is for a new question number, add a question label row, eg "Round 2 -- Question 3"
        if (questionNum !== priorQuestionNum) {
            let labelRowData = drawQuestionRow(priorQuestionNum, questionNum, roundNum, tRow, gridWidth, tooltipText,
                reviewNum, numRounds, roundPrefix, tBody);
            priorQuestionNum = labelRowData.priorQuestionNum;
            tRow = labelRowData.tRow;
            roundNum = labelRowData.roundNum;
        }

        // Generate a table row for this review containing tag status cells
        drawReviewRow(tRow, questionNum, reviewNum, gridWidth, rowData, rIndex, tooltipText);
    }
}

// Generates the header rows and cells for the tag heatgrid with "Tags Completed # out of #"
function drawHeader(table, headerTooltipText, gridWidth) {
    let tHead = table.createTHead();
    let row = tHead.insertRow();
    row.setAttribute("class", "hide-scrollbar tablesorter-headerRow");

    // Create "Tags Completed:" Cell
    let th = document.createElement("th");
    let text = document.createTextNode("\u2195 Tags Completed");
    th.setAttribute("text-align", "center");
    th.setAttribute("id", "tagsSuperLabel");
    th.colSpan = gridWidth;
    addToolTip(th, "Click to collapse/expand");
    th.appendChild(text);
    row.appendChild(th);
    row.setAttribute("onClick", "toggleHeatGridRows()");

    // create "# out of #" Cell to show number of completed tags
    row = tHead.insertRow();
    th = document.createElement("th");
    text = document.createTextNode("0 out of 0");
    th.setAttribute("id", "tagsSuperNumber");
    th.colSpan = gridWidth;
    addToolTip(th, headerTooltipText);
    th.appendChild(text);
    row.appendChild(th);
    row.setAttribute("onClick", "toggleHeatGridRows()");
}

// Generate a sub-heading heatgrid row, once per question, format: "Round 2 -- Question 3"
function drawQuestionRow(priorQuestionNum, questionNum, roundNum, tRow, gridWidth, tooltipText, reviewNum, numRounds, roundPrefix, tBody) {
    // Determine if this question row belongs to a new round
    if (priorQuestionNum !== -1 && priorQuestionNum > questionNum) {
        ++roundNum;
    }
    // Update prior question index
    priorQuestionNum = questionNum;
    // Draw a "Question: # " Row that spans all columns
    let cell = tRow.insertCell();
    cell.colSpan = gridWidth;
    cell.className = "tag_heat_grid_criterion";
    addToolTip(cell, tooltipText);
    tRow.id = "hg_row" + questionNum + "_" + reviewNum;
    tRow.setAttribute("data-questionnum", questionNum);
    if (numRounds > 1) {
        roundPrefix = "Round " + roundNum + " -- ";
    }
    let text = document.createTextNode(roundPrefix + "Question " + questionNum);
    cell.appendChild(text);
    // Initialize new row to be used by the inner loop for reviews.
    tRow = tBody.insertRow();
    let reviewNumZeroIndex = reviewNum - 1;
    tRow.id = "hg_row" + questionNum + "_" + reviewNumZeroIndex;
    return { priorQuestionNum, tRow, roundNum };
}

// Draws a row of grid cells containing information from a single review's tags.
function drawReviewRow(tRow, questionNum, reviewNum, gridWidth, rowData, rIndex, tooltipText) {
    tRow.id = "hg_row" + questionNum + "_" + reviewNum;
    tRow.setAttribute("data-questionnum", questionNum);
    for (let cIndex = 0; cIndex < gridWidth; ++cIndex) {
        let cell = tRow.insertCell();
        // Set the text value of the grid cell
        let innerText = "R." + reviewNum;
        // If review doesn't have tag prompts
        if (rowData[rIndex].get('has_tag') == false) {
            cell.setAttribute("class", "c0");
            innerText += symNoTag;
        } else {
            let idString = "tag_heatmap_id_" + rIndex + "_" + cIndex;
            cell.setAttribute("id", idString);
            if (rowData[rIndex].get('tag_list').get(cIndex).value == 0) {
                // Set color as failing
                cell.setAttribute("class", "c1");
                innerText += symTagNotDone;
            } else {
                // Set color as successful
                cell.setAttribute("class", "c5");
                innerText += symTagDone;
            }
            rowData[rIndex].get('tag_list').get(cIndex).setAttribute("data-tag_heatgrid_id", idString);
        }
        let text = document.createTextNode(innerText);
        //add to table
        cell.appendChild(text);
        addToolTip(cell, tooltipText);
    }
}

// Adds a tooltip to Element "element" that contains the "text"
function addToolTip(element, text) {
    element.setAttribute("data-toggle", "tooltip");
    element.setAttribute("title", text);
}

/********************************** MATHEMATICS HELPERS ****************************************/

// Find the largest number of tags in a review, if any exist, and return the width that the grid should be drawn to.
function getGridWidth(rowData) {
    let gridWidth = 0;
    for (let i = 0; i < rowData.length; ++i) {
        if (rowData[i].get('has_tag') == true && rowData[i].get('tag_list').length > gridWidth) {
            gridWidth = rowData[i].get('tag_list').length;
        }
    }
    return gridWidth;
}

// Returns as a HashMap the count of all, on, and off tags, and the ratio of done to total in decimal and
// (special rounding) integer form to associate with existing heatgrid color classes.
function calcTagRatio(tagPrompts) {
    let countMap = new Map();
    let offTags = 0;
    let onTags = 0;
    let length = tagPrompts.length;
    let ratio = 0;
    let ratioClass = 0;
    for (let index = 0; index < tagPrompts.length; ++index) {
        if (tagPrompts[index].value == 0) {
            ++offTags;
        } else {
            ++onTags;
        }
    }
    countMap.set("onTags", onTags);
    countMap.set("offTags", offTags);
    countMap.set("total", length);

    // Compute ratio as decimal
    ratio = onTags / length;
    // calculate ratioClass (used in CSS Lookup), and scale ratioClass to 0 <= ratioClass <= 4
    ratioClass = ratio * 4;
    // increment ratio so the range is 1 <= ratio_class <= 5
    ++ratioClass;
    // round ratioClass down to nearest integer
    ratioClass = Math.floor(ratioClass);
    // For our purposes, ratio_class should fall in the range { 1,2,3,5 } (skips class 4).
    if (ratioClass === 4) { --ratioClass; }

    // Add values to the hashmap
    countMap.set("ratioClass", ratioClass);
    countMap.set("ratioDecimal", ratio);
    return countMap;
}

// Determine number of rounds in this review dataset
// For now, because of the broken round numbers in the backend, use changes in question number to find rounds
function countRounds(rowData) {
    let numRounds = 1;
    let questionNum = 1;
    for (const row of rowData) {
        if (row.get('question_num') < questionNum) {
            ++numRounds;
        }
        questionNum = row.get('question_num');
    }
    return numRounds;
}
