require File.dirname(__FILE__) + '/../test_helper'
require 'review_mapping_controller'

# Re-raise errors caught by the controller.
class ReviewMappingController; def rescue_action(e) raise e end; end

class ReviewMappingControllerTest < ActionController::TestCase

  fixtures :all

  def setup
    @controller = ReviewMappingController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @request.session[:user] = User.find(users(:admin).id )
    roleid = User.find(users(:admin).id).role_id
    Role.rebuild_cache

    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
    @settings = SystemSettings.find(:first)

    AuthController.set_current_role(roleid,@request.session)
  end

  def test_assign_quiz_dynamically
    number_of_responses = ResponseMap.count

    assign_id = Fixtures.identify(:assignment_quiz)
    reviewer = Participant.first(:conditions => {:parent_id => assign_id})
    post :assign_quiz_dynamically, {:assignment_id => assign_id, :reviewer_id => reviewer.user_id}

    assert_equal number_of_responses+1, ResponseMap.count
    quiz_response_map = ResponseMap.last
    assert quiz_response_map.instance_of? QuizResponseMap
    assert_equal quiz_response_map.reviewer_id, reviewer.id
    assert_redirected_to :controller => 'student_quiz', :action => 'list', :id => reviewer.id
  end

  def test_review_report
    assign_id = Fixtures.identify(:assignment1)
    user = Participant.first(:conditions => {:parent_id => assign_id})

    post :review_report, {:id => assign_id}, session_for(users(:admin))

    assert_template :review_report
  end

  def test_search_by_reviewer
    assign_id = Fixtures.identify(:assignment1)
    user = Participant.first(:conditions => {:parent_id => assign_id})

    post :review_report, {:id => assign_id, :user => {:fullname => user.fullname}}, session_for(users(:admin))

    assert_template :review_report
  end

end