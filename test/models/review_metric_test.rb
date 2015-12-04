require 'test_helper'

class ReviewMetricTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @valid_review = ReviewMetric.new(response_id: Response.last.id)
    @invalid_review = ReviewMetric.new
  end

  test "object should be valid " do
    assert @valid_review.valid?
  end
  test "should calculate metrics for valid response_id" do
    assert @valid_review.calulate_metric
  end
  test "should not calculate metrics for invalid response_id" do
    assert_not @invalid_review.calulate_metric
  end



end
