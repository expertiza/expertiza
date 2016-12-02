require 'rails_helper'

describe SubmissionHistory do
  describe "create method" do
    it "should create link submission history" do
      assignment_team = build(AssignmentTeam)
      link = "https://github.com/prerit2803/expertiza"
      submission_history = SubmissionHistory.create(assignment_team, link)
      submission_history.should be_a(GithubRepoSubmissionHistory)
    end
  end
end