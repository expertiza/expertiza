describe GithubMetricsHelper, type: :helper do
  include Chartjs::ChartHelpers::Implicit

  describe "MetricsHelper Chart methods" do
    before :each do
      @dates = ["2019-02-22", "2020-01-11"]
      @authors = {"student1" => "student1@ncsu.edu", "student2"=> "student2@ncsu.edu"}
      @parsed_metrics = {"student1"=>{"2019-02-22"=>25}, "student2"=>{"2020-01-11"=>13}}
    end

    # Test to see that the piechart is correctly formatted with the passed in metrics
    it "returns a GoogleCharts API link to a totals piechart when passed github data" do
      expect(display_piechart(@parsed_metrics, @authors, @dates)).to eq(
        '{"labels":["student1","student2"],"datasets":[{"data":[25,13],"backgroundColor":["#4e79a7","#f28e2b"],"borderWidth":1}]}'
      )
    end
  end
end
