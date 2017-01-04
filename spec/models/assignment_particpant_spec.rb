require 'rails_helper'
describe "AssignmentParticipant" do
  describe "validations" do
    it "assignment participant is valid" do
      assignment_participant = build(:participant)
      expect(assignment_participant).to be_valid
    end
  end

  describe "#type" do
    it "checks if type is assignment participant" do
      assignment_participant = build(:participant)
      expect(assignment_participant.type).to eq("AssignmentParticipant")
    end
  end

  describe "#average_scores" do
    it "returns 0 if self.response_maps is empty" do
      assignment_participant = build(:participant)
      sum_scores = assignment_participant.average_score
      expect(sum_scores).to be_zero
    end
  end

  describe "#copy" do
    it "creates a copy if part is empty" do
      assignment_participant = build(:participant)
      course_part = assignment_participant.copy(0)
      expect(course_part).to be_an_instance_of(CourseParticipant)
    end
  end

  describe "#import" do
    it "raise error if record is empty" do
      row = []
      expect { AssignmentParticipant.import(row, nil, nil, nil) }.to raise_error("No user id has been specified.")
    end

    it "raise error if record does not have enough items " do
      row = ["user_name", "user_fullname", "name@email.com"]
      expect { AssignmentParticipant.import(row, nil, nil, nil) }.to raise_error("The record containing #{row[0]} does not have enough items.")
    end

    it "raise error if assignment with id not found" do
      build(:assignment)
      session = {}
      row = []
      allow(Assignment).to receive(:find).and_return(nil)
      allow(session[:user]).to receive(:id).and_return(1)
      row = ["user_name", "user_fullname", "name@email.com", "user_role_name", "user_parent_name"]
      expect { AssignmentParticipant.import(row, nil, session, 2) }.to raise_error("The assignment with id \"2\" was not found.")
    end

    it "creates assignment participant form record if it does not exist" do
      assignment = build(:assignment)
      session = {}
      allow(Assignment).to receive(:find).and_return(assignment)
      allow(session[:user]).to receive(:id).and_return(1)
      row = ["user_name", "user_fullname", "name@email.com", "user_role_name", "user_parent_name"]
      assign_part = AssignmentParticipant.import(row, nil, session, 2)
      expect(assign_part).to be_truthy
    end
  end
end
