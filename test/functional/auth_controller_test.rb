require File.dirname(__FILE__) + '/../test_helper'
require 'suggestion_controller'

# Re-raise errors caught by the controller.
class SuggestionController; def rescue_action(e) raise e end; end

class SuggestionControllerTest < ActionController::TestCase
  
  def setup
    @controller = SuggestionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new       
  end

  # Verify that admin accounts are sent to tree_display.
  def test_valid_admin_login
    post :login, :login => {:name => users(:superadmin).name, :password => users(:superadmin).name}
    assert_redirected_to :controller => AuthHelper::get_home_controller(session[:user]), :action => AuthHelper::get_home_action(session[:user])
  end
  

end