describe MetricsHelper, type: :helper do
  include Chartjs::ChartHelpers::Implicit

  describe "MetricsHelper Chart methods" do
    before :each do
      @dates = ["2019-02-22", "2020-01-11"]
      @authors = {"student1" => "student1@ncsu.edu", "student2"=> "student2@ncsu.edu"}
      @parsed_data = {"student1"=>{"2019-02-22"=>25}, "student2"=>{"2020-01-11"=>13}}
    end

    it "returns a javascript function rendering the barchart timeline when passed github data" do
      expect(display_github_metrics(@parsed_data, @authors, @dates)).to eq(
                                                                          '<canvas id="chart-0" class="chart" width="100" height="100"></canvas><script nonce="true">
//<![CDATA[
(function() { var initChart = function() { var ctx = document.getElementById("chart-0"); var chart = new Chart(ctx, { type: "horizontalBar", data: {"labels":["2019-02-22","2020-01-11"],"datasets":[{"label":"student1","data":[25],"backgroundColor":"red","borderWidth":1},{"label":"student2","data":[13],"backgroundColor":"yellow","borderWidth":1}]}, options: {"responsive":true,"maintainAspectRatio":false,"scales":{"yAxes":[{"stacked":true,"ticks":{"beginAtZero":true},"barThickness":30,"scaleLabel":{"display":true,"labelString":"Submission timeline"}}],"xAxes":[{"stacked":true,"ticks":{"beginAtZero":true},"barThickness":30,"scaleLabel":{"display":true,"labelString":"# of Commits"}}]}}, plugins: {}, }); }; if (typeof Chart !== "undefined" && Chart !== null) { initChart(); } else { /* W3C standard */ if (window.addEventListener) { window.addEventListener("load", initChart, false); } /* IE */ else if (window.attachEvent) { window.attachEvent("onload", initChart); } } })();
//]]>
</script>')
    end

    it "returns a GoogleCharts API link to a totals piechart when passed github data" do
      expect(display_totals_piechart(@parsed_data, @authors, @dates)).to eq('http://chart.apis.google.com/chart?chs=600x300&cht=p&chco=ff0000,ffff00&chd=s:9f&chl=student1+(25)|student2+(13)&chtt=%23+Commits+By+Author')
    end
  end
end
