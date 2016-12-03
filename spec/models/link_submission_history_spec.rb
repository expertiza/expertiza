require 'rails_helper'

describe LinkSubmissionHistory do
  describe"add submission" do
    it "should add GithubRepoSubmissionHistory" do
      assignment = build(Assignment)
      assignment_team = build(AssignmentTeam)
      assignment_team.assignment = assignment
      assignment_team.submit_hyperlink("https://github.com/prerit2803/expertiza")
      assignment_team.save
      # puts assignment_team.hyperlinks
      # puts assignment_team.parent_id
      # # puts assignment_team.assignment.id
      # expect(LinkSubmissionHistory).to receive(:add_submission)
      # expect_any_instance_of(AssignmentTeam).to receive(:hyperlinks)
      # expect(SubmissionHistory).to receive(:create)
      # expect(LinkSubmissionHistory).to receive(:create)
      # expect(GithubSubmissionHistory).to receive(:create)
      # expect(GithubRepoSubmissionHistory).to receive(:create)
      # expect_any_instance_of(SubmissionHistory).to receive(:get_submitted_at_time)
      LinkSubmissionHistory.add_submission(assignment.id)
      puts SubmissionHistory.all.size
    end
  end
end
