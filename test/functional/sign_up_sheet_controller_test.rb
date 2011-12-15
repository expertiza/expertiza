require File.dirname(__FILE__) + '/../test_helper'
require 'sign_up_sheet_controller'

# Re-raise errors caught by the controller.
class SignUpSheetController; def rescue_action(e) raise e end; end

class SignUpSheetControllerTest < ActionController::TestCase
  # use dynamic fixtures to populate users table
  # for the use of testing
  fixtures :users
  fixtures :assignments
  fixtures :courses
  fixtures :deadline_types
  fixtures :due_dates
  fixtures :participants
  fixtures :sign_up_topics
  set_fixture_class :system_settings => 'SystemSettings'
  fixtures :system_settings
  fixtures :teams
  fixtures :teams_users
  fixtures :content_pages
  @settings = SystemSettings.find(:first)

  def setup
    @controller = AssignmentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    # Initialize the user to student team formation 1 by default
    @request.session[:user] = User.find(users(:student_team_formation1).id )
    roleid = User.find(users(:student_team_formation1).id).role_id
    Role.rebuild_cache

    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    # Work around a bug that causes session[:credentials] to become a YAML Object
    @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
    @settings = SystemSettings.find(:first)
    AuthController.set_current_role(roleid,@request.session)
    #   @request.session[:user] = User.find_by_name("suadmin")
  end

  # Test Case student can sign up for topic
  def test_successful_sign_up
    topicid = sign_up_topics(:first_topic).id

    # Setup the session
    @request.session[:user] = users(:student_team_formation1)
    
    #call the sign_up_topic controller to sign up the user for topic.
    #SignUpSheetController.signup
    get(:signup, {'assignment_id' => assignments(:assignment_team_formation).id}, {'confirm_by' => 0}, {'id' => topicid}) 
    
    #This should pass fine as the student is paired with student_team_formation2 and max required
    #students for topic is 2
    #Check for no error message
    #assert_equal flash[:error], nil
    
    #backup code
    #assert_response :redirect
    #assert_equal Assignment.count, number_of_assignment
    #assert Assignment.find(:all, :conditions => "name = 'updatedAssignment9'")
  end

  # Test Case student can't sign up for topic
  def test_unsuccessful_sign_up
    topicid = sign_up_topics(:first_topic).id

    # Setup the session
    session[:user] = users(:student_team_formation3)
    
    #call the sign_up_topic controller to sign up the user for topic.
    get(:signup, {'assignment_id' => assignments(:assignment_team_formation).id}, {'confirm_by' => 0}, {'id' => topicid}) 
    
    #This should fail as the student is not teamed up with anyone else and the max students for topic is 2
    #Check for error message
    #assert_redirected_to :controller => "sign_up_sheet", :action => "signup_topic"
    #assert_equal flash[:error], "You need to have between 2 and 3 members in your team to sign up for a topic at this time. However, your team currently has 1 member(s)."
    
    #backup code
    ##assert_select "div.message", "You need to have between 2 and 3 members in your team to sign up for a topic at this time. However, your team currently has 1 member(s)."
    ##assert_tag :tag => 'div',
    ##           :attributes => { :class => 'flash error' },
    ##           :content => 'You need to have between 2 and 3 members in your team to sign up for a topic at this time. However, your team currently has 1 member(s).'

  end


end






