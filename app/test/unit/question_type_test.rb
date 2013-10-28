require File.dirname(__FILE__) + '/../test_helper'
#test question type

class QuestionTypeTest < ActiveSupport::TestCase
  fixtures :questions

  def test_create_question_type
    @question_type1 = QuestionType.new
    @question_type1.question_id = questions(:question1).id
    @question_type1.q_type = "Checkbox"
    assert @question_type1.save
  end

  def test_not_create_question_type_with_no_q_type
    @question_type1 = QuestionType.new
    @question_type1.question_id = questions(:question1).id
    @question_type1.q_type = nil
    assert !@question_type1.save
  end

end