require File.dirname(__FILE__) + '/../test_helper'
require 'assessment360_controller'

# Re-raise errors caught by the controller.
class Assessment360; def rescue_action(e) raise e end; end

class Assessment360ControllerTest < ActionController::TestCase
  # use dynamic fixtures to populate users table
  # for the use of testing
  fixtures :users
  fixtures :assignments
  fixtures :questionnaires
  fixtures :courses
  fixtures :participants
  fixtures :response_maps
  set_fixture_class :system_settings => 'SystemSettings'
  fixtures :system_settings
  fixtures :content_pages
  @settings = SystemSettings.find(:first)

   def testNoOfAllReviewsAssignedToUser
     user = users(:student1)
     course = courses(:course_object_oriented)
     @participant = Participant.find_all_by_user_id(user)
     @participant_course = Array.new
     @participant.each do |participant|
       if(participant.type == 'AssigmentParticipant')
         @participant_course << participant
       end
     end
     @user_test = User.find(user.id)
     test_data = @user_test.get_total_reviews_assigned(course)
     assert_equal @participant_course.count, test_data
   end

  def testNoOfAllReviewsCompletedByUser
     user = users(:student4)
     course = courses(:course_object_oriented)
     @participant = Participant.find_all_by_user_id(user)
     @participant_course = Array.new
     @participant.each do |participant|
       if(participant.type == 'AssignmentParticipant')
         @participant_course << participant
       end
     end
     @user_test = User.find(user.id)
     test_data = @user_test.get_total_reviews_completed(course)
     assert_equal @participant_course.count, test_data
  end

  def testNoOfMetareviewsCompletedByUser
    user = users(:student4)
     course = courses(:course_object_oriented)
     @participant = Participant.find_all_by_user_id(user)
     @participant_course = Array.new
     @participant.each do |participant|
       if(participant.type == 'AssignmentParticipant')
         @participant_course << participant
       end
     end
     @user_test = User.find(user.id)
     test_data = @user_test.get_total_reviews_completed_by_type("Metareviews",course)
     assert_equal @participant_course.count, test_data
  end
  
  def testNoOfMetareviewsAssignedUser
    user = users(:student4)
     course = courses(:course_object_oriented)
     @participant = Participant.find_all_by_user_id(user)
     @participant_course = Array.new
     @participant.each do |participant|
       if(participant.type == 'AssignmentParticipant')
         @participant_course << participant
       end
     end
     @user_test = User.find(user.id)
     test_data = @user_test.get_total_reviews_assigned_by_type("Metareviews",course)
     assert_equal @participant_course.count, test_data
  end

  def testNoOfTeamreviewsCompletedByUser
    user = users(:student4)
     course = courses(:course_object_oriented)
     @participant = Participant.find_all_by_user_id(user)
     @participant_course = Array.new
     @participant.each do |participant|
       if(participant.type == 'AssignmentParticipant')
         @participant_course << participant
       end
     end
     @user_test = User.find(user.id)
     test_data = @user_test.get_total_reviews_completed_by_type("Teamreview",course)
     assert_equal @participant_course.count, test_data
  end
  
  def testNoOfTeamreviewsAssignedToUser
    user = users(:student4)
     course = courses(:course_object_oriented)
     @participant = Participant.find_all_by_user_id(user)
     @participant_course = Array.new
     @participant.each do |participant|
       if(participant.type == 'AssignmentParticipant')
         @participant_course << participant
       end
     end
     @user_test = User.find(user.id)
     test_data = @user_test.get_total_reviews_assigned_by_type("Teamreview",course)
     assert_equal @participant_course.count, test_data
  end
  
  def testNoOfTeammatereviewsCompletedByUser
    user = users(:student4)
     course = courses(:course_object_oriented)
     @participant = Participant.find_all_by_user_id(user)
     @participant_course = Array.new
     @participant.each do |participant|
       if(participant.type == 'AssignmentParticipant')
         @participant_course << participant
       end
     end
     @user_test = User.find(user.id)
     test_data = @user_test.get_total_reviews_completed_by_type("Teammatereview",course)
     assert_equal @participant_course.count, test_data
  end
  
  def testNoOfTeammatereviewsAssignedToUser
    user = users(:student4)
     course = courses(:course_object_oriented)
     @participant = Participant.find_all_by_user_id(user)
     @participant_course = Array.new
     @participant.each do |participant|
       if(participant.type == 'AssignmentParticipant')
         @participant_course << participant
       end
     end
     @user_test = User.find(user.id)
     test_data = @user_test.get_total_reviews_assigned_by_type("Teammatereview",course)
     assert_equal @participant_course.count, test_data
  end
  
  def testNoOfFeedbackCompletedByUser
    user = users(:student4)
     course = courses(:course_object_oriented)
     @participant = Participant.find_all_by_user_id(user)
     @participant_course = Array.new
     @participant.each do |participant|
       if(participant.type == 'AssignmentParticipant')
         @participant_course << participant
       end
     end
     @user_test = User.find(user.id)
     test_data = @user_test.get_total_reviews_completed_by_type("Feedback",course)
     assert_equal @participant_course.count, test_data
  end
  
  def testNoOfFeedbackAssignedToUser
    user = users(:student4)
     course = courses(:course_object_oriented)
     @participant = Participant.find_all_by_user_id(user)
     @participant_course = Array.new
     @participant.each do |participant|
       if(participant.type == 'AssignmentParticipant')
         @participant_course << participant
       end
     end
     @user_test = User.find(user.id)
     test_data = @user_test.get_total_reviews_assigned_by_type("Feedback",course)
     assert_equal @participant_course.count, test_data
  end
  
 def testUniqueUsersForCourse
    @course = courses(:course_object_oriented)
    @assignments = Assignment.find_all_by_course_id(@course.id)
    @participants = Participant.find_all_by_parent_id(@ass)
    @users = @course.get_course_participants()
 end
 
  # def testshouldgetindex
  #       user = users(:admin)
  #       sign_in @user
  #       get "/assessment360"
  #       assert_response ! :success
  #       #assert_redirected_to! :controller => "assessment360", :action => "index"
  #    end
 
  def  getindex 
    get :index
    assert_response(:success)
  end

  def redirecttoassessment360
         get "/assessment360"
         assert_response (:success)
         assert_redirected_to :controller => "assessment360", :action => "index"
  end
 
  end 