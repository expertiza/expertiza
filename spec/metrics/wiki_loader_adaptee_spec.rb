describe "WikiLoaderAdaptee" do 

	it "can load data with a valid wiki url" do 
	   params = {:url => "http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2017/E1790_Text_metrics"} 

	   expect(WikiLoaderAdaptee.can_load?(params)).to be true
	end

	it "can load data and store to database" do 
		assignment = create(:assignment)
		team = create(:assignment_team, assignment: assignment)
		dp = MetricDataPointType.create()
        dp1 = MetricDataPointType.create(name: "FleschKincaidRe", source: MetricDataPointType.sources[:wiki], id: 4)
        dp2 = MetricDataPointType.create(name: "FleschKincaidGl", source: MetricDataPointType.sources[:wiki], id: 5)
        dp3 = MetricDataPointType.create(name: "Ari", source: MetricDataPointType.sources[:wiki], id: 6)
        dp4 = MetricDataPointType.create(name: "ColemanLiau", source: MetricDataPointType.sources[:wiki], id: 7)
        dp5 = MetricDataPointType.create(name: "GunningFog", source: MetricDataPointType.sources[:wiki], id: 8)
        dp6 = MetricDataPointType.create(name: "Smog", source: MetricDataPointType.sources[:wiki], id: 9)
        params = {
        :url => "http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2017/E1790_Text_metrics",
        :assignment => assignment,
        :team => team
        }

        expect(WikiLoaderAdaptee.can_load?(params)).to be true
        metrics = WikiLoaderAdaptee.load_metric(params)
        metric_list_map = WikiLoaderAdaptee.to_map(metrics)


        expect(metric_list_map[0][:FleschKincaidRe].to_f).to eq(53.7)
        expect(metric_list_map[0][:FleschKincaidGl].to_f).to eq(11.4)
        expect(metric_list_map[0][:Ari].to_f).to eq(11.4)
        expect(metric_list_map[0][:ColemanLiau].to_f).to eq(11.1)
        expect(metric_list_map[0][:GunningFog].to_f).to eq(9.0)
        expect(metric_list_map[0][:Smog].to_f).to eq(12.6)
    end

end