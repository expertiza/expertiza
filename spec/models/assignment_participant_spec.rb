require 'rails_helper'

describe "validations" do
  before(:each) do
    @assignment_participant = build(:assignment_participant)
  end

  it "assignment participant is valid" do
    expect(@assignment_participant).to be_valid
  end
end

describe "#type" do
  it "checks if type is assignment participant" do
    assignment_participant = build(:assignment_participant)
    expect(assignment_participant.type).to eq("AssignmentParticipant")
  end
end

describe "#average_scores" do
  it "returns 0 if self.response_maps is empty" do
    assignment_participant = build(:assignment_participant)
    sum_scores = assignment_participant.average_score
    expect(sum_scores).to be_zero
  end
end

describe "#copy" do
  it "creates a copy if part is empty" do
    assignment_participant = build(:assignment_participant)
    course_part = assignment_participant.copy(0)
    expect(course_part).to eq(CourseParticipant.create(user_id: self.user_id, parent_id: course_id))
  end
end

