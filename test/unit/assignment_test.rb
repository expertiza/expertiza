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
    # Intentionally set name to nothing to test validates_presence_of rsjohns3
    assignment.name = ""
    assert !assignment.valid?    
    
    # Submitter count is initialized to 0 by the controller.
    assert_equal assignment.submitter_count, 0
  end

end