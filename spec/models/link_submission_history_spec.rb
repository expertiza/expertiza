require 'rails_helper'

describe LinkSubmissionHistory do
  describe "add submission" do
    it "should add GithubRepoSubmissionHistory" do
      assignment = build(Assignment)
      assignment.save
      assignment_team = build(AssignmentTeam)
      assignment_team.parent_id = assignment.id
      assignment_team.submit_hyperlink("https://github.com/prerit2803/expertiza")
      assignment_team.save
      expect_any_instance_of(SubmissionHistory).to receive(:get_submitted_at_time)
      LinkSubmissionHistory.add_submission(assignment.id)
    end
  end
end
