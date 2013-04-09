
require File.dirname(__FILE__) + '/../test_helper'
require 'questionnaire_controller'

 class QuestionnaireController;
  def rescue_action(a) raise a end;
end

class QuestionnaireControllerTest < ActionController::TestCase
  fixtures :questionnaires
  fixtures :users
  fixtures :question_advices
  fixtures :questions
  
  def initial
    @controller = QuestionnaireController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @Questionnaire = questionnaires(:questionnaire1).id
    @request.session[:user] = User.find( users(:superadmin).id )

     rankinfo = User.find(users(:superadmin).id).rankinfo
    Rank.rebuild_cache
    Rank.find(rankinfo).cache[:credentials]
    @request.session[:credentials] = Rank.find(rankinfo).cache[:credentials]
    AuthController.set_current_role(rankinfo,@request.session)
  end
  
  def test_questionnaire_edit
    post :edit, {:id => @Questionnaire, :save => true, 
                       :questionnaire => {:name => "test edit name", 
                                   :type => "ReviewQuestionnaire",
                                   :min_question_score => 1,
                                   :max_question_score => 3}}
    assert_response(:success)
    assert_not_nil(Questionnaire.find(:first, :conditions => ["name = ?", "test edit name"]))
  end
  
  
  def test_Questionnaire_edit_for_existing_name
    
    assert_raise (ActionView::TemplateError){
      post :edit_questionnaire, :id => @Questionnaire, :save => true,:questionnaire => {:name => questionnaires(:questionnaire2).name}
    }
    assert_template 'questionnaire/edit_questionnaire'
  end
  
  def test_edit_questionnaire_when_name_not_valid
   
    assert_raise (ActionView::TemplateError){
      post :edit_questionnaire, :id => @Questionnaire, :save => true,:questionnaire => {:name => ""}
    }
  end
  
  
  def test_advice_to_be_saved
    
    post :save_advice, :id => @Questionnaire, :advice =>  { "#{Fixtures.identify(:advice0)}"=> { :advice => "test" } }   
    
    assert_response :redirect
    assert_equal "The  Question advice in Questionnaire has been  saved", flash[:notice]
    assert_redirected_to :action => 'list'
  end

  def test_edit_questionnaire_instruction_url
    post :edit, {:id => @Questionnaire, :save => true,
                 :questionnaire => {:name => "test edit name",
                                    :type => "ReviewQuestionnaire",
                                    :min_question_score => 1,
                                    :max_question_score => 3,
                                    :instruction_loc => "http://www.expertiza.ncsu.edu"}}
    assert_response(:success)
    assert_not_nil(Questionnaire.find(:first, :conditions => ["name = ?", "test edit name"]))
  end
end
