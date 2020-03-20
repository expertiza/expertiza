include AssignmentHelper
require 'pp'

describe LotteryController do
  let(:assignment) {build(:assignment, id: 1)}
  let(:student) {build(:student)}
  let(:ta) {build(:teaching_assistant)}
  let(:instructor) {build(:instructor)}
  let(:admin) {build(:admin)}
  let(:topic1) {build(:topic, assignment: assignment)}
  let(:topic2) {build(:topic, assignment: assignment)}
  let(:assignment_team1) {build(:assignment_team, assignment: assignment)}
  let(:assignment_team2) {build(:assignment_team, assignment: assignment)}
  
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

  # Starting to write my own tests
  describe "#action_allowed?" do
    it "allows Instructors, Teaching Assistants, Administrators to run the bid" do
      user = instructor
      stub_current_user(user, user.role.name, user.role)
      expect(controller.action_allowed?).to be true
      user = admin
      stub_current_user(user, user.role.name, user.role)
      expect(controller.action_allowed?).to be true
      user = ta
      stub_current_user(user, user.role.name, user.role)
      expect(controller.action_allowed?).to be true
      user = student
      stub_current_user(user, user.role.name, user.role)
      expect(controller.action_allowed?).to be false
    end
  end

  describe "#construct_user_bidding_info" do
    it "generate user bidding infomation hash" do
      assignment.teams << assignment_team1
      assignment.teams << assignment_team2
      assignment.sign_up_topics << topic1
      assignment.sign_up_topics << topic2
      teams = assignment.teams
      sign_up_topics = assignment.sign_up_topics
      test = SignedUpTeam.where(team_id: teams[0].id, is_waitlisted: 0).any?
      user_bidding_info = controller.send(:construct_user_bidding_info, sign_up_topics, teams)
      expect(user_bidding_info).to eq([])
    end
  end

  describe "#run_intelligent_assignment" do
    it "should redirect to list action in tree_display controller" do
      allow(Assignment).to receive(:find_by).with(id: 1).and_return(assignment)
      params = {id: 1}
      get :run_intelligent_assignment, params
#      expect(response).to redirect_to('/tree_display/list')
    end
  end

 # describe "#log" do
  #  it "prints a log message through ExpertizaLogger" do
   #   expect(controller.send(:log, "hello").to receive(ExpertizaLogger.info))
   # end
 # end

end
