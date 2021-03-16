
//this function render the pie chat for time tracking detail
function drawTimeCanvas(chartdata,resd) {
    //initializing the timeModal view
    $("#timeModalBody").empty().html("<div class=\"time-canvas-container\">" +
        "<canvas id=\"timeCanvas\" width=\"300\" height=\"300\"></canvas>"+
        "</div>"+
        "<table id=\"timeTable\" class=\"time-table\">"+
        "<tr>"+
        "<th>Subject</th>"+
        "<th>Time</th>"+
        "<th>Avg.</th>"+
        "</tr>" +
        "</table>");

    for(var i = 0 ; i < tb.length ; i++){

        var d = resd[0];
        $('#timeTable :last-child').append("<tr>" +
            "<td>" + d.subject + "</td>" +
            "<td>" + d.timecost + "</td>" +
            "<td>" + d.clsavg + "</td>" +
            "</tr>");

    }

    $('#timeTable :last-child').append("<tr>" +
        "<td>Total</td>" +
        "<td>" + resd.total + "</td>" +
        "<td>" + resd.totalavg + "</td>" +
        "</tr>");

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
        success: function (respond) {
            chartData = {
                labels: respond.Labels,
                datasets: [{
                    data: respond.Data,
                    borderWidth: 1
                }]
            };

            drawTimeCanvas(chartData,respond.tables);
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
