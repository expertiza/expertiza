require "rails_helper"

describe WikipediaSubmissionHistory do
  describe "get_submitted_at_time" do
    it "should return the last time a github pull request was updated" do
      history_object = WikipediaSubmissionHistory.new
      time_stamp = history_object.get_submitted_at_time("http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2016/oss_E1663")
      expect(time_stamp).not_to be_empty
    end
  end
end
