require "rails_helper"

describe GithubRepoSubmissionHistory do
  describe "get_submitted_at_time" do
    it "should return the last time a github repo was pushed" do
      history_object = GithubRepoSubmissionHistory.new
      time_stamp = history_object.get_submitted_at_time("https://github.com/prerit2803/expertiza/")
      expect(time_stamp).not_to be_empty
    end
  end
end
