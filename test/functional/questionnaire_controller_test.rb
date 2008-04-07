require File.dirname(__FILE__) + '/../test_helper'
require 'questionnaire_controller'

# Re-raise errors caught by the controller.
class QuestionnaireController;
  def rescue_action(e) raise e end;
end

class QuestionnaireControllerTest < Test::Unit::TestCase
  fixtures :questionnaires
  fixtures :users
  fixtures :question_advices
  
  def setup
    @controller = QuestionnaireController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @Questionnaire = questionnaires(:questionnaire1).id
    @request.session[:user] = User.find( users(:suadmin_user).id )
  end
  #901 edit an questionnaire’s data
  def test_edit_questionnaire
    post :edit_questionnaire, :id => @Questionnaire, :save => true, 
                       :questionnaire => {:name => "test edit name", 
                                   :type_id => 2,
                                   :min_question_score => 1,
                                   :max_question_score => 3}
                                  
    assert_equal flash[:notice], 'questionnaire was successfully saved.'
    assert_response :redirect
  end
  #802 Add an questionnaire with existing name  
  def test_create_questionnaire_with_existing_name
   # It will raise an error while execute render method in controller
   # Because the goldberg variables didn't been initialized  in the test framework
    assert_raise (ActionView::TemplateError){
      post :create_questionnaire, :save => true, 
                           :questionnaire => {:name => questionnaires(:questionnaire2).name, 
                                       :type_id => 2,
                                       :min_question_score => 1,
                                       :max_question_score => 3, 
                                       :id => @Questionnaire }
    }                               
    assert_template 'questionnaire/new_questionnaire'
  end
  
  # 901
  def test_edit_Questionnaire_with_existing_name
   # It will raise an error while execute render method in controller
   # Because the goldberg variables didn't been initialized  in the test framework
    assert_raise (ActionView::TemplateError){
      post :edit_questionnaire, :id => @Questionnaire, :save => true,:questionnaire => {:name => questionnaires(:questionnaire2).name}
    }
    assert_template 'questionnaire/edit_questionnaire'
  end
  # 902 
  def test_edit_questionnaire_with_invalid_name
  # It will raise an error while execute render method in controller
   # Because the goldberg variables didn't been initialized  in the test framework
    assert_raise (ActionView::TemplateError){
      post :edit_questionnaire, :id => @Questionnaire, :save => true,:questionnaire => {:name => ""}
    }
    assert_template 'questionnaire/edit_questionnaire'
  end
  
  # 1001 edit(save) rurbic's advice
  def test_save_advice
    
    post :save_advice, :id => @Questionnaire, :advice =>  { "1"=> { :advice => "test" } }   
    
    assert_response :redirect
    assert_equal "The questionnaire's question advice was successfully saved", flash[:notice]
    assert_redirected_to :action => 'list'
  end
end