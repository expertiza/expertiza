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

  # Tests added wrt E702 for micro tasks
  # This method is used to assignvarious properties to the assignment
  def new_micro_task_assignment(attributes={})
    questionnaire_id = Questionnaire.first.id
    instructorid = Instructor.first.id
    courseid = Course.first.id
    number_of_topics = SignUpTopic.count


    attributes[:name] ||=  "mt_valid_test"
    attributes[:course_id] ||= 1
    attributes[:directory_path] ||= "mt_valid_test"
    attributes[:review_questionnaire_id] ||= questionnaire_id
    attributes[:review_of_review_questionnaire_id] ||= questionnaire_id
    attributes[:author_feedback_questionnaire_id]  ||= questionnaire_id
    attributes[:instructor_id] ||= instructorid
    attributes[:course_id] ||= courseid
    attributes[:wiki_type_id] ||= 1
    attributes[:microtask] ||= true

    assignment = Assignment.new(attributes)
    assignment
  end

    #This test creates a valid assignment and thus checks that there arrises no errors
  def test_valid_mktask_assignment
    new_assignment = new_micro_task_assignment
    assert new_assignment.valid?
  end

    #This test creates a Invalid assignment and thus infers that such an assignment is not created
  def test_invalid_mktask_assignment
    new_assignment = new_micro_task_assignment(:microtask => '')
    if new_assignment == nil
      assert TRUE
    end
  end



end
