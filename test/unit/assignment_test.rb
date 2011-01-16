require File.dirname(__FILE__) + '/../test_helper'

class AssignmentTest < Test::Unit::TestCase
  fixtures :assignments

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
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

    # Instructor_id is initialized to the current user by the controller ... needs to be checked by a functional test.
    
    #assert assignment.errors.invalid?(:course_id)
    #assert assignment.errors.invalid?(:private)
    #assert assignment.errors.invalid?(:num_reviewers)
    #assert assignment.errors.invalid?(:num_review_of_reviewers)
    #assert assignment.errors.invalid?(:review_strategy_id)
    #assert assignment.errors.invalid?(:mapping_strategy_id)


end