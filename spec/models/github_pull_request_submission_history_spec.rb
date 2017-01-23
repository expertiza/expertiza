require "rails_helper"

describe GithubPullRequestSubmissionHistory do
  describe "get_submitted_at_time" do
    it "should return the last time a github pull request was updated" do
      history_object = GithubPullRequestSubmissionHistory.new
      time_stamp = history_object.get_submitted_at_time("https://github.com/prerit2803/expertiza/pull/1")
      expect(time_stamp).not_to be_empty
    end
  end
end
