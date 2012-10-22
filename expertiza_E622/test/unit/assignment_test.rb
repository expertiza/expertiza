require File.dirname(__FILE__) + '/../test_helper'

class AssignmentTest < ActiveSupport::TestCase
  fixtures :assignments

  def test_invalid_with_empty_attributes
    # Create a new assignment
    assignment = Assignment.new
    # Assignment should not be valid, because some fields have not been created.
    assert !assignment.valid?
    # These two fields have been created, so they should be invalid.
    assert assignment.errors.invalid?(:name)
    
    # Submitter count is initialized to 0 by the controller.
    assert_equal assignment.submitter_count, 0
    # assert_equal assignment.instructor_id, (session[:user]).id
  end

  def test_database_returns_review_mappings_in_order_of_creation_and_uses_sequential_ids
    p = AssignmentParticipant.create :handle => 'assignment'
    (1..5).each do |i|
      map = ParticipantReviewResponseMap.create :reviewer_id => i, :reviewee_id => i, :reviewed_object_id => i # use reviewer_id to store the sequence
      p.review_mappings << map
    end
    
    # clear any association cache by redoing the find
    p = AssignmentParticipant.find(p.id)
    
    latest_id = 0
    lowest_sequence = 0
    p.review_mappings.each do |map|
      assert latest_id < map.id
      assert lowest_sequence < map.reviewer_id
      latest_id = map.id
      lowest_sequence = map.reviewer_id
    end
  end

end
