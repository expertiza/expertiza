
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
  fixtures :roles
  fixtures :question_types

  def setup
    @controller = QuestionnaireController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @Questionnaire = questionnaires(:questionnaire1).id

    @request.session[:user] = User.find(users(:superadmin).id )
    roleid = User.find(users(:superadmin).id).role_id
    Role.rebuild_cache

    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    # Work around a bug that causes session[:credentials] to become a YAML Object
    @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
    @settings = SystemSettings.find(:first)
    AuthController.set_current_role(roleid,@request.session)
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
    assert_equal "The questionnaire's question advice was successfully saved", flash[:notice]
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

  # Test the toggle access action
  def test_toggle_access

    # Get its access and put it in old_access
    questionnaire1 = Questionnaire.find_by_id(@Questionnaire)
    old_access = questionnaire1.private

    # call controller method
    post :toggle_access, :id=>@Questionnaire

    # Get its access again and put it in new_access
    questionnaire1 = Questionnaire.find_by_id(@Questionnaire)
    new_access = questionnaire1.private
   
    # test assertion
    assert_equal(old_access, !new_access)

    assert_redirected_to :controller => 'tree_display', :action => 'list'

  end

  # Should change count after deleting question type
  def test_delete_question_type

    # get qt_1's question id from fixtures
    qt_1_question_id = question_types(:qt_1).question_id

    # Test deleting question type by id (instance_eval to test private method)
    assert_difference('QuestionType.count', -1) do
      @controller.instance_eval{delete_question_type(qt_1_question_id) }
    end

  end
end
