require File.dirname(__FILE__) + '/../test_helper'
require 'response_controller'

# Re-raise errors caught by the controller.
class ResponseController; def rescue_action(e) raise e end; end

class ResponseControllerTest < ActionController::TestCase

  fixtures :all

  def setup
    @controller = ResponseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @request.session[:user] = User.find(users(:student1).id ) # change the student
    roleid = User.find(users(:student1).id).role_id  # change the student
    Role.rebuild_cache

    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
    @settings = SystemSettings.find(:first)

    AuthController.set_current_role(roleid,@request.session)
  end


  def test_create_response_for_quiz
    number_of_responses = Response.count

    map_id = Fixtures.identify(:quiz_response_map)
    additional_comment = "Quiz taken"
    q1_option_id = Fixtures.identify(:quiz2_q1_advice2)
    q2_option_id = Fixtures.identify(:quiz2_q2_advice2)

    post :create, {:id => map_id, :review => {:comments => additional_comment}, :option_0 => q1_option_id, :option_1 => q2_option_id}

    assert_equal number_of_responses + 1, Response.count
    assert_equal map_id, Response.last.map_id
    msg = "Your response was successfully saved."
    error_msg = ""
    assert_redirected_to :controller => 'response', :action => 'saving', :id => map_id, :msg => msg, :error_msg => error_msg

  end

end