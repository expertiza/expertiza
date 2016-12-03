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
      expect_any_instance_of(GithubRepoSubmissionHistory).to receive(:get_submitted_at_time)
      LinkSubmissionHistory.add_submission(assignment.id)
    end

    it "should add GithubPullRequestSubmissionHistory" do
      assignment = build(Assignment)
      assignment.save
      assignment_team = build(AssignmentTeam)
      assignment_team.parent_id = assignment.id
      assignment_team.submit_hyperlink("https://github.com/prerit2803/expertiza/pull/1")
      assignment_team.save
      expect_any_instance_of(GithubPullRequestSubmissionHistory).to receive(:get_submitted_at_time)
      LinkSubmissionHistory.add_submission(assignment.id)
    end

    it "should add WikipediaSubmissionHistory" do
      assignment = build(Assignment)
      assignment.save
      assignment_team = build(AssignmentTeam)
      assignment_team.parent_id = assignment.id
      assignment_team.submit_hyperlink("http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2016/oss_E1663")
      assignment_team.save
      expect_any_instance_of(WikipediaSubmissionHistory).to receive(:get_submitted_at_time)
      LinkSubmissionHistory.add_submission(assignment.id)
    end
  end
end
