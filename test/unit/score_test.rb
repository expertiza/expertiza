require File.dirname(__FILE__) + '/../test_helper'
# Testing for score

class QuestionaireTest < ActiveSupport::TestCase
  fixtures :questionnaires, :assignments

  def test_check_min_max_score
    @questionnaire1.min_question_score = "ThisIsMinScore"
    @questionnaire1.max_question_score = "ThisIsMaxScore"
    assert !@questionnaire1.save
  end

  def test_checkfor_positive_score
    @questionnaire1.max_question_score = -1
    assert !@questionnaire1.save
  end
end