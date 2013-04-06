require File.dirname(__FILE__) + '/../test_helper'

class QuestionTest < ActiveSupport::TestCase
  fixtures :questions, :questionnaires

  def test_truth
    assert true
  end
  def setup
    # Database was initialized with (at least) 3 questionnaires.
    @question1 = Question.find(questions(:question1).id)
    @question2 = Question.find(questions(:question2).id)
    @question3 = Question.find(questions(:question3).id)
  end

  def test_validate_weight_no_numbers
    @question1.weight = "akajfsd"
    assert !@question1.save
  end

  def test_validate_txt_not_nil
    @question1.txt = nil
    assert !@question1.save
  end

end
