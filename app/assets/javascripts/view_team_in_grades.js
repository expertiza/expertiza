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
