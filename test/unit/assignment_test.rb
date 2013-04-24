require File.dirname(__FILE__) + '/../test_helper'

class AssignmentTest < ActiveSupport::TestCase

  fixtures :questionnaires, :assignments

  def setup
    # Database was initialized with (at least) 3 questionnaires.
    @questionnaire1 = Questionnaire.find(questionnaires(:questionnaire1).id)
    @questionnaire2 = Questionnaire.find(questionnaires(:questionnaire2).id)
    @questionnaire3 = Questionnaire.find(questionnaires(:questionnaire3).id)
  end

  def test_validate_name
    # Create a new assignment
    a = Assignment.new
    # Assignment should not be valid, because some fields have not been created.
    assert !a.valid?
    # These two fields have been created, so they should be invalid.
    assert a.errors.invalid?(:name)
  end

  # Scope of the assignment is defined by the a combination of the directory_path and instructor_id
  def test_uniqueness_scope
    a = Assignment.create! :name => 'a', :directory_path => "Home", :instructor_id => 1
    b = Assignment.create :name => 'b', :directory_path => "Home", :instructor_id => 1
    assert !b.valid?
    assert b.errors.invalid?(:directory_path)
  end
    
  #duplicate names must not be present
  def test_duplicate_name
    a = Assignment.new

    a.course_id = 1
    a.instructor_id = 1
    a.name = "Sam"
    a.save

    assert !a.duplicate_name?
  end

  #As there are no signup topics has_topics returns a false
  def test_has_topics
    a = Assignment.new
    assert !a.has_topics?
  end
    
  #The maximum score gets computed appropriately
  def test_get_max_score_possible
    a = Assignment.new
    assert a.get_max_score_possible(@questionnaire1)
  end

  def test_get_review_questionnaire_id
    a = Assignment.new
    assert !a.get_review_questionnaire_id
  end
end
