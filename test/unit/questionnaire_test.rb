require 'test_helper'

class RubricTest < Test::Unit::TestCase
  fixtures :questionnaires

  def setup
    # Database was initialized with (at least) 3 questionnaires.
    @questionnaire1 = Questionnaire.find(1)
    @questionnaire2 = Questionnaire.find(2)
    @questionnaire3 = Questionnaire.find(3)
  end
  
  def test_create
    assert_kind_of Questionnaire, @questionnaire1
    assert_equal "questionnaire1", @questionnaire1.name
    
    assert_equal 1, @questionnaire1.min_question_score
    assert_equal 5, @questionnaire1.max_question_score
    assert_equal false, @questionnaire1.private
  end
  
  def test_update
    @questionnaire1.min_question_score = 2
    @questionnaire1.max_question_score = 8
    @questionnaire1.name = "questionnaire1 new name"
    @questionnaire1.save
    @questionnaire1.reload
    
    assert_equal 2, @questionnaire1.min_question_score
    assert_equal 8, @questionnaire1.max_question_score
    assert_equal "questionnaire1 new name", @questionnaire1.name
  end
  
#  def test_destroy
#    @questionnaire1.destroy
#    assert_raise(ActiveRecord::RecordNotFound) { questionnaire.find(@questionnaire1.id) }
#  end
  
  def test_validate_no_numbers
    @questionnaire1.min_question_score = "akajfsd"
    @questionnaire1.max_question_score = "fkjlfsdi"
    assert !@questionnaire1.save
  end
  
  def test_validate_min_greater_than_max
    @questionnaire1.min_question_score = 8
    @questionnaire1.max_question_score = 2 
    assert !@questionnaire1.save
  end
  
  def test_validate_positive_max
    @questionnaire1.max_question_score = -2
    assert !@questionnaire1.save
  end
  
  def test_validate_unique_questionnaire_names
    @questionnaire1.name = "aaaa"
    @questionnaire1.instructor_id = 1
    assert @questionnaire1.save
    @questionnaire2.name = "aaaa"
    @questionnaire2.instructor_id = 1
    assert !@questionnaire2.save
  end
  
  def test_true_false_question
    assert !@questionnaire1.true_false_questions?
    q = Question.new
    q.questionnaire_id = @questionnaire1.id
    q.true_false = false
    q.txt = "1"
    q2 = Question.new
    q2.questionnaire_id = @questionnaire1.id
    q2.true_false = true
    q2.txt = "2"
    @questionnaire1.questions << q
    assert !@questionnaire1.true_false_questions?
    @questionnaire1.questions << q2
    assert @questionnaire1.true_false_questions?
  end
end
