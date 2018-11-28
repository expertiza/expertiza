/* 
  Google charts  for displaying the chart data on the grades view page.
  These functions are called by _team_chart.html.erb file.
  File path : expertiza/app/views/grades/_team_charts.html.erb  
*/

google.charts.load('current', {packages: ['corechart', 'bar']});
google.charts.setOnLoadCallback(drawBasic);

var chart;
var chartOptions;

var chartData = [];
var currentRound = 0;
var criteriaSelected = [];

function generateData() {
	var rounds = 3;

	for(var i = 0; i < rounds; i++) {
    var criteriaNum = Math.floor(Math.random() * 5 + 5);
  	
		var round = [];
    var criteria = [];
    for(var j = 0; j < criteriaNum; j++) {
    	round.push(Math.floor(Math.random() * 101));
      criteria.push(true);
    }
 		chartData.push(round);
    criteriaSelected.push(criteria);
  }
}

function drawBasic() {
	generateData();
  
  chartOptions = {		//Render options for the chart
  	title: 'Average Scores',
    titleTextStyle: {
      fontName: 'arial',	//Fonts to be changed to Helvetica when implemented
      fontSize: 18,
      italic: false,
      bold: true
    },
    legend: 'none',
    bar: {
    	groupWidth: 'default'
    },
    hAxis: {
    	title: 'Criterion',
      titleTextStyle: {
      	fontName: 'arial',
        fontSize: 14,
      	italic: false,
        bold: false
      },
      viewWindow: {
      	min: 0,
     		max: 10
      }
    },
    vAxis: {
    	title: 'Average Score',
      titleTextStyle: {
      	fontName: 'arial',
        fontSize: 14,
      	italic: false,
        bold: false
      },
      viewWindow: {
      	min: 0,
        max: 100
      }
    }
  };
  
  chart = new google.visualization.ColumnChart(document.getElementById('chart_div'));
  updateChart(currentRound);
	loadOptions();
}

function updateChart(roundNum) {
  currentRound = roundNum;
  renderChart();
  loadCriteria();
}

function renderChart() {
	var data = loadData();
  chart.draw(data, chartOptions);
}


function loadData() {
	var data = new google.visualization.DataTable();
  data.addColumn('number', 'Criterion');
	data.addColumn('number', 'Average Score');
  data.addColumn({type: 'string', role: 'style'});	//column for specifying the bar color

  for(var i = 0; i < chartData[currentRound].length; i++) {
  	if (criteriaSelected[currentRound][i])
  		data.addRow([i+1, chartData[currentRound][i], '#a90201']);
  }
  
  return data;
	
}

function loadOptions() {
	var rounds = document.getElementById("chartRounds");
  for(var i = 0; i < chartData.length; i++) {
  	var option = document.createElement('option');
  	option.value = i;
    option.text = "Round " + (i+1);
    rounds.add(option);
  }
  rounds.style.display = "inline";
}
function loadCriteria() {
	var form = document.getElementById("chartCriteria");
  while (form.firstChild)
    form.removeChild(form.firstChild);
    
  for(let i = 0; i < chartData[currentRound].length; i++) {
 		var checkbox = document.createElement('input');
    checkbox.type = "checkbox";
    checkbox.name = "name";
    checkbox.value = "value";
    checkbox.id = "checkboxoption" + i;
    checkbox.onclick = function() {
    	checkboxUpdate(i);
    }

    var label = document.createElement('label')
    label.htmlFor = "id";
    label.appendChild(document.createTextNode(i+1));
    label.appendChild(document.createElement("BR"));

    form.appendChild(checkbox);
    form.appendChild(label);
    checkbox.checked = criteriaSelected[currentRound][i];
  }
}

function funtFactory(id) {
	return function() {
  	checkboxUpdate(id);
  }
}

function checkboxUpdate(checkid) {
	var check = document.getElementById("checkboxoption" + checkid);
  criteriaSelected[currentRound][checkid] = check.checked;
  renderChart();
}