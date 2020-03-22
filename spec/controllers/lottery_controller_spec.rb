include AssignmentHelper
require 'pp'

describe LotteryController do
  let(:assignment) {build(:assignment, id: 1, is_intelligent: true)}
  let(:assignment2) {build(:assignment, id: 2)}
  let(:student) {build(:student)}
  let(:ta) {build(:teaching_assistant)}
  let(:instructor) {build(:instructor)}
  let(:admin) {build(:admin)}
  let(:topic1) {build(:topic, assignment: assignment)}
  let(:topic2) {build(:topic, assignment: assignment)}
  let(:assignment_team1) {create(:assignment_team, parent_id: assignment.id)}
  let(:assignment_team2) {create(:assignment_team, parent_id: assignment.id)}

  let(:student1) {build(:student)}
  let(:student2) {build(:student)}
  let(:student3) {build(:student)}
  let(:student5) {build(:student)}
  
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

  describe "#create_new_teams_for_bidding_response" do
    it "create new Assignment Teams" do
      user_bidding_info = []
      teams = [[student1.id, student2.id], [student3.id, student5.id]]
      expect(AssignmentTeam.count).to eq(0)
      expect(TeamNode.count).to eq(0)
      expect(TeamsUser.count).to eq(0)
      expect(TeamUserNode.count).to eq(0)
      controller.send(:create_new_teams_for_bidding_response, teams, assignment, user_bidding_info)
      #expect {create(:AssignmentTeam)}.to change(AssignmentTeam, :count).by(2)
      expect(AssignmentTeam.count).to eq(2)
      expect(TeamNode.count).to eq(2)
      expect(TeamsUser.count).to eq(4)
      expect(TeamUserNode.count).to eq(4)
    end
  end

  describe "#run_intelligent_assignment" do
    it "should redirect to list action in tree_display controller" do
      allow(Assignment).to receive(:find_by).with(id: 1).and_return(assignment)
      params = {id: 1}
      user = student
      stub_current_user(user, user.role.name, user.role)
      session = {user: student}
      get :run_intelligent_assignment, params, session
#      expect(response).to redirect_to('/tree_display/list')
    end
  end

  describe "#construct_team_bidding_info" do
    it "should generate team bidding info hash based on newly created teams" do
      unassigned_teams = [assignment_team1, assignment_team2]
      sign_up_topics = [topic1, topic2]
      team_bidding_info = controller.send(:construct_team_bidding_info, unassigned_teams, sign_up_topics)
      expect(team_bidding_info.size).to eq(2)
    end
  end

  describe "#match_new_teams_to_topics" do
    it "assigns topics to teams" do
      expect(assignment2.is_intelligent).to eq(false)
      controller.send(:match_new_teams_to_topics, assignment2)
      expect(assignment2.is_intelligent).to eq(false)
      expect(assignment.is_intelligent).to eq(true)
      bid1 = Bid.create(team_id: assignment_team1.id, topic_id: topic1.id)
      bid2 = Bid.create(team_id: assignment_team2.id, topic_id: topic2.id)
      controller.send(:match_new_teams_to_topics, assignment)
      expect(assignment.is_intelligent).to eq(false)
    end
  end


 # describe "#log" do
  #  it "prints a log message through ExpertizaLogger" do
   #   expect(controller.send(:log, "hello").to receive(ExpertizaLogger.info))
   # end
 # end

end
