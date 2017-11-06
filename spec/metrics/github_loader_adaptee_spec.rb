describe "GithubLoaderAdaptee" do

  it "cannot load data with a team and assignment" do
    params = { :url => "https://github.com/totallybradical/simicheck-expertiza-sandbox/pull/3"}

    expect(GithubMetricsFetcher.supports_url?(params[:url])).to be true
    expect(GithubLoaderAdaptee.can_load?(params)).to be false 
  end

  it "can load data and save to db" do 
    student = create(:student, email: 'zctaylor@ncsu.edu', github_id: 'zachncst')
    assignment = create(:assignment)
    team = create(:assignment_team, assignment: assignment)
    team_users = create(:team_user, team: team, user: student)
    dp = create(:metric_data_point_type)
    dp1 = create(:metric_data_point_type, name: "user_id", id: 2)
    dp2 = create(:metric_data_point_type, name: "commit_date", id: 3)
    dp3 = create(:metric_data_point_type, name: "lines_added", id: 4)
    params = { 
      :url => "https://github.ncsu.edu/zctaylor/csc517-program-1",
      :assignment => assignment,
      :team => team
    }
    
    expect(GithubMetricsFetcher.supports_url?(params[:url])).to be true
    expect(GithubLoaderAdaptee.can_load?(params)).to be true
    metrics = GithubLoaderAdaptee.load_metric(params)
    metric_list_map = GithubLoaderAdaptee.to_map(metrics)
    expect(metric_list_map.length).to eq(11)
  end

  it "loads only new commits" do 
    student = create(:student, email: 'zctaylor@ncsu.edu', github_id: 'zachncst')
    assignment = create(:assignment)
    team = create(:assignment_team, assignment: assignment)
    team_users = create(:team_user, team: team, user: student)
    params = { 
      :url => "https://github.ncsu.edu/zctaylor/csc517-program-1",
      :assignment => assignment,
      :team => team
    }
    metric = create(:metric, 
      team: team, 
      assignment: assignment, 
      remote_id: params[:url],
      uri: 'csc517-program-1:commit:d4b7859c13e1b29640e1e9cb7c9442a063f7d853')
    dp = create(:metric_data_point_type)
    dpt = create(:metric_data_point_type, name: "commit_date", id: 2)
    met_point = create(:metric_data_point, metric_data_point_type: dpt,
      metric: metric, value: "2017-03-04T06:16:47Z" )
    met_point2 = create(:metric_data_point, metric_data_point_type: dp,
      metric: metric, value: "d4b7859c13e1b29640e1e9cb7c9442a063f7d853" )
    
    expect(GithubMetricsFetcher.supports_url?(params[:url])).to be true
    expect(GithubLoaderAdaptee.can_load?(params)).to be true
    metrics = GithubLoaderAdaptee.load_metric(params)
    metric_list_map = GithubLoaderAdaptee.to_map(metrics)
    expect(metric_list_map.length).to eq(11)
  end
end