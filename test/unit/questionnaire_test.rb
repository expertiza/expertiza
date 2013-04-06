require File.dirname(__FILE__) + '/../test_helper'

class RubricTest < ActiveSupport::TestCase
  fixtures :questionnaires, :assignments

  def setup
    # Database was initialized with (at least) 3 questionnaires.
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
    q2 = Question.new
    q2.questionnaire_id = @questionnaire1.id
    q2.true_false = true
    q2.txt = "2"
    @questionnaire1.questions << q2
    assert @questionnaire1.true_false_questions?
  end

  def test_get_assessment_for
    questionnaire1 = Array.new
    questionnaire1<<questionnaires(:questionnaire0)
    questionnaire1<<questionnaires(:questionnaire1)
    questionnaire1<<questionnaires(:questionnaire2)
    questionnaire1<<questionnaires(:peer_review_questionnaire)

    scores = Hash.new
    scores[:participant] = AssignmentParticipant.find_by_parent_id(assignments(:assignment0))
    questionnaire1.each do |questionnaire|
      scores[questionnaire.symbol] = Hash.new
      scores[questionnaire.symbol][:assessments] = questionnaire.get_assessments_for(AssignmentParticipant.find_by_parent_id(assignments(:assignment0)))

      assert_not_equal(scores[questionnaire.symbol][:assessments],0)
    end
  end
end
