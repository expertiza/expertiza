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
    # Try to access the questionnaires listing without logging in
    get "/questionnaire/list"
    assert_response :redirect
  end
  
  def test_list
    log_instructor_in
    get "/questionnaire/list"
    assert_response :success
  end
  
  def test_create_empty_questionnaire
    log_instructor_in
    size = Questionnaire.find(:all).length
    post "/questionnaire/create_questionnaire", "save"
    assert_response :error
  end
  
  def test_create_questionnaire
    log_instructor_in
    size = Questionnaire.find(:all).length + 1
    post "/questionnaire/create_questionnaire",
         :save => "save",
         :questionnaire => {:id => "4",
                     :name => "questionnaire test", 
                     :min_question_score => "1",
                     :max_question_score => "5",
                     :private => "true"}
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert size, Questionnaire.find(:all).length
    
    new_questionnaire = Questionnaire.find_by_name("questionnaire test")
    assert_equal new_questionnaire.name, "questionnaire test"
    assert_equal new_questionnaire.min_question_score, 1
    assert_equal new_questionnaire.max_question_score, 5
    assert new_questionnaire.private
  end
  
  def test_delete
    # Delete a questionnaire with no assignments associated with it.
    log_instructor_in
    size = Questionnaire.find(:all).length
    get "/questionnaire/delete_questionnaire/1"
    assert_response :redirect # questionnaire 1 has no assignments
    follow_redirect!
    assert_response :success
    assert size, Questionnaire.find(:all).length - 1
  end
  
  def test_delete_unknown_questionnaire
    # User is redirected to the list if the questionnaire id is bogus
    log_instructor_in
    size = Questionnaire.find(:all).length
    get "/questionnaire/delete_questionnaire/9834343"
    assert_response :redirect 
    follow_redirect!
    assert_response :success
    assert size, Questionnaire.find(:all).length
  end
end
