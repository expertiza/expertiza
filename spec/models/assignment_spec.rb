require 'rails_helper'

xdescribe "validations" do
  it "assignment should exist" do
    expect(FactoryGirl.create(:assignment)).to be_valid
  end
	
  it "assignment without name should not exist" do
    expect(FactoryGirl.build(:assignment_without_name)).not_to be_valid
  end

  it "checks whether Assignment Team is created or not" do
     expect(FactoryGirl.create(:assignmentTeam)).to be_valid
  end
	
  it "checks whether signed up topic is created or not" do
    expect(FactoryGirl.create(:signed_up_topic)).to be_valid
  end

end

xdescribe "#team_assignment" do
  it "checks team assignment should be true" do
    assign = FactoryGirl.create(:assignment)
    res = assign.team_assignment
    expect(res).to be true
  end
end

xdescribe "#has_teams?" do
  it "checks assignment should have a team" do
    assign = FactoryGirl.build(:assignment)
    assign_team = FactoryGirl.create(:assignmentTeam)
    assign.teams << assign_team
    assign.save!
    res = assign.has_teams?
    expect(res).to be true
  end
end

xdescribe "#has_topics?" do
  it "checks assignment should have a topic" do
    assign_signed_up_topic = FactoryGirl.create(:signed_up_topic)
    assign_topic = FactoryGirl.build(:assignment)
    assign_topic.sign_up_topics << assign_signed_up_topic
    assign_topic.save!
    res = assign_topic.has_topics?
    expect(res).to be true
  end
end

xdescribe "#is_google_doc" do
  it "checks whether assignment is a google doc" do
    skip('#is_google_doc no longer exists in assignment.rb file.')
    assign = FactoryGirl.create(:assignment)
    res = assign.is_google_doc
    expect(res).to be false
  end
end

xdescribe "#is_microtask?" do
  it "checks whether assignment is a micro task" do
    assign = FactoryGirl.create(:assignment)
    id = assign.is_microtask?
    expect(id).to be true
  end
end

xdescribe "#dynamic_reviewer_assignment?" do
  it "checks the Review Strategy Assignment" do
    assign = FactoryGirl.create(:assignment)
    id = assign.dynamic_reviewer_assignment?
    expect(id).to be true
  end
end

xdescribe "#is_coding_assignment?" do
  it "checks assignment should be coding assignment" do
    expect(FactoryGirl.create(:assignment)).to be_valid
   end
end

xdescribe "#candidate_assignment_teams_to_review" do
  it "returns nil if if there are no contributors" do
    assign = FactoryGirl.create(:assignment)
    reviewer = FactoryGirl.create(:user)
    cand_team = assign.candidate_assignment_teams_to_review(reviewer)
    expect(cand_team).to be_empty
  end

end

xdescribe "#candidate_topics_for_quiz" do
  it "returns nil if sign up topic is empty" do
    assign = FactoryGirl.create(:assignment)
    cand_team = assign.candidate_topics_for_quiz
    expect(cand_team).to be_nil
  end
end
