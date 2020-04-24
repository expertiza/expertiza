function switchPoints() {
  var raws_graph = document.getElementsByClassName("raw_points_graph");
  var percents_graph = document.getElementsByClassName("percentage_points_graph");
  var raws = document.getElementsByClassName("raw_points");
  var percents = document.getElementsByClassName("percentage_points");
  var button = document.getElementById("switchPointsButton");

  for (var k=0; k<raws_graph.length; k++){
    switch_graph_points_helper(raws_graph[k]);
  }

  for (var k=0; k<percents_graph.length; k++){
    switch_graph_points_helper(percents_graph[k]);
  }

  for (var k=0; k<raws.length; k++){
    switch_points_helper(raws[k]);
  }
  
  for (var k=0; k<percents.length; k++){
    switch_points_helper(percents[k]);
  }

  switch_button_helper(button)
}

function switch_graph_points_helper(x) {
  if (x.style.display === "none") {
    x.style.display = "block"
  } else {
    x.style.display = "none";
  }
}

function switch_points_helper(x) {
  if (x.style.display === "none") {
    x.style.display = "inline"
  } else {
    x.style.display = "none";
  }
}

function switch_button_helper(button){
  if (button.innerHTML === "Convert Points to Percents"){
    button.innerHTML = "Convert Points to Raw"
  } else {
    button.innerHTML = "Convert Points to Percents"
  }

}