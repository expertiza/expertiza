require File.dirname(__FILE__) + '/../test_helper'
require 'questionnaire_controller'

# Re-raise errors caught by the controller.
class QuestionnaireController;
  def rescue_action(e) raise e end;
end

class QuestionnaireControllerTest < ActionController::TestCase
  fixtures :questionnaires
  fixtures :users
  fixtures :question_advices
  fixtures :questions
  
  def setup
    @controller = QuestionnaireController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @Questionnaire = questionnaires(:questionnaire1).id
    @request.session[:user] = User.find( users(:superadmin).id )
    roleid = User.find(users(:superadmin).id).role_id
    Role.rebuild_cache
    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    AuthController.set_current_role(roleid,@request.session)
  end
  #901 edit an questionnaire�s data
  def test_edit_questionnaire
    post :edit, {:id => @Questionnaire, :save => true, 
                       :questionnaire => {:name => "test edit name", 
                                   :type => "ReviewQuestionnaire",
                                   :min_question_score => 1,
                                   :max_question_score => 3}}
    assert_response(:success)
    assert_not_nil(Questionnaire.find(:first, :conditions => ["name = ?", "test edit name"]))
  end

  def test_add_checkbox_option
    post :create_questionnaire, { :questionnaire => {:name => "test create name",
                                   :type => "ReviewQuestionnaire",
                                   :instructor_id => users(:instructor1).id ,
                                   :private => 0,
                                   :min_question_score => 1,
                                   :max_question_score => 3,
                                   :display_type => "Review" },
                                   :new_question => { 1 => {:txt => "This is the question", :true_false => "checkbox"} },

                                   :checkbox_option => {1 => {0 => {:option_text => "Checkbox option test create" } ,
                                                             1 => {:option_text => "Checkbox option 2"} }
                                                       }
                                }
    assert_redirected_to(:controller => "tree_display",:action => "list")
    assert_not_nil(QuestionOption.find(:first, :conditions => ["option_text = ?", "Checkbox option test create"]))
  end

  def test_add_radio_option
    post :create_questionnaire, { :questionnaire => {:name => "test create name",
                                   :type => "ReviewQuestionnaire",
                                   :instructor_id => users(:instructor1).id ,
                                   :private => 0,
                                   :min_question_score => 1,
                                   :max_question_score => 3,
                                   :display_type => "Review" },
                                   :new_question => { 1 => {:txt => "This is the question", :true_false => "radio"} },

                                   :radio_option => {1 => {0 => {:option_text => "Radio option test create" } ,
                                                             1 => {:option_text => "Radio option 2"} }
                                                       }
                                }
    assert_redirected_to(:controller => "tree_display",:action => "list")
    assert_not_nil(QuestionOption.find(:first, :conditions => ["option_text = ?", "Radio option test create"]))
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
  end
  
  # 1001 edit(save) rurbic's advice
  def test_save_advice
    
    post :save_advice, :id => @Questionnaire, :advice =>  { "#{Fixtures.identify(:advice0)}"=> { :advice => "test" } }   
    
    assert_response :redirect
    assert_equal "The questionnaire's question advice was successfully saved", flash[:notice]
    assert_redirected_to :action => 'list'
  end
end