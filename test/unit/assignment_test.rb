require File.dirname(__FILE__) + '/../test_helper'

class AssignmentTest < ActiveSupport::TestCase
  fixtures :assignments, :assignment_questionnaires, :questionnaires, :courses, :questions, :response_maps, :responses

  def test_get_metareview_questionnaire_id()
    assignment = assignments(:assignment5)
    assert_equal questionnaires(:questionnaire2).id,assignment.get_metareview_questionnaire_id()
  end

  def test_get_assignments_for_course()
    assert_equal [assignments(:assignment1)],Assignment.get_assignments_for_course(courses(:course1))
  end

  def test_get_review_comments()
    response_type = ["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"]
    assignment = assignments(:assignment2)
    assert_equal [],assignment.get_review_comments(response_type)
  end

  def test_average_tokens()
    assignment = assignments(:assignment0)
    assert_equal 5,assignment.average_tokens(["This is a test review"])
    assert_equal 1,assignment.average_tokens(["TeSt test"])
    assert_equal 3.0,assignment.average_tokens(["This is a test review","TEST test"])
  end

  def test_get_review_questions()
    assignment = assignments(:assignment2)
    assert_equal [questions(:question1).txt],assignment.get_review_questions("ReviewQuestionnaire")
  end

  def test_count_average_subquestions()
    assignment = assignments(:assignment2)
    assert_equal 1,assignment.count_average_subquestions("ReviewQuestionnaire")
  end

  def test_get_number_of_reviewers()
    assignment = assignments(:assignment2)
    assert_equal 0,assignment.get_number_of_reviewers("ReviewQuestionnaire")
  end

  def test_count_questions()
    assignment = assignments(:assignment2)
    assert_equal 1,assignment.count_questions("ReviewQuestionnaire")
  end

  def test_get_average_num_of_reviews()
    assignment = assignments(:assignment2)
    assert_equal 1,assignment.get_average_num_of_reviews(["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"])
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
