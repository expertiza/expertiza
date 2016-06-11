require 'rails_helper'

describe "validations" do
  before(:each) do
    @assignment = build(:assignment)
  end

  it "assignment is valid" do
    expect(@assignment).to be_valid
  end

  it "assignment without name is not valid" do
    @assignment.name = nil
    @assignment.save
    expect(@assignment).not_to be_valid
  end

  it "checks whether Assignment Team is created or not" do
    expect(create(:assignment_team)).to be_valid
  end

  it "checks whether signed up topic is created or not" do
    expect(create(:topic)).to be_valid
  end
end

describe "#team_assignment" do
  it "checks an assignment has team" do
    assignment = build(:assignment)
    expect(assignment.team_assignment).to be true
  end
end

describe "#has_teams?" do
  it "checks an assignment has a team" do
    assignment = build(:assignment)
    assign_team = build(:assignment_team)
    assignment.teams << assign_team
    expect(assignment.has_teams?).to be true
  end
end

describe "#has_topics?" do
  it "checks an assignment has a topic" do
    assignment = build(:assignment)
    topic = build(:topic)
    assignment.sign_up_topics << topic
    expect(assignment.has_topics?).to be true
  end
end

describe "#is_google_doc" do
  it "checks whether assignment is a google doc" do
    skip('#is_google_doc no longer exists in assignment.rb file.')
    assignment = build(:assignment)
    res = assignment.is_google_doc
    expect(res).to be false
  end
end

describe "#is_microtask?" do
  it "checks whether assignment is a micro task" do
    assignment = build(:assignment, microtask: true)
    expect(assignment.is_microtask?).to be true
  end
end

describe "#dynamic_reviewer_assignment?" do
  it "checks the Review Strategy Assignment" do
    assignment = build(:assignment)
    expect(assignment.dynamic_reviewer_assignment?).to be true
  end
end

describe "#is_coding_assignment?" do
  it "checks assignment is coding assignment or not" do
    assignment = build(:assignment)
    expect(assignment.is_coding_assignment?).to be false
  end
end

describe "#candidate_assignment_teams_to_review" do
  it "returns nil if if there are no contributors" do
    assignment = build(:assignment)
    reviewer = build(:participant)
    cand_team = assignment.candidate_assignment_teams_to_review(reviewer)
    expect(cand_team).to be_empty
  end
end

describe "#candidate_topics_for_quiz" do
  it "returns nil if sign up topic is empty" do
    assignment = build(:assignment)
    cand_topic = assignment.candidate_topics_for_quiz
    expect(cand_topic).to be_nil
  end
end
