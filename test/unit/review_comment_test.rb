require File.dirname(__FILE__) + '/../test_helper'

class ReviewCommentTest < ActiveSupport::TestCase

  test "CreateSampleComment" do
    rc = ReviewComment.new
    rc.review_file_id = 5
    rc.comment_content = "Sample Comment"
    rc.reviewer_participant_id = 6
    rc.file_offset = 100
    assert rc.save
  end
end