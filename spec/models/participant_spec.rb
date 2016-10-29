require 'rails_helper'


describe Participant do

  before(:each) do
    @student = create(:student, name: "Student", fullname: "Student Test", email: "student1@gmail.com" , password: "123456", password_confirmation: "123456")
    @assignment = create(:assignment, name: "Assignment1", course: nil)
    @participant = create(:participant, parent_id: @assignment.id, user_id: @student.id)
    @assignment_questionnaire1 =create(:assignment_questionnaire, user_id: @student.id, assignment: @assignment)
  end
  it "is valid" do
    expect(@participant).to be_valid
  end

  it "can review" do
    expect(@participant.able_to_review).to be true
  end
  it "can submit" do
    expect(@participant.can_submit).to be true
  end
  it "can take quiz" do
    expect(@participant.can_take_quiz).to be true
  end
  it "has 0 penalty accumulated" do
    expect(@participant.penalty_accumulated).to be_zero
  end
 it "is type of assignment participant" do
   expect(@participant.type).to eql "AssignmentParticipant"
 end
  describe "#topicname" do
 it "returns the topic name" do
   expect(@participant.topic_name).to eql "<center>&#8212;</center>"
 end
 end

  describe "#name" do
    it "returns the name of the user" do
      expect(@participant.name).to eql "Student"
    end
  end
  describe "#fullname" do
  it "returns the full name of the user" do
    expect(@participant.fullname).to eql "Student Test"
  end
  end

end

