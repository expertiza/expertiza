function toggleFunction(elementId) {
    var target = document.getElementById(elementId);
    if (target.style.display === 'none') {
        target.style.display = 'block';
    } else {
        target.style.display = 'none';
    }
}


function sortTable(n) {
    var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
    table = document.getElementById("github-metrics-summary-table");
    switching = true;
    dir = "asc";
    while (switching) {
        switching = false;
        rows = table.rows;
        for (i = 1; i < (rows.length - 1); i++) {
            shouldSwitch = false;
            x = rows[i].getElementsByTagName("TD")[n];
            y = rows[i + 1].getElementsByTagName("TD")[n];
            if (dir == "asc") {
		if (parseInt(x.innerHTML.toLowerCase()) > parseInt(y.innerHTML.toLowerCase())) {
                    shouldSwitch = true;
                    break;
		}
            } else if (dir == "desc") {
		if (parseInt(x.innerHTML.toLowerCase()) < parseInt(y.innerHTML.toLowerCase())) {
                    shouldSwitch = true;
                    break;
		}
            }
        }
        if (shouldSwitch) {
            rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
            switching = true;
            switchcount ++;
        } else {
            if (switchcount == 0 && dir == "asc") {
		dir = "desc";
		switching = true;
            }
        }
    }
}

Array.prototype.unique = function() {
    return this.filter(function (value, index, self) { 
	return self.indexOf(value) === index;
    });
}

var datasets = [];
var variable = ["commits", "additions", "deletions"];
var group = ["by_week", "by_student"];
var colors = ['#ed1c1c', '#ffea00', '#00ff08', '#00e5ff', '#ff0077', '#0d00ff', '#7d4a56', '#77c9c8'];
var labels = []

function generate_data(gitData, group, variable) {
    datasets = [];
    labels = [];
    if (group === "by_week") {
	Object.keys(gitData).forEach(function (key, index) {
	    // key represents email addresses / student IDs.
	    var set = {};
	    set.label = key;
	    set.data = [];
	    set.backgroundColor = colors[index % colors.length];
	    Object.values(gitData[key]).forEach(function (val) {
		set.data.push(val[variable]);
	    });
	    datasets.push(set);
	    labels = Object.keys(gitData[key]);
	});
    } else if (group === "by_student") {
	var weeks = Object.values(gitData).map(function (v, i) { return Object.keys(v); }).flat();
	weeks.unique().forEach(function(week, index) {
	    console.log(week);
	    var set = {};
	    set.label = week;
	    set.data = [];
	    set.backgroundColor = colors[index % colors.length];
	    Object.keys(gitData).forEach(function (email) {
		set.data.push(gitData[email][week][variable])
	    });
	    datasets.push(set);
	});
	// labels = weeks.unique();
	labels = Object.keys(gitData);
	console.log(datasets);
    }
};

function drawChart() {
    var ctx = document.getElementById('charter').getContext('2d');
    window.myBar = new Chart(ctx, {
	type: 'horizontalBar',
	data: {
	    labels: labels,
	    datasets: datasets
	},
	options: {
	    responsive: true,
	    legend: {
		position: 'top',
	    },
	    scales: {
		xAxes: [{
		    stacked: true
		}],
		yAxes: [{
		    stacked: true
		}]
	    }
	}
    });
};

window.onload = function() {
    generate_data(gitData, "by_week", "commits");
    drawChart();
};


$(document).ready(function(){
    function handle_graph_change() {
	var participant_id = $('#participant_id').val()
	var graphType = $('#graph_selector').val();
	var timelineType = $('#timeline_selector').val();
	generate_data(gitData, group[timelineType], variable[graphType]);
	drawChart();
    }
    $('#graph_selector').on('change', handle_graph_change);
    $('#timeline_selector').on('change', handle_graph_change);
})
