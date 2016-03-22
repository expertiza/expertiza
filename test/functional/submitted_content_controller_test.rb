require File.dirname(__FILE__) + '/../test_helper'

class SubmittedContentControllerTest < ActionController::TestCase
  fixtures :participants
  fixtures :users

  def setup
    @request.session[:user] = User.find(users(:one).id)
  end



end