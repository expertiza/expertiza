include AssignmentHelper

describe LotteryController do
  let(:assignment) { create(:assignment, is_intelligent: true) }
  let(:assignment2) { build(:assignment) }
  let(:ta) { build(:teaching_assistant) }
  let(:instructor) { build(:instructor) }
  let(:admin) { build(:admin) }

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
  let(:team_user6) { create(:team_user, team_id: assignment_team3.id, user_id: student6.id, id: 6) }

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

    create(:bid, topic_id: topic1.id, team_id: assignment_team1.id, priority: 1)
    create(:bid, topic_id: topic2.id, team_id: assignment_team2.id, priority: 2)
    create(:bid, topic_id: topic4.id, team_id: assignment_team2.id, priority: 1)
    create(:bid, topic_id: topic3.id, team_id: assignment_team2.id, priority: nil)
    create(:bid, topic_id: topic4.id, team_id: assignment_team3.id, priority: 5)
    create(:bid, topic_id: topic4.id, team_id: assignment_team1.id, priority: 3)

    @expected_users_bidding_info = [{pid: student1.id, ranks: [1, 0, 0, 3]},
                                    {pid: student2.id, ranks: [1, 0, 0, 3]},
                                    {pid: student3.id, ranks: [1, 0, 0, 3]},
                                    {pid: student4.id, ranks: [0, 2, 0, 1]},
                                    {pid: student5.id, ranks: [0, 0, 0, 5]},
                                    {pid: student6.id, ranks: [0, 0, 0, 5]}]

    @team_users = []
    @team_users << team_user1 << team_user2 << team_user3

    @teams = assignment.teams
    @sign_up_topics = assignment.sign_up_topics
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
end
