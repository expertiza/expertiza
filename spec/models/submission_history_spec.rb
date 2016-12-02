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
end