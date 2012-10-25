require File.dirname(__FILE__) + '/../test_helper'

class LeaderboardTest < ActiveSupport::TestCase
  fixtures :response_maps, :participants, :score_caches, :assignments
  set_fixture_class :score_caches => ScoreCache

  def test_scoreCache
    score_cache = ScoreCache.new(:object_type =>  "TeamReviewResponseMap")
    assert score_cache.save
  end

  def test_score
    score_cache = score_caches(:sc0)
    score = score_cache.score
    assert score <= 100
  end

  def test_getIndependantAssignments
    participant = participants(:par14)
    assignment =  Assignment.find(participant.parent_id)
    assert_not_nil assignment
  end

  def test_getAssessmentsFor
    @participant = participants(:par14)
    assessments = FeedbackResponseMap.get_assessments_for(@participant)
    assert_equal assessments, @participant.get_feedback
  end

  def test_getParticipantEntriesInAssignment
    assignment = Assignment.find_by_instructor_id(9999999999999999999999999999999999999999999)
    assert_nil assignment
  end

  def test_deleteNotForce
    participant = participants(:par1)
    participant.delete
    assert participant.valid?
  end

  def test_getAssignmentsInCourses
    assignment = Assignment.find_all_by_course_id(0)
    assert assignment.blank?
  end


end