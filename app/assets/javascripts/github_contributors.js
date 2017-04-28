// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function loadGithubCharts(data, container, title, color) {
    new Highcharts.chart(container, {
       title: {
           text: title,
           style: {
               // fontSize: "12px"
               display: 'none'
           }
       }, xAxis: {
           type: 'datetime'
       }, yAxis: {
           title: {
               text: title
           }
       }, series: [{
           color: color,
           data: data
       }], tooltip: {
           // pointFormat: '<span style="color:{point.color}">\u25CF</span> <b>{point.y}</b><br/>'
       }, legend: {
           enabled: false
       }, credits: {
           enabled: false
       }
    });
}