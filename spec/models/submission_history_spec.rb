require 'rails_helper'

describe SubmissionHistory do
  describe "create method" do
    it "should create link submission history" do
      assignment_team = build(AssignmentTeam)
      link = "https://www.youtube.com/watch?v=dQw4w9WgXcQ&ab_channel=RickAstleyVEVO"
      submission_history = SubmissionHistory.create(assignment_team, link)
      expect(submission_history).to be_a(LinkSubmissionHistory)
    end

    it "should create github link submission history" do
      assignment_team = build(AssignmentTeam)
      link = "https://github.com/prerit2803/expertiza"
      submission_history = SubmissionHistory.create(assignment_team, link)
      expect(submission_history).to be_a(GithubRepoSubmissionHistory)
    end

    it "should create wikipedia link submission history" do
      assignment_team = build(AssignmentTeam)
      link = "http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2016/oss_E1663"
      submission_history = SubmissionHistory.create(assignment_team, link)
      expect(submission_history).to be_a(WikipediaSubmissionHistory)
    end

    it "should create google doc link submission history" do
      assignment_team = build(AssignmentTeam)
      link = "https://docs.google.com/document/d/1fI5KbPXCJ8dSUyLynnqC__A3MtZ47enNfMcki3Vf3uk/edit"
      submission_history = SubmissionHistory.create(assignment_team, link)
      expect(submission_history).to be_a(GoogledocSubmissionHistory)
    end

    it "should create file submission history" do
      assignment_team = build(AssignmentTeam)
      link = "/user/home/Expertiza_gemfile"
      submission_history = SubmissionHistory.create(assignment_team, link)
      expect(submission_history).to be_a(FileSubmissionHistory)
    end
  end

  describe "delete method" do
    it "should add a row to submission history table with action as delete" do
      assignment_team = build(AssignmentTeam)
      link = "/user/home/Expertiza_gemfile"
      submission_history = SubmissionHistory.delete_submission(assignment_team, link)
      expect(submission_history.action).to eq("delete")
    end

    it "should add a row to submission history table with action as edit" do
      assignment_team = build(AssignmentTeam)
      link = "/user/home/Expertiza_gemfile"
      submission_history = SubmissionHistory.create(assignment_team, link)
      submission_history.submitted_at = Time.current
      submission_history.save

      submission_history2 = SubmissionHistory.create(assignment_team, link)
      submission_history2.submitted_at = Time.current
      submission_history2.save
      expect(submission_history2.action).to eq("edit")
    end
  end

  describe "add submission" do
    it "should add GithubRepoSubmissionHistory" do
      assignment = build(Assignment)
      assignment_team = build(AssignmentTeam)
      assignment_team.assignment = assignment
      assignment_team.submit_hyperlink("https://github.com/prerit2803/expertiza")
      assignment_team.save
      puts assignment_team.hyperlinks
      puts assignment_team.parent_id
      # puts assignment_team.assignment.id
      expect(LinkSubmissionHistory).to receive(:add_submission)
      expect_any_instance_of(AssignmentTeam).to receive(:hyperlinks)
      expect(SubmissionHistory).to receive(:create)
      expect(LinkSubmissionHistory).to receive(:create)
      expect(GithubSubmissionHistory).to receive(:create)
      expect(GithubRepoSubmissionHistory).to receive(:create)
      expect_any_instance_of(GithubRepoSubmissionHistory).to receive(:get_submitted_at_time)
      LinkSubmissionHistory.add_submission(assignment.id)
    end
  end
end
