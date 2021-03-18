
//this function render the pie chat for time tracking detail
function drawTimeCanvas(chartdata,resd) {

    var table = resd.tables;
    var stats = resd.stats;

    if(table.length == 0 || chartdata.datasets[0].data.length == 0){
        $("#timeModalBody").empty().html("<p>This review has no time detail avaliable</p>");
        return;
    }

    //initializing the timeModal view
    $("#timeModalBody").empty().html("<div class=\"time-canvas-container\">" +
        "<canvas id=\"timeCanvas\" width=\"300\" height=\"300\"></canvas>"+
        "</div>"+
        "<table id=\"timeTable\" class=\"time-table\">"+
        "<tbody id=\"timeTableBody\">"+
        "<tr>"+
        "<th>Subject</th>"+
        "<th>Time</th>"+
        "<th>Avg.</th>"+
        "</tr>" +
        "</tbody>" +
        "</table>" +
        "<table id=\"statTable\" class=\"stat-table\">"+
        "<tbody id=\"statTableBody\">"+
        "<tr>"+
        "<th>Class Stats</th>"+
        "<th>Value</th>"+
        "</tr>" +
        "</tbody>" +
        "</table>");

    for(var i = 0 ; i < table.length ; i++){
        var d = table[i];
        $('#timeTable > :last-child').append("<tr>" +
            "<td>" + d.subject + "</td>" +
            "<td>" + d.timeCost + "</td>" +
            "<td>" + d.avgTime +"</td>" +
            "</tr>");

    }

    for(var i = 0 ; i < stats.length ; i++){
        var d = stats[i];
        $('#statTable > :last-child').append("<tr>" +
            "<td>" + d.title + "</td>" +
            "<td>" + d.value + "</td>" +
            "</tr>");

    }

    var ctx = $("#timeCanvas").get(0).getContext("2d");
    var pieChart = new Chart(ctx, {
        type: 'pie',
        data: chartdata,
        options:{
            plugins: {
                colorschemes: {
                    scheme: 'office.Atlas6'
                }
            }
        }
    });
}

//this function pop up the modal and do AJAX call to load time tracking data.
function displayTimeDetail(resp_map_id,round){
    $("#timeModalBody").empty().html("<p>Loading data...(This might need few seconds)</p>")
    $("#timeModal").show();
    $.ajax({
        url: '/submission_viewing_events/getTimingDetails',
        method: 'POST',
        dataType: 'json',
        data: {
            reponse_map_id: resp_map_id,
            round: round
        },
        success: function (jsonResponse) {
            chartData = {
                labels: jsonResponse.Labels,
                datasets: [{
                    data: jsonResponse.Data,
                    borderWidth: 1
                }]
            };

            drawTimeCanvas(chartData,jsonResponse);
        },
        error: function(xhr, textStatus, errorThrown){
            $("#timeModalBody").empty().html("<p>Failed, cannot get time details at this time..</p>")
        }
    });
}

//this function destroys the modal view.
$("#closeTimeModal").click(function (){
    $("#timeModal").hide();
});
