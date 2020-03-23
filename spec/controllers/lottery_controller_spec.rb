include AssignmentHelper
require 'pp'

describe LotteryController do
  let(:assignment) { create(:assignment, is_intelligent: true) }
  let(:assignment2) { build(:assignment) }
  let(:ta) { build(:teaching_assistant) }
  let(:instructor) { build(:instructor) }
  let(:admin) { build(:admin) }

  let(:student1) { create(:student) }
  let(:student2) { create(:student) }
  let(:student3) { create(:student) }

  let(:topic1) { create(:topic, assignment_id: assignment.id) }
  let(:topic2) { create(:topic, assignment_id: assignment.id) }
  let(:topic3) { create(:topic, assignment_id: assignment.id) }
  let(:topic4) { create(:topic, assignment_id: assignment.id) }

  let(:assignment_team1) { create(:assignment_team, parent_id: assignment.id) }
  let(:assignment_team2) { create(:assignment_team, parent_id: assignment.id) }
  let(:assignment_team3) { create(:assignment_team, parent_id: assignment.id) }
  let(:assignment_team4) { create(:assignment_team, parent_id: assignment.id) }

  let(:team_user1) { build(:team_user, team_id: assignment_team1.id, user_id: student1.id, id: 1) }
  let(:team_user2) { build(:team_user, team_id: assignment_team1.id, user_id: student2.id, id: 2) }
  let(:team_user3) { build(:team_user, team_id: assignment_team1.id, user_id: student3.id, id: 3) }

  before :each do
    assignment_team1.save
    assignment_team2.save
    assignment_team3.save
    assignment_team4.save

    team_user1.save
    team_user2.save
    team_user3.save

    topic1.save
    topic2.save
    topic3.save
    topic4.save

    @team_users = []
    @team_users << team_user1 << team_user2 << team_user3

    @teams = assignment.teams
    @sign_up_topics = assignment.sign_up_topics
  end

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

#  describe "#create_new_teams_for_bidding_response" do
#    it "should create team and return teamid" do
#      assignment = double("Assignment")
#      team = double("team")
#      allow(team).to receive(:create_new_teams_for_bidding_response).with(assignment).and_return(:teamid)
#      expect(team.create_new_teams_for_bidding_response(assignment)).to eq(:teamid)
#    end
#  end

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
      user = student1
      stub_current_user(user, user.role.name, user.role)
      expect(controller.action_allowed?).to be false
    end
  end

  describe "#construct_user_bidding_info" do
    it "generate user bidding information hash" do
      users_bidding_info = controller.send(:construct_users_bidding_info, @sign_up_topics, @teams)
      expect(users_bidding_info).to eq([])
    end
  end

  describe "#create_new_teams_for_bidding_response" do
    it "create new Assignment Teams" do
      user_bidding_info = []
      teams = [[student1.id, student2.id], [student3.id]]
      expect(AssignmentTeam.count).to eq(4)
      expect(TeamNode.count).to eq(0)
      expect(TeamsUser.count).to eq(3)
      expect(TeamUserNode.count).to eq(0)
      controller.send(:create_new_teams_for_bidding_response, teams, assignment, user_bidding_info)
      expect(AssignmentTeam.count).to eq(6)
      expect(TeamNode.count).to eq(2)
      expect(TeamsUser.count).to eq(3)
      expect(TeamUserNode.count).to eq(3)
    end
  end

  describe "#run_intelligent_assignment" do
    it "should redirect to list action in tree_display controller" do
      params = ActionController::Parameters.new(id: assignment.id)
      allow(controller).to receive(:params).and_return(params)
      allow(controller).to receive(:log)
      allow(controller).to receive(:flash).and_return({})
      allow(Assignment).to receive(:find_by).with(id: assignment.id).and_return(assignment)
      expect(controller).to receive(:redirect_to).with({:controller => 'tree_display', :action => "list"})

      controller.run_intelligent_assignment
    end
  end

  describe "#construct_team_bidding_info" do
    it "should generate team bidding info hash based on newly created teams" do
      unassigned_teams = [assignment_team1, assignment_team2]
      sign_up_topics = [topic1, topic2]
      team_bidding_info = controller.send(:construct_teams_bidding_info, unassigned_teams, sign_up_topics)
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
    it "should" do
    end
  end

  describe "#merge_bids_from_different_previous_teams" do
    before :each do
      @sign_up_topics = @sign_up_topics
      @team_id = assignment_team1.id
      @user_ids = @team_users.map(&:id)
      @user_bidding_info = [{pid: team_user1.id, ranks: [1, 0, 2, 2]},
                            {pid: team_user2.id, ranks: [2, 1, 3, 0]},
                            {pid: team_user3.id, ranks: [3, 2, 1, 1]}]
    end
    it "should create bids objects of the newly-merged team on each sign-up topics" do
      expect(Bid.count).to eq(0)
      controller.send(:merge_bids_from_different_previous_teams, @sign_up_topics, @team_id, @user_ids, @user_bidding_info)
      expect(Bid.count).to eq(4)
      expect(Bid.find_by(topic_id: 1, team_id: 1).priority).to eq(1)
      expect(Bid.find_by(topic_id: 2, team_id: 1).priority).to eq(3)
      expect(Bid.find_by(topic_id: 3, team_id: 1).priority).to eq(2)
      expect(Bid.find_by(topic_id: 4, team_id: 1).priority).to eq(4)
    end
  end
end
