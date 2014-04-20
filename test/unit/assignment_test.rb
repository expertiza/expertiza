require File.dirname(__FILE__) + '/../test_helper'

class AssignmentTest < ActiveSupport::TestCase

  fixtures :questionnaires, :assignments

  def setup
    # Database was initialized with (at least) 3 questionnaires.
    @questionnaire1 = Questionnaire.find(questionnaires(:questionnaire1).id)
    @questionnaire2 = Questionnaire.find(questionnaires(:questionnaire2).id)
    @questionnaire3 = Questionnaire.find(questionnaires(:questionnaire3).id)
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
    b = Assignment.new
    a.directory_path = "Home"
    a.instructor_id = 1
    b = Assignment.create :name => 'b', :directory_path => "Home", :instructor_id => 1
    b.instructor_id = 1

    assert !b.valid?
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

  def test_compute__scores
    a = Assignment.new
    assert a.compute_scores
  end

  def test_sign_up_topics
    a = Assignment.new
    if a.has_topics?
      assert !a.sign_up_topics.empty?
    else
      assert a.sign_up_topics.empty?
    end
  end

  def test_reject_by_no_topic_selection_or_no_submission
    assign = Assignment.new
    user=User.new
    AssignmentParticipant.new(user_id:user.id,parent_id:assign.id)
    contributors = Array.new(Team.find_all_by_parent_id(assign.id))
    contributors=assign.reject_by_no_topic_selection_or_no_submission(contributors)
    assert contributors.empty?
  end

  def test_reject_previously_reviewed_submissions
    assign = Assignment.new
    reviewer=User.new
    reviewee=User.new
    reviewerPart=Participant.new(user_id:reviewer.id,parent_id:assign.id)
    revieweePart=Participant.new(user_id:reviewee.id,parent_id:assign.id)
    ResponseMap.new(reviewed_object_id:assign.id,reviewer_id:reviewerPart.id,reviewee_id:revieweePart.id)
    contributors = Array.new(Team.find_all_by_parent_id(assign.id))
    contributors=assign.reject_previously_reviewed_submissions(contributors,reviewer)
    assert contributors.empty?
  end

  def test_reject_own_submission
    assign = Assignment.find(assignments(:assignment7))
    reviewer=Participant.find(participants(:par14))
    contributors = Array.new(Team.find_all_by_parent_id(assign.id))
    contributors.each {|contributor| assert contributor.teams_users.find_by_user_id(reviewer.id)}

    contributors=assign.reject_own_submission(contributors,reviewer)
    contributors.each {|contributor| assert !contributor.teams_users.find_by_user_id(reviewer.id)}
  end

  def test_reject_by_deadline
    assign = Assignment.find(assignments(:assignment7))
    topic =SignUpTopic.find(sign_up_topics(:topic_deadline331))
    user=User.new
    participant=AssignmentParticipant.new(user_id:user.id,parent_id:assign.id)
    participant.topic_id=topic.id

    contributors = Array.new(Team.find_all_by_parent_id(assign.id))
    assert !contributors.include?(reviewer)
    contributors=assign.reject_own_submission(contributors,reviewer)
    assert !contributors.include?(reviewer)
  end

  def test_candidate_topics_to_review_returns_nil
    assign = Assignment.find(assignments(:assignment_project1))
    participant = Participant.find_by_parent_id(assign.id)
    topics = assign.candidate_topics_to_review(participant)
    assert_equal(nil,topics)
  end
end
