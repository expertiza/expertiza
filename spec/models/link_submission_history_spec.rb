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
      puts assignment.id
      puts assignment_team.parent_id
      puts assignment_team.hyperlinks
      puts assignment.teams[0].hyperlinks
      # puts assignment_team.assignment.id
      expect_any_instance_of(SubmissionHistory).to receive(:get_submitted_at_time)
      LinkSubmissionHistory.add_submission(assignment.id)
      puts SubmissionHistory.all.size
    end
  end
end
