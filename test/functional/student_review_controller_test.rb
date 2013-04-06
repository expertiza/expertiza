require "test_helper"
require 'student_review_controller'

class StudentReviewController; def rescue_action(e) raise e end; end

class StudentReviewControllerTest < ActionController::TestCase

  fixtures :participants, :assignments, :users, :response_maps, :roles, :topic_deadlines, :teams
  def setup
    @participant = participants(:par1)
    @assignment = assignments(:assignment1)
    @user = users(:student1)
    @request.session[:user] = User.find(users(:student1).id)
  end

  #Test case used to verify the session_id and user_id of logged in user
  def test_get_current_user_id_and_verify

    participant=Participant.find(participants(:par1))
    assignment=Assignment.find(:first,:conditions => ["id=?",participant.parent_id] )
    session[:user] = @user
    printf(assignment.inspect)
    participant_user_id = participant.user_id
    result = session[:user].id
    assert_equal(participant_user_id, result)

  end


  #Test case will pass in case a user tries to log in as an invalid user
  #In case the user enters incorrect value the test will pass only for assert_not_equal
  def test_false_current_user_id_and_verify

    participant=Participant.find(participants(:par1))
    assignment=Assignment.find(:first,:conditions => ["id=?",participant.parent_id] )
    session[:user].id = 5
    printf(assignment.inspect)
    participant_user_id = participant.user_id
    result = session[:user].id
    assert_not_equal(participant_user_id, result)

  end

  #Test case for retreiving the current stage of the assignment
  #The stage can be "complete", "resubmission", "rereview" and "submission"
  def test_get_current_stage

    participant=Participant.find(participants(:par0))
    assignment=Assignment.find(:first,:conditions => ["id=?",participant.parent_id] )
    session[:user] = @user
    current_stage = assignment.get_current_stage(participant.topic_id)
    result = "rereview"
    assert_equal(current_stage, result)

  end

  #Testing the functionality of finding the correct reviewer_id
  #This test is to validate when a user is a reviewer.
  #The find_all_by_reviewer_id will validate whether the logged in user is a reviewer using his reviewer_id
  def test_find_reviewer_id

    participant=Participant.find(participants(:par14))
    response_map14 = ResponseMap.find(response_maps(:response_maps3))
    session[:user] = @user
    review_mapping = ParticipantReviewResponseMap.find_all_by_reviewer_id(participant.id)
    assert_equal(response_map14.to_a, review_mapping.to_a)

  end

  #Testing the number of review rounds for a given assignment.
  #review_rounds is a variable which is associated with the number of times an assignment has been reviewed.
    def test_verify_rounds

    participant = Participant.find(participants(:par0))
    assignment = Assignment.find(:first, :conditions => ["id=?", participant.parent_id])
    review_rounds = assignment.get_review_rounds
    result = 2
    assert_equal(result, review_rounds)

  end

  #Test to verify the reviewer_id. This test case is used to verify the correct 
  #reviewer_id using the topic_id and the deadline_id of the assignment
  def test_review_allowed_id

    participant = Participant.find(participants(:par5))
    assignment = Assignment.find(:first, :conditions => ["id=?", participant.parent_id])
    topic_id = TopicDeadline.find_by_topic_id_and_deadline_type_id(participant.topic_id,1)
    result = 1
    printf(topic_id.inspect)
    assert_equal(result, topic_id.review_allowed_id)

  end

  #Test to verify the rereview_allowed_id using the topic_id and deadline_id for a given assignment.
  def test_rereview_allowed_id

    participant = Participant.find(participants(:par5))
    assignment = Assignment.find(:first, :conditions => ["id=?", participant.parent_id])
    topic_id = TopicDeadline.find_by_topic_id_and_deadline_type_id(participant.topic_id,1)
    result = 1
    printf(topic_id.inspect)
    assert_equal(result, topic_id.review_allowed_id)

  end

  #Test to verify team_review_id for a given team.
  def test_verify_team_review_response

    participant = Participant.find(participants(:par2))
    response_map = ResponseMap.find(response_maps(:response_maps0))
    assignment = Assignment.find(:first, :conditions => ["id=?", participant.parent_id])
    review_mapping = TeamReviewResponseMap.find_by_reviewer_id(participant.id)
    assert_equal(response_map.to_a, review_mapping.to_a)

  end

  #Test to verify the metareviewer_id for a given participant.
  def test_find_metareviewer_id

    participant=Participant.find(participants(:par15))
    response_map15 = ResponseMap.find(response_maps(:response_map8))
    session[:user] = @user
    review_mapping = MetareviewResponseMap.find_all_by_reviewer_id(participant.id)
    assert_equal(response_map15.to_a, review_mapping.to_a)

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    participant = nil
    assignment = nil
  end



end