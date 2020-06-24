describe LotteryController do
  let(:assignment) { create(:assignment, is_intelligent: true, name: "assignment") }
  let(:assignment_2) { create(:assignment, is_intelligent: false, name: "assignment_2") }

  let(:student1) { create(:student, name: "student1") }
  let(:student2) { create(:student, name: "student2") }
  let(:student3) { create(:student, name: "student3") }
  let(:student4) { create(:student, name: "student4") }
  let(:student5) { create(:student, name: "student5") }
  let(:student6) { create(:student, name: "student6") }

  let(:topic1) { create(:topic, assignment_id: assignment.id) }
  let(:topic2) { create(:topic, assignment_id: assignment.id) }
  let(:topic3) { create(:topic, assignment_id: assignment.id) }
  let(:topic4) { create(:topic, assignment_id: assignment.id) }

  let(:assignment_team1) { create(:assignment_team, parent_id: assignment.id) }
  let(:assignment_team2) { create(:assignment_team, parent_id: assignment.id) }
  let(:assignment_team3) { create(:assignment_team, parent_id: assignment.id) }
  let(:assignment_team4) { create(:assignment_team, parent_id: assignment.id) }

  let(:team_user1) { create(:team_user, team_id: assignment_team1.id, user_id: student1.id, id: 1) }
  let(:team_user2) { create(:team_user, team_id: assignment_team1.id, user_id: student2.id, id: 2) }
  let(:team_user3) { create(:team_user, team_id: assignment_team1.id, user_id: student3.id, id: 3) }
  let(:team_user4) { create(:team_user, team_id: assignment_team2.id, user_id: student4.id, id: 4) }
  let(:team_user5) { create(:team_user, team_id: assignment_team3.id, user_id: student5.id, id: 5) }
  let(:team_user6) { create(:team_user, team_id: assignment_team4.id, user_id: student6.id, id: 6) }

  before :each do
    assignment_team1.save
    assignment_team2.save
    assignment_team3.save
    assignment_team4.save

    team_user1.save
    team_user2.save
    team_user3.save
    team_user4.save
    team_user5.save
    team_user6.save

    topic1.save
    topic2.save
    topic3.save
    topic4.save

    Bid.create(topic_id: topic1.id, team_id: assignment_team1.id, priority: 1)
    Bid.create(topic_id: topic2.id, team_id: assignment_team2.id, priority: 2)
    Bid.create(topic_id: topic4.id, team_id: assignment_team2.id, priority: 1)
    Bid.create(topic_id: topic3.id, team_id: assignment_team2.id, priority: 5)
    Bid.create(topic_id: topic4.id, team_id: assignment_team3.id, priority: 0)
    Bid.create(topic_id: topic4.id, team_id: assignment_team1.id, priority: 3)

    @teams = assignment.teams
    @sign_up_topics = assignment.sign_up_topics
  end

  describe "#action_allowed?" do
    it "allows Instructors, Teaching Assistants, Administrators to run the bid" do
      session[:user] = build(:instructor)
      expect(controller.action_allowed?).to be true
      session[:user] = build(:teaching_assistant)
      expect(controller.action_allowed?).to be true
      session[:user] = build(:admin)
      expect(controller.action_allowed?).to be true
    end
    it "does not allow Students or Visitors to run the bid" do
      session[:user] = student1
      expect(controller.action_allowed?).to be false
      session[:user] = nil
      expect(controller.action_allowed?).to be false
    end
  end

  describe "#construct_users_bidding_info" do
    it "generate users bidding information hash" do
      # Only members in assignment_team1 and assignment_team2 are involved in the bidding process
      @expected_users_bidding_info = [{pid: student1.id, ranks: [1, 0, 0, 3]},
                                      {pid: student2.id, ranks: [1, 0, 0, 3]},
                                      {pid: student3.id, ranks: [1, 0, 0, 3]},
                                      {pid: student4.id, ranks: [0, 2, 5, 1]}]
      users_bidding_info = controller.send(:construct_users_bidding_info, @sign_up_topics, @teams)
      expect(users_bidding_info).to eq(@expected_users_bidding_info)
    end
  end

  describe "#create_new_teams_for_bidding_response" do
    it "create new Assignment Teams" do
      user_bidding_info = []
      teams = [[student1.id, student2.id], [student3.id]]
      expect(AssignmentTeam.count).to eq(4)
      expect(TeamNode.count).to eq(0)
      expect(TeamsUser.count).to eq(6)
      expect(TeamUserNode.count).to eq(0)
      controller.send(:create_new_teams_for_bidding_response, teams, assignment, user_bidding_info)
      expect(AssignmentTeam.count).to eq(6)
      expect(TeamNode.count).to eq(2)
      expect(TeamsUser.count).to eq(6)
      expect(TeamUserNode.count).to eq(3)
    end
  end

  describe "#run_intelligent_assignment" do
    before :each do
      session[:user] = build(:instructor)
      params = ActionController::Parameters.new(id: assignment.id)
      allow(controller).to receive(:params).and_return(params)
      allow(controller).to receive(:redirect_to).with(controller: 'tree_display', action: "list")
    end
    context "with valid assignment id" do
      it "should not set any error message in the flash" do
        controller.run_intelligent_assignment
        expect(controller).not_to set_flash[:error]
      end
      it "should redirect to list action in tree_display controller" do
        expect(controller).to receive(:redirect_to).with(controller: 'tree_display', action: "list")
        controller.run_intelligent_assignment
      end
    end
    context "with no participants" do
      before :each do
        allow(controller).to receive(:construct_users_bidding_info).and_return([])
      end
      it "should set error message in the flash" do
        controller.run_intelligent_assignment
        expect(controller).to set_flash[:error]
      end
      it "should redirect to list action in tree_display controller" do
        expect(controller).to receive(:redirect_to).with(controller: 'tree_display', action: "list")
        controller.run_intelligent_assignment
      end
    end
  end

  describe "#construct_teams_bidding_info" do
    it "should generate teams bidding info hash based on newly created teams" do
      unassigned_teams = [assignment_team1, assignment_team2]
      sign_up_topics = [topic1, topic2]
      teams_bidding_info = controller.send(:construct_teams_bidding_info, unassigned_teams, sign_up_topics)
      expect(teams_bidding_info.size).to eq(2)
    end
  end

  describe "#match_new_teams_to_topics" do
    it "assigns topics to teams" do
      expect(assignment_2.is_intelligent).to eq(false)
      controller.send(:match_new_teams_to_topics, assignment_2)
      expect(assignment_2.is_intelligent).to eq(false)
      expect(controller).to set_flash[:error]

      expect(assignment.is_intelligent).to eq(true)
      Bid.create(team_id: assignment_team1.id, topic_id: topic1.id)
      Bid.create(team_id: assignment_team2.id, topic_id: topic2.id)
      controller.send(:match_new_teams_to_topics, assignment)
      expect(assignment.is_intelligent).to eq(false)
      expect(controller).to set_flash[:success]
    end
  end

  describe "#merge_bids_from_different_previous_teams" do
    before :each do
      @team_id = assignment_team1.id
      @user_ids = [team_user1.id, team_user2.id, team_user3.id]
      @user_bidding_info = [{pid: team_user1.id, ranks: [1, 0, 2, 2]},
                            {pid: team_user2.id, ranks: [2, 1, 3, 0]},
                            {pid: team_user3.id, ranks: [3, 2, 1, 1]}]
    end
    it "should create bids objects of the newly-merged team on each sign-up topics" do
      bid_count = Bid.count
      controller.send(:merge_bids_from_different_previous_teams, @sign_up_topics, @team_id, @user_ids, @user_bidding_info)
      expect(Bid.count).to eq(bid_count + 4)
      expect(Bid.find_by(topic_id: 1, team_id: 1, priority: 1)).to_not be nil
      expect(Bid.find_by(topic_id: 2, team_id: 1, priority: 3)).to_not be nil
      expect(Bid.find_by(topic_id: 3, team_id: 1, priority: 2)).to_not be nil
      expect(Bid.find_by(topic_id: 4, team_id: 1, priority: 4)).to_not be nil
      expect(Bid.find_by(topic_id: 1, team_id: 1, priority: 2)).to be nil
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
        number_of_team_users = TeamsUser.count
        controller.send(:remove_user_from_previous_team, @assignment.id, @team_user3.user_id)

        expect(TeamsUser.count).to eq(number_of_team_users - 1)
        expect(TeamsUser.find_by(user_id: @team_user3.user_id)).to be nil
        expect(TeamsUser.find_by(user_id: @team_user2.user_id)).to eq @team_user2
        expect(TeamsUser.find_by(user_id: @team_user1.user_id)).to eq @team_user1
      end
    end
    describe "#remove_empty_teams" do
      it "should reduce the number of teams by the number of empty teams in the assignment" do
        create(:assignment_team, assignment: @assignment, teams_users: [])
        number_of_teams = AssignmentTeam.count
        number_of_teams_in_assignment = Assignment.find(@assignment.id).teams.count
        controller.send(:remove_empty_teams, @assignment)
        expect(AssignmentTeam.count).to eq(number_of_teams - 1)
        expect(Assignment.find(@assignment.id).teams.count).to_not eq(number_of_teams_in_assignment)
      end
    end
  end

  describe "#assign_available_slots" do
    it "should assign topic to team of biggest size" do
      @topic_bids1 = [{topic_id: topic1.id, priority: 1}]
      @team_bids = [{team_id: assignment_team1.id, bids: @topic_bids1}]
      number_of_signed_up_teams = SignedUpTeam.count
      controller.send(:assign_available_slots, @team_bids)
      expect(SignedUpTeam.count).to eq(number_of_signed_up_teams + 1)
    end
  end
end
