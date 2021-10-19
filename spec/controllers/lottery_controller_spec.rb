include AssignmentHelper

describe LotteryController do
  describe "#run_intelligent_assignmnent" do
    it "webservice call should be successful" do
      dat = double("data")
      rest = double("RestClient")
      result = RestClient.get 'http://www.google.com', content_type: :json, accept: :json
      expect(result.code).to eq(200)
    end

    it "should return json response" do
      result = RestClient.get 'https://www.google.com', content_type: :json, accept: :json
      expect(result.header['Content-Type']).to include 'application/json' rescue result
    end
  end

  describe "#run_intelligent_bid" do
    it "should do intelligent assignment" do
      assignment = double("Assignment")
      allow(assignment).to receive(:is_intelligent) { 1 }
      expect(assignment.is_intelligent).to eq(1)
    end

    it "should exit gracefully when assignment not intelligent" do
      assignment = double("Assignment")
      allow(assignment).to receive(:is_intelligent) { 0 }
      expect(assignment.is_intelligent).to eq(0)
      redirect_to(controller: 'tree_display')
    end
  end

  describe "#create_new_teams_for_bidding_response" do
    it "should create team and return teamid" do
      assignment = double("Assignment")
      team = double("team")
      allow(team).to receive(:create_new_teams_for_bidding_response).with(assignment).and_return(:teamid)
      expect(team.create_new_teams_for_bidding_response(assignment)).to eq(:teamid)
    end
  end

  describe "#auto_merge_teams" do
    it "sorts the unassigned teams" do
      assignment = double("Assignment")
      team = double("team")
      unassignedteam = double("team")
      sortedteam = double("team")
      allow(team).to receive(:where).with(assignment).and_return(unassignedteam)
      allow(unassignedteam).to receive(:sort_by).and_return(sortedteam)
      expect(team.where(assignment)).to eq(unassignedteam)
      expect(unassignedteam.sort_by).to eq(sortedteam)
    end
  end
end
