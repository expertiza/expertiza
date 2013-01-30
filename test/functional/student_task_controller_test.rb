# Tests for Student task controller
  # Author:   Pongobinath Sivashanmugam

# Date:     15th Oct 2012
require File.dirname(__FILE__) + '/../test_helper'
require 'student_task_controller'


# Re-raise errors caught by the controller.
class StudentTaskController; def rescue_action(e) raise e end; end

class StudentTaskControllerTest < ActionController::TestCase
  # fixtures for the various objects involved in student task controller
  fixtures :users, :roles, :participants, :assignments, :due_dates, :deadline_types, :teams
  # the setup subs 
  def setup
    @controller = StudentTaskController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = User.find(users(:student1).id)
  end


  # FN 01 - GP
  # redirect new user to eula controller
  # if the user enters for the very first time the user should be re directed to EULA controller
  def test_new_user_redirect
    @request.session[:user] = User.find(users(:student1).id)
    user = User.find(users(:student1).id)
    if @request.session[:user].is_new_user = true
      post :list, { :id => users(:student1).id }
      assert_redirected_to  'eula/display'
    end
  end

  # FN 02 - GP
  #get the assignment user participates
  # for a given user id test whether the function returns all the assignment the user participates in
  def test_return_assignment_user_participates
    assignment_assert = Participant.find(participants(:student)).to_a
    assignment_result = AssignmentParticipant.find_all_by_user_id(3, "parent_id DESC")
    assert_equal(assignment_assert,assignment_result)
  end

  #get the assignment user participates
  # for a given user id test whether the function doesnt returns all the assignment the user participates in
  def test_return_assignment_user_participates_negative
    assignment_assert = ""
    assignment_result = AssignmentParticipant.find_all_by_user_id(-1, "parent_id DESC")
    assert_equal(assignment_assert.to_a,assignment_result.to_a)
  end


  #FN 03 - GP
  # get the current stage of the assignment
  # for a given user id and for a particular assignments, return the current stage the assignment is in, test this functionality
  def test_current_stage
    participant=Participant.find(participants(:par1))
    assignment=Assignment.find(:first,:conditions => ["id=?",participant.parent_id] )
    #participant.assignment.get_current_stage()
    stage_result = assignment.get_current_stage(participant.topic_id)
    stage_assert = 'resubmission'
    assert_equal(stage_assert,stage_result)
  end


  #FN 05 - GP
  # get the URL of the user assignment
  # for a given user id and for a particular assignment, return the URLS the user has submitted for the particular the assignment 
  def test_get_url
    participant = Participant.find(participants(:student))
    url_result = participant.get_hyperlinks
    url_assert = participant.submitted_hyperlinks
    assert_equal(url_assert ,url_result )
  end



  #FN 06 - GP
  # get the reviews of the current object assignment by reviewee id
  # return all the assignments the current user participates in review, or review the object
  def test_review_mapping_single
    participant=Participant.find(participants(:par14))
    rmaps_result = ParticipantReviewResponseMap.find_all_by_reviewee_id_and_reviewed_object_id(participant.id, participant.assignment.id)
    rmaps_assert = ResponseMap.find(:first,:conditions => ["reviewed_object_id = ? AND reviewee_id = ? AND type = ?",participant.assignment.id,participant.id,'ParticipantReviewResponseMap'] )
    assert_equal(rmaps_assert.to_a,rmaps_result.to_a)
  end

  def test_review_mapping_single_negative
    participant=Participant.find(participants(:par14))
    rmaps_result = ParticipantReviewResponseMap.find_all_by_reviewee_id_and_reviewed_object_id('-1', '-1')
    rmaps_assert = ''
    assert_equal(rmaps_assert.to_a,rmaps_result.to_a)
  end


  #FN 07 - GP
  # check if the assignment is a team assignment
  # for a given user id test if the assignment that the user participates is team assignment
  def test_team_assignment
    participant=Participant.find(participants(:par13))
    assignment=Assignment.find(:first,:conditions => ["id=?",participant.parent_id] )
    team_result = assignment.team_assignment
    team_assert = 'false'
    assert_equal(team_assert.to_s ,team_result.to_s)
  end




  #FN 08 - GP
  #get the reviewer map by participant id
  #get the review mapping for current team assignment the user participates in 
  def test_review_team
    participant=Participant.find(participants(:par3))
    maps_result = TeamReviewResponseMap.find_all_by_reviewer_id(participant.id)
    maps_assert = ResponseMap.find(:first,:conditions => ["reviewer_id = ? AND type = ?",participant.id,'TeamReviewResponseMap'] )
    printf(maps_assert.inspect)
    printf(maps_result.inspect)
    assert_equal(maps_assert.to_a,maps_result.to_a)
  end

