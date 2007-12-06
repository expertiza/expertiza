require File.dirname(__FILE__) + '/../test_helper'

class RubricControllerTest < ActionController::IntegrationTest
  def setup
    @controller = QuestionnaireController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def log_instructor_in
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
    log_instructor_in
    get "/questionnaire/list"
    assert_response :success
  end
  
  def test_create_empty_rubric
    log_instructor_in
    size = Questionnaire.find(:all).length
    post "/questionnaire/create_rubric", "save"
    assert_response :error
  end
  
  def test_create_rubric
    log_instructor_in
    size = Questionnaire.find(:all).length + 1
    post "/questionnaire/create_rubric",
         :save => "save",
         :rubric => {:id => "4",
                     :name => "rubric test", 
                     :min_question_score => "1",
                     :max_question_score => "5",
                     :private => "true"}
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert size, Questionnaire.find(:all).length
    
    new_rubric = Questionnaire.find_by_name("rubric test")
    assert_equal new_rubric.name, "rubric test"
    assert_equal new_rubric.min_question_score, 1
    assert_equal new_rubric.max_question_score, 5
    assert new_rubric.private
  end
  
  def test_delete
    # Delete a rubric with no assignments associated with it.
    log_instructor_in
    size = Questionnaire.find(:all).length
    get "/questionnaire/delete_rubric/1"
    assert_response :redirect # Rubric 1 has no assignments
    follow_redirect!
    assert_response :success
    assert size, Questionnaire.find(:all).length - 1
  end
  
  def test_delete_unknown_rubric
    # User is redirected to the list if the rubric id is bogus
    log_instructor_in
    size = Questionnaire.find(:all).length
    get "/rubric/delete_rubric/9834343"
    assert_response :redirect 
    follow_redirect!
    assert_response :success
    assert size, Questionnaire.find(:all).length
  end
end
