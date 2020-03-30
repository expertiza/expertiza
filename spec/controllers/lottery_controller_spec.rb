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

  describe "remove" do
    before :each do
      @assignment = create(:assignment, name: "remove_user_from_previous_team")
      @assignment_team = create(:assignment_team, assignment: @assignment)
      @team_user1 = create(:team_user, team: @assignment_team, user: create(:student, name: "team_user1"))
      @team_user2 = create(:team_user, team: @assignment_team, user: create(:student, name: "team_user2"))
      @team_user3 = create(:team_user, team: @assignment_team, user: create(:student, name: "team_user3"))
    end

    describe "#remove_user_from_previous_team" do
      it "should return the team without the removed user" do
        user_id = @team_user3.user_id
        assignment_id = @assignment.id
        number_of_team_users = TeamsUser.count
        controller.send(:remove_user_from_previous_team, assignment_id, user_id)

        expect(TeamsUser.count).to eq(number_of_team_users - 1)
        expect(TeamsUser.find_by(user_id: @team_user3.user_id)).to be nil
        expect(TeamsUser.find_by(user_id: @team_user2.user_id)).to eq @team_user2
        expect(TeamsUser.find_by(user_id: @team_user1.user_id)).to eq @team_user1
      end
    end

    describe "#remove_empty_teams" do
      before :each do
        @assignment_team2 = create(:assignment_team, assignment: @assignment, teams_users: [])
      end
      
      it "should reduce the number of teams by the number of empty teams in the assignment" do
        number_of_teams = AssignmentTeam.count
        number_of_teams_in_assignment = Assignment.find(@assignment.id).teams.count
        controller.send(:remove_empty_teams, @assignment)
        expect(AssignmentTeam.count).to eq(number_of_teams - 1)
        expect(Assignment.find(@assignment.id).teams.count).to_not eq(number_of_teams_in_assignment)
      end
    end
  end

  describe "#assign_available_slots" do
    before :each do
      @sign_up_topic = topic1
      @topic_bids1 = [{topic_id: @sign_up_topic.id, priority: 1}]
      @team_bids = [{team_id: assignment_team1.id, bids: @topic_bids1}]
    end
    it "should assign topic to team of biggest size" do
      number_of_signed_up_teams = SignedUpTeam.count
      controller.send(:assign_available_slots, @team_bids)
      expect(SignedUpTeam.count).to eq(number_of_signed_up_teams + 1)
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
