 /*
Google Charts tutorial - https://developers.google.com/chart/interactive/docs/quick_start
The function below is called by generate_statistics.html.erb
 */
 function chart(chart_data,element_id) {
      google.charts.load('current', {'packages':['corechart']});
      google.charts.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable(chart_data);
        var options = {
          titleTextStyle: { 
            fontSize: 12,
            bold: true
          }
        };
        var chart = new google.visualization.PieChart(document.getElementById(element_id));
        chart.draw(data, options);
      } 
}