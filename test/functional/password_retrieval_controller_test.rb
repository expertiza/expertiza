require File.dirname(__FILE__) + '/../test_helper'
require 'password_retrieval_controller'

# Re-raise errors caught by the controller.
class PasswordRetrievalController; def rescue_action(e) raise e end; end

class PasswordRetrievalControllerTest < ActionController::TestCase
  fixtures :users
  
  def setup
    @controller = PasswordRetrievalController.new  
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_reset_password
    user = users :student4
    original_password = user.password
    
    assert_emails 1 do # should have sent one reminder email
      post :send_password, :user => {:email => user.email}
    end
    user = User.find_by_email user.email
    
    assert_equal nil, flash[:pwerr]
    assert flash[:pwnote].present?
    assert_not_equal original_password, user.password
  end
end
