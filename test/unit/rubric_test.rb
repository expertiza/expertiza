require File.dirname(__FILE__) + '/../test_helper'
# Testing the Questionaire

class QuestionaireTest < ActiveSupport::TestCase
  fixtures :questionnaires, :assignments

  def questionaire_setup
    @questionnaire1 = Questionnaire.find(questionnaires(:questionnaire1).id)
    @questionnaire2 = Questionnaire.find(questionnaires(:questionnaire2).id)
    @questionnaire3 = Questionnaire.find(questionnaires(:questionnaire3).id)
  end

  def test_create
    assert_kind_of Questionnaire, @questionnaire1
    assert_equal questionnaires(:questionnaire1).name, @questionnaire1.name

    assert_equal questionnaires(:questionnaire1).min_question_score, @questionnaire1.min_question_score
    assert_equal questionnaires(:questionnaire1).max_question_score, @questionnaire1.max_question_score
    assert_equal false, @questionnaire1.private
  end

  def test_checkfor_unique_names
    @questionnaire1.name = "Anyname1"
    @questionnaire1.instructor_id = 1
    assert @questionnaire1.save
    @questionnaire2.name = "AnyName1"
    @questionnaire2.instructor_id = 1
    assert !@questionnaire2.save
  end

  def test_update
    @questionnaire1.min_question_score = 1
    @questionnaire1.max_question_score = 10
    @questionnaire1.name = "questionnaire1 new name"
    @questionnaire1.save
    @questionnaire1.reload

    assert_equal 1, @questionnaire1.min_question_score
    assert_equal 10, @questionnaire1.max_question_score
    assert_equal "questionnaire1 new name", @questionnaire1.name
  end

  def test_check_score
    @questionnaire1.min_question_score = 10
    @questionnaire1.max_question_score = 3
    assert !@questionnaire1.save
  end

  def test_boolean_question
    q4 = Question.new
    q4.questionnaire_id = @questionnaire1.id
    q4.true_false = true
    q4.txt = "2"
    @questionnaire1.questions << q4
    assert @questionnaire1.true_false_questions?
  end
end