require File.dirname(__FILE__) + '/../test_helper'
#test question type

class QuestionTypeTest < ActiveSupport::TestCase
  fixtures :questions

  def test_boolean_question
    q4 = Question.new
    q4.questionnaire_id = @questionnaire1.id
    q4.true_false = true
    q4.txt = "4"
    @questionnaire1.questions << q4
    assert @questionnaire1.true_false_questions?
  end
end