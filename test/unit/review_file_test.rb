require File.dirname(__FILE__) + '/../test_helper'

class ReviewFileTest < ActiveSupport::TestCase

  test "CreateReviewFileRecord" do
    rf = ReviewFile.new
    rf.filepath = "/dummy/path"
    rf.author_participant_id = 5
    rf.version_number = 6
    assert rf.save
  end
end