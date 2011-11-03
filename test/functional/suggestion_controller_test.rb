require File.dirname(__FILE__) + '/../test_helper'
require 'suggestion_controller'

# Re-raise errors caught by the controller.
class SuggestionController; def rescue_action(e) raise e end; end

class SuggestionControllerTest < ActionController::TestCase
  fixtures :users
  
  def setup
    @controller = SuggestionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new     
    @request.session[:user] = users(:superadmin)  
  end

  def test_add_suggestion
    params = {:title => "title1",:description => "description1", :signup_preference => "pref"}
    post(:create, {:suggestion => params})
    assert_response 302
  end
  
  def test_update_suggestion
    params = {:title => "title1",:description => "description1", :signup_preference => "pref"}
    post(:create, {:suggestion => params})
        
    up_params = {:title => "title_updated",:description => "description1", :signup_preference => "pref"}
    put(:update,{:suggestion => up_params})
    assert_redirected_to :action => 'show'
  end
end