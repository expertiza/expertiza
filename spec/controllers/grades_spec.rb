require 'rails_helper'
# include GradesHelper
include LogInHelper # TEMP USED TO AUTHORIZE SESSION

describe GradesController do
  before :each do
    controller.class.skip_before_filter :authorize
  end

  xit 'returns the score for an assignment' do
    assignmentParticipant = double(AssignmentParticipant)
    assignment = double(Assignment)
    # questionnaires=double(Questionnaire)
    allow(AssignmentParticipant).to receive("find").and_return(assignmentParticipant)
    allow(assignmentParticipant).to receive(:assignment).and_return(assignment)
    allow(assignment).to receive("questionnaires").and_return([])
    allow(assignmentParticipant).to receive("scores").and_return([1, 2])
    @params = {id: 1}
    expect { get :edit, @params }.to eq([1, 2])
  end

  xit 'prepares the email content for a conflict notification email when user is instructor' do
    user = double(Assignment)
    allow(user).to receive(:timezonepref) { nil }
    allow(user).to receive(:super_admin?) { true }
    participant = double(AssignmentParticipant)
    allow(participant).to receive(:parent_id) { 15 }
    allow(user).to receive(:role_id) { 4 }
    session[:user] = user

    allow(AssignmentParticipant).to receive(:find) { participant }
    assignment = double(Assignment)
    allow(assignment).to receive(:name) { "assignment name" }
    allow(Assignment).to receive("find") { assignment }

    questionnaire = double(Questionnaire)
    allow(questionnaire).to receive(:symbol) { "a" }
    allow(questionnaire).to receive(:questions) { [] }

    user1 = double(User)
    user2 = double(User)
    allow(user1).to receive(:super_admin?) { true }
    allow(user2).to receive(:super_admin?) { true }
    allow(user1).to receive(:timezonepref) { nil }
    # allow(user1).to receive(:super_admin?){true}
    allow(user2).to receive(:timezonepref) { nil }
    # allow(user2).to receive(:super_admin?){true}
    allow(user1).to receive(:fullname) { "full name" }
    allow(user2).to receive(:fullname) { "name full" }
    allow(user1).to receive(:email) { "abc@xyz.com" }
    allow(user2).to receive(:email) { "xyz@abc.com" }

    review1 = double(User)
    allow(review1).to receive(:map) { review1 }
    allow(review1).to receive(:reviewer) { review1 }
    allow(review1).to receive(:user) { user1 }

    review2 = double(User)
    allow(review2).to receive(:map) { review2 }
    allow(review2).to receive(:reviewer) { review2 }
    allow(review2).to receive(:user) { user2 }

    allow(participant).to receive(:reviews) { [review1, review2] }

    allow(assignment).to receive(:questionnaires).and_return([questionnaire])
    allow(questionnaire).to receive(:find_by_type) { questionnaire }

    @params = {submission: "review", id: 5}

    get :conflict_notification, @params
  end

  xit 'prepares the email content for a conflict notification email when user is a TA' do
    user = double(Assignment)
    allow(user).to receive(:timezonepref) { nil }
    allow(user).to receive(:super_admin?) { true }
    participant = double(AssignmentParticipant)
    allow(participant).to receive(:parent_id) { 15 }
    allow(user).to receive(:role_id) { 6 }
    session[:user] = user

    instructor = double(Instructor)
    allow(Ta).to receive(:get_my_instructor) { instructor }

    allow(AssignmentParticipant).to receive(:find) { participant }
    assignment = double(Assignment)
    allow(assignment).to receive(:name) { "assignment name" }
    allow(Assignment).to receive("find") { assignment }

    questionnaire = double(Questionnaire)
    allow(questionnaire).to receive(:symbol) { "a" }
    allow(questionnaire).to receive(:questions) { [] }

    user1 = double(User)
    user2 = double(User)
    allow(user1).to receive(:super_admin?) { true }
    allow(user2).to receive(:super_admin?) { true }
    allow(user1).to receive(:timezonepref) { nil }
    allow(user1).to receive(:super_admin?) { true }
    allow(user2).to receive(:timezonepref) { nil }
    allow(user2).to receive(:super_admin?) { true }
    allow(user1).to receive(:fullname) { "full name" }
    allow(user2).to receive(:fullname) { "name full" }
    allow(user1).to receive(:email) { "abc@xyz.com" }
    allow(user2).to receive(:email) { "xyz@abc.com" }

    review1 = double(User)
    allow(review1).to receive(:map) { review1 }
    allow(review1).to receive(:reviewer) { review1 }
    allow(review1).to receive(:user) { user1 }

    review2 = double(User)
    allow(review2).to receive(:map) { review2 }
    allow(review2).to receive(:reviewer) { review2 }
    allow(review2).to receive(:user) { user2 }

    allow(participant).to receive(:reviews) { [review1, review2] }

    allow(assignment).to receive(:questionnaires).and_return([questionnaire])
    allow(questionnaire).to receive(:find_by_type) { questionnaire }

    @params = {submission: "review", id: 5}

    get :conflict_notification, @params
  end
