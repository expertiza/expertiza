
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
  fixtures :assignment_questionnaires

  def setup
    @controller = QuestionnaireController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @Questionnaire = questionnaires(:questionnaire5).id

    login_user(:admin)
  end


  # Helper method for logging in as user
  def login_user(userType)
    @request.session[:user] = User.find(users(userType).id )
    roleid = User.find(users(userType).id).role_id
    Role.rebuild_cache

    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    # Work around a bug that causes session[:credentials] to become a YAML Object
    @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
    @settings = SystemSettings.find(:first)
    AuthController.set_current_role(roleid,@request.session)
  end


  # Tests to see if the questionnaire was edited properly. The questionnaires name is changed
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

  # Tests saving advice for a questionnaire. Tests that the request is
  # redirected to the list action and also that the text notice for successfully
  # saving is displayed
  def test_save_advice
    
    post :save_advice, :id => @Questionnaire, :advice =>  { "#{Fixtures.identify(:advice0)}" => { :advice => "test" } }
    
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



  # Test the creation of questionnaire with student
  # A student should not be able to create a questionnaire
  def test_create_questionnaire_with_student
    login_user(:student1)
    post :create_questionnaire,{:questionnaire => {
        :name => "test valid questionnaire",
        :type => "ReviewQuestionnaire",
        :min_question_score => 1,
        :max_question_score => 5,
        :section => "Review" }}

    # Should be nil because it wasn't saved correct
    assert_redirected_to 'denied'
    assert_nil (Questionnaire.find_by_name("test valid questionnaire"))
  end


  # Test the creation of a valid questionnaire
  def test_create_valid_questionnaire
    post :create_questionnaire,{:questionnaire => {
        :name => "test valid questionnaire",
        :type => "ReviewQuestionnaire",
        :min_question_score => 1,
        :max_question_score => 5,
        :section => "Review" }}

    # Should be nil because it wasn't saved correct
    assert_not_nil (Questionnaire.find_by_name("test valid questionnaire"))
  end


  # Test the creation of a invalid questionnaire based on an invalid max question score
  def test_create_questionnaire_with_non_numerical_max_question_score
    post :create_questionnaire,{    :questionnaire => {:name => "test invalid questionnaire",
                                                       :type => "ReviewQuestionnaire",
                                                       :min_question_score => 1,
                                                       :max_question_score => "a string",
                                                       :section => "Review" }}

    # Should be nil because it wasn't saved correct
    assert_nil (Questionnaire.find_by_name("test invalid questionnaire"))

    # Should get a flash error
    assert @response.flash[:error]
  end

  # Test the creation of a invalid questionnaire based on missing "section" field
  def test_create_questionnaire_with_no_section_column
    post :create_questionnaire,{:questionnaire => {
        :name => "test invalid questionnaire again",
        :type => "ReviewQuestionnaire",
        :min_question_score => 1,
        :max_question_score => "a string"}}

    # Should be nil because it wasn't saved correct
    assert_nil (Questionnaire.find_by_name("test invalid questionnaire again"))

    # Should get a flash error
    assert @response.flash[:error]
  end

  # Test the creation of a invalid questionnaire based on an invalid max question score
  def test_create_questionnaire_with_invalid_type
    assert_raise(NameError){
      post :create_questionnaire,{:questionnaire => {
          :name => "test invalid name questionnaire",
          :type => "InvalidTYpe",
          :min_question_score => 1,
          :max_question_score => "a string",
          :section => "Review" }}
    }
    # Should be nil because it wasn't saved correct
    assert_nil (Questionnaire.find_by_name("test invalid name questionnaire"))
  end

  def test_edit_questionnaire_with_lower_max_score_than_min
    post :edit, {:id => @Questionnaire, :save => true,
                 :questionnaire => {:name => "test edit name",
                                    :type => "MetareviewQuestionnaire",
                                    :min_question_score => 5,
                                    :max_question_score => 2,
                                    :instruction_loc => "http://www.expertiza.ncsu.edu"}}

    # Should get a flash error
    assert @response.flash[:error]
  end

  # Copies the questionnaire and tests whether the questionnaire was copied
  # as well as if the name and instructor_id were updated correctly.
  def test_copy
    post :copy, :id => @Questionnaire
    userid = session[:user].id
    assert_not_nil(Questionnaire.find(:first, :conditions => ["name = ? and instructor_id=?", "Copy of questionnaire5", userid]))
  end

  # Asserts that the questionnaire is there and then tests for deletion. Also tests that it
  # user is redirected with the correct questionnaire deletion message
  def test_delete
    assert_not_nil(Questionnaire.find(@Questionnaire))
    assert_difference ('Questionnaire.count', difference = -1)  do
      post :delete, :id => @Questionnaire

      assert_nil flash[:error]
      assert_equal "Questionnaire <B>questionnaire5</B> was deleted.", flash[:note]
      assert_redirected_to :controller => 'tree_display', :action => :list
    end
  end

  def test_view
    post :view, :id => @Questionnaire
    assert_response(:success)
  end

  # Tests redirecting to edit advice if the edit_advice parameter is true
  def test_edit_view_advice
    post :edit, {:id => @Questionnaire, :view_advice => true, :questionnaire => Questionnaire.find(@Questionnaire)}
    assert_redirected_to :action => :edit_advice, :id => @Questionnaire
  end

  def test_export
    post :edit, {:id => @Questionnaire, :export => true, :questionnaire => Questionnaire.find(@Questionnaire)}
    assert_response(:success)
  end

  def test_import
    post :edit, {:id => @Questionnaire, :random => true, :questionnaire => Questionnaire.find(@Questionnaire)}
    assert_response(:success)
  end

  def test_new
    post :new, {:private => true, :model => "ReviewQuestionnaire" }
    assert_response(:success)
  end

  def test_create_questionnaire
    post :create_questionnaire, {:questionnaire => {:type => "ReviewQuestionnaire" }}
    assert_redirected_to :controller => 'tree_display', :action => :list
  end

  def test_edit_advice
    post :edit_advice, {:id => @Questionnaire, :questionnaire => Questionnaire.find(@Questionnaire)}
    assert_response(:success)
  end

  # Test the toggle access action
  def test_toggle_access

    questionnaire1 = Questionnaire.find_by_id(questionnaires(:questionnaire1).id)
    old_access = questionnaire1.private

    post :toggle_access, :id => questionnaire1.id

    questionnaire1 = Questionnaire.find_by_id(questionnaires(:questionnaire1).id)
    new_access = questionnaire1.private

    assert_redirected_to :controller => 'tree_display', :action => 'list'
    assert_equal(old_access, !new_access)
  end

  # Should change count after deleting question type
  def test_delete_question_type
    qt_1_question_id = question_types(:qt_1).question_id

    # Test deleting question type by id (instance_eval to test private method)
    assert_difference('QuestionType.count', -1) do
      @controller.instance_eval{delete_question_type(qt_1_question_id) }
    end

  end

  # Test the saving of an invalid advice
  def test_save_advice_that_does_not_exist
    # Instantiate a new question advice and make sure it is not nil
    new_advice = QuestionAdvice.new(:question_id => 2, :score => 2, :advice => 'great')
    assert_not_nil new_advice

    # Should raise error since the advice hasn't been saved to the database
    assert_raise (ActionView::TemplateError){
      post :save_advice, :id => @Questionnaire, :advice =>  { new_advice => { :question_id => 111 } }
    }
  end

end
