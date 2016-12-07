require 'test_helper'

class ReviewMetricTest < ActiveSupport::TestCase
  def setup
  	@valid_review_for_student = ReviewMetric.new(response_id: Resonse.last.id)
  	@valid_review_for_instructor = ReviewMetric.new(assignment_id: ResponseMaps.reviewed_object_id, reviewer_id: ResponseMaps.reviewer_id)
  	@invalid_review = ReviewMetric.new
  end

  test "object should be valid"  do
  	assert @valid_review.valid?
  end
 
  test "should calculate metrics for valid review for instructor" do
  assert @valid_review_for_instructor.calculate_metrics_for_instructor(assignment_id, reviewer_id)
  end

  test "should calculate metrics for valid review for student" do
  assert @valid_review_for_student.calculate_metrics_for_student(response_id)
  end

  test "should not calculate metrics for invalid review for instructor" do
  assert_not @invalid_review.calculate_metrics_for_instructor(assignment_id, reviewer_id)
  end

  test "should not calculate metrics for invalid review for student" do
  assert_not @invalid_review.calculate_metrics_for_student(response_id)
  end
  
end
