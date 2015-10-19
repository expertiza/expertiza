require 'spec_helper'
require 'rails_helper'

describe Assignment do
  it "when is valid" do
    create(:assignment).should be_valid
  end

end

describe "#candidate_assignment_teams_to_review" do
  it "returns nil if if there are no contributors" do
    assgn=FactoryGirl.build(:assignment)
    reviewer=FactoryGirl.build(:user)
    cand_team=assgn.candidate_assignment_teams_to_review(reviewer)
    expect(cand_team).to be_empty
  end
end

describe "#candidate_topics_for_quiz" do
  it "returns nil if sign up topic is empty" do
    assgn=FactoryGirl.build(:assignment)
    cand_team=assgn.candidate_topics_for_quiz
    expect(cand_team).to be_nil
  end

end

