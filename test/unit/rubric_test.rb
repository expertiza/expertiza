require File.dirname(__FILE__) + '/../test_helper'

class RubricTest < Test::Unit::TestCase
  fixtures :rubrics

  def setup
    # Database was initialized with (at least) 3 rubrics.
    @rubric1 = Rubric.find(1)
    @rubric2 = Rubric.find(2)
    @rubric3 = Rubric.find(3)
  end
  
  def test_create
    assert_kind_of Rubric, @rubric1
    assert_equal "rubric1", @rubric1.name
    
    assert_equal 1, @rubric1.min_question_score
    assert_equal 5, @rubric1.max_question_score
    assert_equal false, @rubric1.private
  end
  
  def test_update
    @rubric1.min_question_score = 2
    @rubric1.max_question_score = 8
    @rubric1.name = "rubric1 new name"
    @rubric1.save
    @rubric1.reload
    
    assert_equal 2, @rubric1.min_question_score
    assert_equal 8, @rubric1.max_question_score
    assert_equal "rubric1 new name", @rubric1.name
  end
  
#  def test_destroy
#    @rubric1.destroy
#    assert_raise(ActiveRecord::RecordNotFound) { Rubric.find(@rubric1.id) }
#  end
  
  def test_validate_no_numbers
    @rubric1.min_question_score = "akajfsd"
    @rubric1.max_question_score = "fkjlfsdi"
    assert !@rubric1.save
  end
  
  def test_validate_min_greater_than_max
    @rubric1.min_question_score = 8
    @rubric1.max_question_score = 2 
    assert !@rubric1.save
  end
  
  def test_validate_positive_max
    @rubric1.max_question_score = -2
    assert !@rubric1.save
  end
  
  def test_validate_unique_rubric_names
    @rubric1.name = "aaaa"
    @rubric1.instructor_id = 1
    assert @rubric1.save
    @rubric2.name = "aaaa"
    @rubric2.instructor_id = 1
    assert !@rubric2.save
  end
  
  def test_true_false_question
    assert !@rubric1.true_false_questions?
    q = Question.new
    q.rubric_id = @rubric1.id
    q.true_false = false
    q.txt = "1"
    q2 = Question.new
    q2.rubric_id = @rubric1.id
    q2.true_false = true
    q2.txt = "2"
    @rubric1.questions << q
    assert !@rubric1.true_false_questions?
    @rubric1.questions << q2
    assert @rubric1.true_false_questions?
  end
end
