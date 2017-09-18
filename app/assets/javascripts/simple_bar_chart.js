google.charts.load("current", {packages:["corechart"]});

function drawChart(id, title, data) {
  /*
  [
    ["Element", "Density", { role: "style" } ],
    ["Copper", 8.94, "#b87333"],
    ["Silver", 10.49, "silver"],
    ["Gold", 19.30, "gold"],
    ["Platinum", 21.45, "color: #e5e4e2"]
  ]
  */
  var data = google.visualization.arrayToDataTable();

  var view = new google.visualization.DataView(data);
  view.setColumns([0, 1,
                   { calc: "stringify",
                     sourceColumn: 1,
                     type: "string",
                     role: "annotation" },
                   2]);

  var options = {
    title: title,
    width: 200,
    height: 400,
    bar: {groupWidth: "95%"},
    legend: { position: "none" },
  };
  
  var chart = new google.visualization.BarChart(document.getElementById(id));
  chart.draw(view, options);
}