require File.dirname(__FILE__) + '/../test_helper'
require 'questionnaire_controller'

# Re-raise errors caught by the controller.
class QuestionnaireController;
  def rescue_action(e) raise e end;
end

class QuestionnaireControllerTest < ActionController::TestCase
  fixtures :assignments
  fixtures :participants
  fixtures :questionnaires
  fixtures :users
  fixtures :question_advices
  fixtures :questions
  
  def setup
    @controller = QuestionnaireController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @Questionnaire = questionnaires(:questionnaire1).id

    @QuizQuestionnaire = questionnaires(:quiz_questionnaire1)
    @QuizStudent = User.find(users(:student1)).id
    @Assignment = assignments(:assignment_quiz).id
    @Participant = participants(:quiz_par1).id

    @request.session[:user] = User.find( users(:superadmin).id )
    roleid = User.find(users(:superadmin).id).role_id
    Role.rebuild_cache
    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    AuthController.set_current_role(roleid,@request.session)
  end
  #901 edit an questionnaire's data
  def test_edit_questionnaire
    post :edit, {:id => @Questionnaire, :save => true, 
                       :questionnaire => {:name => "test edit name", 
                                   :type => "ReviewQuestionnaire",
                                   :min_question_score => 1,
                                   :max_question_score => 3}}
    assert_response(:success)
    assert_not_nil(Questionnaire.find(:first, :conditions => ["name = ?", "test edit name"]))
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

  def test_create_quiz
    questions_count = Question.count
    answers_count =  QuestionAdvice.count
    q_questionnaire = {"name" => "testquiz", "id" => "", "type" => "QuizQuestionnaire" }

    new_q_question = Hash.new()
    new_q_question["1"] = {"weight" => "2", "txt" => "Quiz Question 1"}
    new_q_question["2"] = {"weight" => "1", "txt" => "Quiz Question 2"}

    new_q_choices = Hash.new()
    new_q_choices["1"] = {"1" => "Answer 1 for Q1", "2" => "Answer 2 for Q1"}
    new_q_choices["2"] = {"1" => "Answer 1 for Q1", "2" => "Answer 2 for Q2"}

    post :create_quiz_questionnaire, :model=>"QuizQuestionnaire", :pid=>@Participant, :aid=> @Assignment,
                                      :questionnaire=>q_questionnaire, :new_question=>new_q_question, :new_choices=>new_q_choices

    assert_not_nil(Questionnaire.find(:first, :conditions => ["name = ?", "testquiz"]))
    assert(questions_count + 2 == Question.count)
    assert(answers_count + 4 == QuestionAdvice.count)

  end

  def test_update_quiz
    q_questionnaire = {"name" => @QuizQuestionnaire.name, "id" => @QuizQuestionnaire.id, "type" => @QuizQuestionnaire.type }
    q_question = Hash.new()
    q_advices = Hash.new()
    q_questions = Question.find_all_by_questionnaire_id(@QuizQuestionnaire.id)
    i = 1
    for question in q_questions
    q_question[question.id.to_s] = {"weight" => question.weight, "txt" => "changed question" + i.to_s}
    q_answers = QuestionAdvice.find_all_by_question_id(question.id.to_s)
    for answer in q_answers
    q_advices[answer.id.to_s] = {"advice" => answer.advice}
    end
    i = i + 1
    end

    post :update_quiz, :pid => @Participant, :id=>@QuizQuestionnaire.id, :questionnaire=>q_questionnaire,
    :question => q_question, :save => "Save quiz", :question_advice => q_advices

    test_questions = Question.find_all_by_questionnaire_id(@QuizQuestionnaire.id)
    i = 1
    for test_question in test_questions
    txt = "changed question" + i.to_s
    assert_equal(test_question.txt,txt)
    i += 1
    end
  end
end