require File.dirname(__FILE__) + '/../test_helper'

class RubricControllerTest < ActionController::IntegrationTest
  def setup
    @controller = RubricController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def login_instructor
    post "/auth/login", :login => {:name => 'ed_gehringer', :password => 'ed_gehringer'}
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  def test_list_no_login
    # Try to access the rubrics listing without logging in
    get "/rubric/list"
    assert_response :redirect
  end
  
  def test_list
    login_instructor
    get "/rubric/list"
    assert_response :success
  end
  
  def test_create_empty_rubric
    login_instructor
    size = Rubric.find(:all).length
    post "/rubric/create_rubric", "save"
    assert_response :error
  end
  
  def test_create_rubric
    login_instructor
    size = Rubric.find(:all).length + 1
    post "/rubric/create_rubric",
         :save => "save",
         :rubric => {:id => "4",
                     :name => "rubric test", 
                     :min_question_score => "1",
                     :max_question_score => "5",
                     :private => "true"}
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert size, Rubric.find(:all).length
    
    new_rubric = Rubric.find_by_name("rubric test")
    assert_equal new_rubric.name, "rubric test"
    assert_equal new_rubric.min_question_score, 1
    assert_equal new_rubric.max_question_score, 5
    assert new_rubric.private
  end
  
  def test_delete
    # Delete a rubric with no assignments associated with it.
    login_instructor
    size = Rubric.find(:all).length
    get "/rubric/delete_rubric/1"
    assert_response :redirect # Rubric 1 has no assignments
    follow_redirect!
    assert_response :success
    assert size, Rubric.find(:all).length - 1
  end
  
  def test_delete_unknown_rubric
    # User is redirected to the list if the rubric id is bogus
    login_instructor
    size = Rubric.find(:all).length
    get "/rubric/delete_rubric/9834343"
    assert_response :redirect 
    follow_redirect!
    assert_response :success
    assert size, Rubric.find(:all).length
  end
end
