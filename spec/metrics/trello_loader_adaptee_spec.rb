# This rspec file is used to test that the TrelloLoaderAdaptee can use the
# TrelloMetricsFetcher object to fetch the metrics and store them to the database.

describe "TrelloLoaderAdaptee" do
  it "cannot load data with a team and assignment" do
    params = {url: "https://trello.com/b/rU4qGAt4/517-test-board"}

    expect(TrelloMetricsFetcher.supports_url?(params[:url])).to be true
    expect(TrelloLoaderAdaptee.can_load?(params)).to be false
  end

  it "can load data and save to db" do
    student = create(:student, email: 'yliu224@ncsu.edu', github_id: 'hankliu5', trello_name: 'hankliu17')
    assignment = create(:assignment)
    team = create(:assignment_team, assignment: assignment)
    team_users = create(:team_user, team: team, user: student)
    dp = create(:metric_data_point_type)
    dp1 = create(:metric_data_point_type, name: "total_items", source: MetricDataPointType.sources[:trello], id: 2)
    dp2 = create(:metric_data_point_type, name: "checked_items", source: MetricDataPointType.sources[:trello], id: 3)
    dp3 = create(:metric_data_point_type, name: "users_contributions", source: MetricDataPointType.sources[:trello], id: 4)
    params = {
      url: "https://trello.com/b/rU4qGAt4/517-test-board",
      assignment: assignment,
      team: team
    }
    expect(TrelloMetricsFetcher.supports_url?(params[:url])).to be true
    expect(TrelloLoaderAdaptee.can_load?(params)).to be true
    metrics = TrelloLoaderAdaptee.load_metric(params)
    metric_list_map = TrelloLoaderAdaptee.to_map(metrics)
    users_contributions = TrelloLoaderAdaptee.map_user_contributions(metric_list_map[0][:users_contributions])

    expect(metric_list_map[0][:total_items].to_i).to eq(11)
    expect(metric_list_map[0][:checked_items].to_i).to eq(3)
    expect(users_contributions[:otto292].to_i).to eq(2)
    expect(users_contributions[:hankliu17].to_i).to eq(1)
  end
end
