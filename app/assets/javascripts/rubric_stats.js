// Load the Visualization API and the corechart package.
google.charts.load('current', {'packages':['corechart']});

// Set a callback to run when the Google Visualization API is loaded.
google.charts.setOnLoadCallback(drawSingleChart);

// Values set in grades_controller#view
var round_names = <%= @round_names.to_json.html_safe %>;
var criteria_names = <%= @criteria_names.to_json.html_safe %>;
var avg_data = <%= @avg_data.to_json.html_safe %>;
var avg_data_to_compare = <%= @assignment_avg_data.to_json.html_safe %>;
var assignment_names_to_compare = <%= @assignment_names.to_json.html_safe %>;
var assignment_name = <%= @assignment_name.to_json.html_safe %>;
var med_data = <%= @med_data.to_json.html_safe %>;

var source_data = avg_data;

var selected_assignment = 0;

function buildSelectArray(prefix, length) {
    var selected = [];
    for (i = 0; i < length; i++) {
        var eID = prefix+"_"+i+"_selector";
        var selector = document.getElementById(eID);
        selected.push(selector.checked);
    }
    return selected;
}

var selected_round = 0;
function toggleRound(control) {
    selected_round = control.selectedIndex;
    for (var round = 0; round < round_names.length; round++) {
        var roundDiv = document.getElementById("round_"+round+"_criteria");
        var display = null;
        if (round != selected_round) display = "none";
        roundDiv.style.display = display;
    }
    drawChart();
}

var selected_assignment_round = 0;
function toggleAssignmentRound(control) {
    selected_assignment_round = control.selectedIndex;
    renderCompareUI();
}

function renderCompareUI() {
    for (var assignment = 0; assignment < assignment_names_to_compare.length; assignment++) {
        for (var round = 0; round < round_names.length; round++) {
            eID = "assignment_"+assignment+"_round_"+round+"_criteria";
            var roundDiv = document.getElementById(eID);
            var display = null;
            if (assignment != selected_assignment || round != selected_assignment_round) display = "none";
            roundDiv.style.display = display;
        }
    }
    drawChart();
}

function toggleMetric(control) {
    var data = [avg_data, med_data];
    source_data = data[control.selectedIndex];
    drawChart();
}

function toggleAssignment(control) {
    selected_assignment = control.selectedIndex;
    renderCompareUI();
}

// Callback that creates and populates a data table,
// instantiates the column chart, passes in the data and
// draws it.
function drawSingleChart() {
    var selected_criteria = buildSelectArray("round_"+selected_round+"_criterion", criteria_names[selected_round].length);

    // Create the data table.
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'Criteria');
    data.addColumn('number', round_names[selected_round]);
    var rows = [];
    for (criterion = 0; criterion < selected_criteria.length; criterion++) {
        if (!selected_criteria[criterion]) {
            continue;
        }
        var row = [criteria_names[selected_round][criterion]];
        row.push(source_data[selected_round][criterion]);
        rows.push(row);
    }
    data.addRows(rows);
    // Set chart options
    var options = {
        'title':'Class Performance By Criterion',
        'width':700,
        'height':250
    };
    // Instantiate and draw our chart, passing in some options.
    var chart = new google.visualization.ColumnChart(document.getElementById('chart_div'));
    chart.draw(data, options);
}

// Callback that creates and populates a data table,
// instantiates the column chart, passes in the data and
// draws it.
function drawCompareChart() {
    source_data = avg_data;
    var prefix = "assignment_"+selected_assignment+"_round_"+selected_assignment_round+"_criterion";
    var selected_criteria = buildSelectArray(prefix, criteria_names[selected_assignment_round].length);

    // Create the data table.
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'Criteria');
    data.addColumn('number', assignment_name);
    data.addColumn('number', assignment_names_to_compare[selected_assignment]);
    var rows = [];
    for (criterion = 0; criterion < selected_criteria.length; criterion++) {
        if (!selected_criteria[criterion]) {
            continue;
        }
        var row = [criteria_names[selected_assignment_round][criterion]];
        row.push(source_data[selected_assignment_round][criterion]);
        row.push(avg_data_to_compare[selected_assignment][selected_assignment_round][criterion]);
        rows.push(row);
    }
    data.addRows(rows);
    // Set chart options
    var options = {
        'title':'Class Performance By Criterion For ' + round_names[selected_assignment_round],
        'width':700,
        'height':250
    };
    // Instantiate and draw our chart, passing in some options.
    var chart = new google.visualization.ColumnChart(document.getElementById('chart_div'));
    chart.draw(data, options);
}

var drawChart = drawSingleChart;

var tabCount = 2;
function switchToTab(newTab) {
    var chartFuncs = [drawSingleChart, drawCompareChart];
    for (tab = 0; tab < tabCount; tab++) {
        var display = null;
        if (tab != newTab) display = "none";
        var selector = document.getElementById("tab_"+tab+"_selector").style;
        selector.display = display;
        var tabDiv = document.getElementById("tab_"+tab).style;
        tabDiv.display = display;
    }
    drawChart = chartFuncs[newTab];
    drawChart();
}