# test if the review objects that the user reviews are incorrectly listed -ve test case
  def test_review_team_negative
    participant=Participant.find(participants(:par3))
    maps_result = TeamReviewResponseMap.find_all_by_reviewer_id('-1')
    maps_assert = ''
    assert_equal(maps_assert.to_a,maps_result.to_a)
  end


  #FN 09 - GP
  #get the review response map by id
  #get the review mapping for current individual  assignment the user participates in 
  def test_review_single
    participant=Participant.find(participants(:par14))
    maps_result = ParticipantReviewResponseMap.find_all_by_reviewer_id(participant.id)
    maps_assert = ResponseMap.find(:first,:conditions => ["reviewer_id = ? AND type = ?",participant.id,'ParticipantReviewResponseMap'] )
    assert_equal(maps_assert.to_a,maps_result.to_a)
  end

#get the review mapping for current individual  assignment the user participates in - ve test case 
  def test_review_single_negative
    participant=Participant.find(participants(:par14))
    maps_result = ParticipantReviewResponseMap.find_all_by_reviewer_id('-1')
    maps_assert = ''
    assert_equal(maps_assert.to_a,maps_result.to_a)
  end

#meta review

  #FN 10 - GP
  # get meta review for assignment by reviewee id
  # get the meta review mapping for all the assignment the current user participates in 
  # for a given assignment of the current user return all the meta review that is done or that is to be done
  def test_meta_review_mapping_all
    participant=Participant.find(participants(:par14))
    rmaps = ParticipantReviewResponseMap.find_all_by_reviewer_id_and_reviewed_object_id(participant.id, participant.assignment.id)
    mmaps_result = MetareviewResponseMap.find_all_by_reviewee_id_and_reviewed_object_id(rmaps[0].reviewer_id,rmaps[0].id)
   mmaps_assert = ResponseMap.find(:first,:conditions => ["reviewed_object_id = ? AND reviewee_id = ? AND type = ?",rmaps[0].id,rmaps[0].reviewer_id,'MetareviewResponseMap'] )
  assert_equal(mmaps_assert.to_a,mmaps_result.to_a)
  end


  #FN 11 - GP
  # get meta review for assignment by reviewer id
  # for a given assignment of the current user return all the meta review that is done or that is to be done
  def test_meta_review_mapping
    participant=Participant.find(participants(:par15))
    mmaps_result = MetareviewResponseMap.find_all_by_reviewer_id(participant.id)
    mmaps_assert = ResponseMap.find(:first,:conditions => [" reviewer_id = ? AND type = ?",participant.id,'MetareviewResponseMap'] )
    printf(mmaps_assert.inspect)
    printf(mmaps_result.inspect)
    assert_equal(mmaps_assert.to_a,mmaps_result.to_a)
  end

  def test_meta_review_mapping_negative
    participant=Participant.find(participants(:par15))
    mmaps_result = MetareviewResponseMap.find_all_by_reviewer_id('-1')
    mmaps_assert = ''
    assert_equal(mmaps_assert.to_a,mmaps_result.to_a)
  end

  #FN 12 - GP

  #find a given participant
  # test whether for a particular participant id, the function returns correct participant details 
  
  def test_find_assignment_participant_view
    participant=Participant.find(participants(:par15))
    assertresult=AssignmentParticipant.find(participant.id)
    assert_equal(participant.to_a,assertresult.to_a)
  end



  #FN 13 - GP

  # find the first member
  # check if the current assignment is team assignment, if yes return the first team member of the team handle
  def test_first_member_negative
    participant=''
    maps_result = AssignmentTeam.get_first_member(-1)
    assert_equal(participant.to_a,maps_result.to_a)
  end


  # FN 14 - GP

  # get the due date of the current topic
  # for a given user id and for a particular assignments, return the current due date based on the current stage the assignment is in, test this functionality
  def test_review_due_date
    participant=Participant.find(participants(:par5))
    assertresult2 =TopicDeadline.find_by_topic_id_and_deadline_type_id(participant.topic_id, 2)
    due_date_result= assertresult2.due_at
    due_date_assert= '2012-10-20 23:31:27'
    assert_equal(due_date_assert.to_s,due_date_result.to_s.sub(' UTC',''))
  end


  #FN: JM - 01
  #Here the test case goes down a gray path and checks if the user has logged in for first time then he
  #should be redirected to eula/display page. So while asserting we look for redirection to the page in
  #question.
  def test_valid_newstudent_student_list
    @request.session[:user] = User.find(users(:student2).id)
    @participant = AssignmentParticipant.find(participants(:par2).id)
    get :list
    assert_redirected_to "/eula/display"
  end

  #FN: JM - 02
  #Here the test case goes down the Happy path and checks that the logged in user is not a first time user
  # and if so then should display the correct list of tasks. This is asserted by checking for the known html 
  #elements that get rendered
  def test_valid_oldstudent_student_list
    @request.session[:user] = User.find(users(:student1).id)
    @participant = AssignmentParticipant.find(participants(:par1).id)
    get :list
    assert_template :list
    assert_select "title","student_task | list"
  end

  #FN: JM - 03
  # This test goes down the Sad path and tries to access the task_list web page witout logging In.
  # In such a scenario the user should be redirected to the denied page. This is been
  # asserted by ensuring that user is redirected to the intended "denied" page.
  def test_invalid_student_task_list
    @request.session[:user] = ""
    @participant = AssignmentParticipant.find(participants(:par1).id)
    get :view, {:id => @participant.id}
    assert_redirected_to "/denied"
  end


  #FN: JM - 04
  # This test goes down the Sad path and tries to access the task_view web page witout logging In.
  # In such a scenario the user should be redirected to the denied page. This is been
  # asserted by ensuring that user is redirected to the intended "denied" page.
  def test_invalid_user_student_task_view
    @request.session[:user] = ""
    @participant = AssignmentParticipant.find(participants(:par1).id)
    get :view, {:id => @participant.id}
    assert_redirected_to "/denied"
  end

  #FN: JM - 05
  # This test tries to fetch the page of others work. As it is a Happy Testng path with all the  
  # correct parameters provided the Others_Work web page should be displayed. This is asserted by
  # checking for the known html elements in the page that got rendered.
  def test_valid_others_work
    @request.session[:user] = User.find(users(:student1).id)
    @participant = AssignmentParticipant.find(participants(:par1).id)
    get :others_work, {:id => @participant.id}
    assert_template :others_work
    assert_select "title","student_task | others_work"
  end

  #FN: JM - 06
  # This test goes down the Sad path and tries to access the Others_work web page witout logging In.
  # In such a scenario the user should be redirected to the denied page. This is been
  # asserted by ensuring that user is redirected to the intended "denied" page.
  def test_invalid_others_work
    @request.session[:user] = ""
    @participant = AssignmentParticipant.find(participants(:par1).id)
    get :others_work, {:id => @participant.id}
    assert_redirected_to "/denied"
  end


  #FN: JM - 07
  # This test aims at checking a functionality that fetches the review date and tries to match it
  # with the one that we know is correct. The test selects a due date based on many conditions and
  # asserts it with a known value passes in fixture. Thus we verify that the correct date is being 
  # displayed on the others_work web page.
  def test_valid_review_dates_others_work
    #@request.session[:user] =  User.find(users(:student1).id)
    @assignment = assignments(:assignment1)
    #@participant = AssignmentParticipant.find(participants(:par1).id)
    due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?", @assignment.id])
    @very_last_due_date = DueDate.find(:all, :order => "due_at DESC", :limit =>1, :conditions => ["assignment_id = ?", @assignment.id])
    next_due_date = @very_last_due_date[0]
    for due_date in due_dates
      if due_date.due_at > Time.now
        if due_date.due_at < next_due_date.due_at
          next_due_date = due_date
        end
      end
    end
    @review_phase = next_due_date.deadline_type_id;

    assert_equal(DeadlineType.find(@review_phase).name , deadline_types(:deadline_type_review).name)
  end



  #FN ## - GP
  def test_the_truth
    assert true
  end

end