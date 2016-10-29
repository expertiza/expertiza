require 'rails_helper'


describe Participant do

  before(:each) do
    @student = create(:student, name: "Student", fullname: "Student Test", email: "student1@gmail.com" )
    @assignment = create(:assignment, name: "Assignment1", course: nil)
    @participant = create(:participant, parent_id: @assignment.id, user_id: @student.id)
    @assignment_questionnaire1 =create(:assignment_questionnaire, user_id: @student.id, assignment: @assignment)
  end
  it "is valid" do
    expect(@participant).to be_valid
  end
  it "can submit" do
    expect(@participant.can_submit).to be true
  end
  it "can review" do
    expect(@participant.able_to_review).to be true
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
 it "has topic name" do
   expect(@participant.topic_name).to eql "<center>&#8212;</center>"
 end
  it "has a name" do
    expect(@participant.name).to eql "Student"
  end
  it "has a full name" do
    expect(@participant.fullname).to eql "Student Test"
  end

end

