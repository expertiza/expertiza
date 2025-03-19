describe BiddingController do
  let(:assignment) { create(:assignment, is_intelligent: true, name: 'assignment', directory_path: 'assignment') }
  let(:assignment_2) { create(:assignment, is_intelligent: false, name: 'assignment_2', directory_path: 'assignment_2') }

  let(:student1) { create(:student, name: 'student1') }
  let(:student2) { create(:student, name: 'student2') }
  let(:student3) { create(:student, name: 'student3') }
  let(:student4) { create(:student, name: 'student4') }
  let(:student5) { create(:student, name: 'student5') }
  let(:student6) { create(:student, name: 'student6') }

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

  describe '#action_allowed?' do
    it 'allows Instructors, Teaching Assistants, Administrators to run the bid' do
      session[:user] = build(:instructor)
      expect(controller.action_allowed?).to be true
      session[:user] = build(:teaching_assistant)
      expect(controller.action_allowed?).to be true
      session[:user] = build(:admin)
      expect(controller.action_allowed?).to be true
    end
    it 'does not allow Students or Visitors to run the bid' do
      session[:user] = student1
      expect(controller.action_allowed?).to be false
      session[:user] = nil
      expect(controller.action_allowed?).to be false
    end
  end
end
