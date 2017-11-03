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
    puts GithubLoaderAdaptee.to_map(metrics)
  end
end