end

describe GradesController do
  before(:each) do
    # Simulate Authorized Session
    instructor.save
    @user = User.find_by(name: "instructor")
    allow_any_instance_of(ApplicationController).to receive(:current_role_name).and_return('Instructor')
    allow_any_instance_of(ApplicationController).to receive(:undo_link).and_return(TRUE)

    # Allow Access to Private Methods
    @controller = GradesController.new

    # Create Assignment and Questionnaires
    @assignment = create(:assignment)
    @questionnaire = create(:questionnaire)
    @assignment_questionnaire = create(:assignment_questionnaire, used_in_round: 2)
    @question1 = create(:question, txt: "Who?")
    @question2 = create(:question, txt: "What?")
    @questions = {question1: @question1, question2: @question2}
    @questionnaires = [@questionnaire]
  end

  describe "Calculate review questions" do
    it "returns the correct minimum, maximum, and number of questions" do
      min, max, questions = @controller.send(:calculate_review_questions, @assignment, @questionnaires)
      expect(min).to eq(0)
      expect(max).to eq(5)
      expect(questions).to eq(2)
    end
  end

  describe "Get team data" do
    it "returns a blank array when there are no teams" do
      scores = @assignment.scores(@questions)
      data = @controller.send(:get_team_data, @assignment, @questionnaires, scores)
      expect(data).to eq([])
    end
    it "returns a valid data structure with the correct participants" do
      create_list(:participant, 1)
      student = User.where(role_id: 2).second # Since Instructor is First
      team = create(:assignment_team)
      create(:team_user, user: student, team: team)

      scores = @assignment.scores(@questions)
      scores[:teams]["0".to_sym][:team] = team

      data = @controller.send(:get_team_data, @assignment, @questionnaires, scores)
      participants = data.first.first.listofteamparticipants # Team Data -> VMList -> VmQuestionResponse
      expect(participants.first.user_id).to eq(student.id)
    end
  end

  describe "Get highchart data" do
    it "properly initializes the chart hash" do
      data = @controller.send(:get_highchart_data, [], @assignment, 1, 3, 1)
      expect(data).to eq(1 => {1 => [0], 2 => [0], 3 => [0]})
    end
  end

  describe "Generate highchart" do
    it "returns the correct series" do
      series, _categories = @controller.send(:generate_highchart, {1 => {1 => [5]}}, 1, 1, 1)
      expect(series).to eq([{name: "Score 1 - Submission 1", data: [5], stack: "S1"}])
    end
    it "returns the correct categories" do
      _series, categories = @controller.send(:generate_highchart, {1 => {1 => [5, 10]}}, 1, 1, 2)
      expect(categories).to eq(["Rubric 1", "Rubric 2"])
    end
  end
end
