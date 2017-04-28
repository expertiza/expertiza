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
           formatter: function () {
                return '<span style="color:' + this.color + '">\u25CF</span> <b>' + this.y + '</b><br/>' +
                    '<span style="font-size: 10px">' + Highcharts.dateFormat('%e - %b - %Y',
                        new Date(this.x))+ '</span><br/>';
           }
       }, legend: {
           enabled: false
       }, credits: {
           enabled: false
       }
    });
}