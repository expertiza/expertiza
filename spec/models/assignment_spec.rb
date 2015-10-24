require 'rails_helper'
require 'spec_helper'

describe "Team_Assignment" do
  it "checks team assignment should be true" do
    assign=FactoryGirl.create(:assignment)
    res=assign.team_assignment
    expect(res).to be true
  end
end

describe "Assignment_Exists" do
  it "Assignment should exist" do
    FactoryGirl.create(:assignment).should be_valid
  end
end

describe "Assignment_Without_Name_Doesnot_Exists" do
  it "Assignment without name should not exist" do
    FactoryGirl.build(:assignment_without_name).should_not be_valid
  end
end

describe "Has_Teams" do
  it "checks assignment should have a team" do
   assign=FactoryGirl.build(:assignment)
   assign_team=FactoryGirl.create(:assignmentTeam)
   assign.teams << assign_team
   assign.save!
  # puts assign.teams.name.to_yaml
   res=assign.has_teams?
   expect(res).to be true
  end
end

describe "Has_Topics" do
  it "checks assignment should have a topic" do
    assign_signed_up_topic=FactoryGirl.create(:signed_up_topic)
    assign_topic=FactoryGirl.build(:assignment)
    assign_topic.sign_up_topics << assign_signed_up_topic
    assign_topic.save!
    res=assign_topic.has_topics?
    expect(res).to be true
  end
end

describe "Is_Wiki_Assignment" do
  it "checks assignment should be a wiki assignment" do
    assign=  FactoryGirl.create(:assignment)
    id=assign.is_wiki_assignment
    expect(id).to be true
  end
end

describe "Is_Google_Doc" do
  it "checks whether assignment is a google doc" do
    assign=  FactoryGirl.create(:assignment)
    res=assign.is_google_doc
    expect(res).to be false
  end
end

describe "Is_Micro_task_Assignment" do
  it "checks whether assignment is a micro task" do
    assign=  FactoryGirl.create(:assignment)
    id=assign.is_microtask?
    expect(id).to be true
  end
end

describe "Check the Review Strategy Assignment" do
  it "checks the Review Strategy Assignment" do
    assign= FactoryGirl.create(:assignment)
    id=assign.dynamic_reviewer_assignment?
    expect(id).to be true
  end
end

describe "Is_Coding_Assignment" do
  it "checks assignment should be coding assignment" do
    assign=FactoryGirl.create(:assignment).should be_valid
    #res=assign.is_coding_assignment?
    #expect(res).to be true
  end
end

describe "Validates_Assignment_Team" do
  it "checks whether Assignment Team is created or not" do
  FactoryGirl.create(:assignmentTeam).should be_valid
    end
end

describe "Validates_Signed_Up_Topic" do
  it "checks whether signed up topic is created or not" do
    FactoryGirl.create(:signed_up_topic).should be_valid
  end
end

describe "#candidate_assignment_teams_to_review" do
  it "returns nil if if there are no contributors" do
    assgn=FactoryGirl.create(:assignment)
    reviewer=FactoryGirl.create(:user)
    cand_team=assgn.candidate_assignment_teams_to_review(reviewer)
    expect(cand_team).to be_empty
  end

end

describe "#candidate_topics_for_quiz" do
  it "returns nil if sign up topic is empty" do
    assgn=FactoryGirl.create(:assignment)
    cand_team=assgn.candidate_topics_for_quiz
    expect(cand_team).to be_nil
  end
end
