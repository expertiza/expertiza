require 'rails_helper'
# include GradesHelper

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
