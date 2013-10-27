require File.dirname(__FILE__) + '/../test_helper'
# Testing for score

class ScoreTest < ActiveSupport::TestCase
  fixtures :assignments, :responses, :questions, :response_maps, :scores, :questionnaires, :question_types

  def test_compute_total_score_with_one_assessments_one_question
    assessments = [responses(:response0)]
    questions = [questions(:question1)]
    score_actual = Score.compute_scores_statistics(assessments, questions)
    score_expected = {:min =>80.0, :max =>80.0, :avg => 80.0}
    assert_equal(score_expected, score_actual, "The actual score is not equal to the expected score" )
  end

  def test_compute_total_score_with_one_assessments_many_questions
    assessments = [responses(:response0)]
    questions = [questions(:question1), questions(:question8), questions(:question9)]
    score_actual = Score.compute_scores_statistics(assessments, questions)
    s = ((55).to_f/(60).to_f)*100
    score_expected = {:min => s, :max => s, :avg => s}
    assert_equal(score_expected, score_actual, "The actual score is not equal to the expected score" )
  end

  def test_compute_total_score_with_many_assessments_many_question
    assessments = [responses(:response0),responses(:response6),responses(:response7) ]
    questions = [questions(:question1), questions(:question8), questions(:question9)]
    score_actual = Score.compute_scores_statistics(assessments, questions)
    s_min = ((35).to_f/(60).to_f)*100
    s_avg = (250).to_f/3
    score_expected = {:min => s_min, :max =>100.0, :avg => s_avg}
    assert_equal(score_expected, score_actual, "The actual score is not equal to the expected score" )
  end

  def test_compute_total_score_with_assessments_length_zero
    assessments = []
    questions = [questions(:question1)]
    score_actual = Score.compute_scores_statistics(assessments, questions)
    score_expected = {:min =>nil, :max =>nil, :avg => nil}
    assert_equal(score_expected, score_actual, "The actual score is not equal to the nil" )
  end

  def test_compute_total_score_with_questions_length_zero
    assessments = [responses(:response0)]
    questions = []
    score_actual = Score.compute_scores_statistics(assessments, questions)
    score_expected = {:min =>nil, :max =>nil, :avg => nil}
    assert_equal(score_expected, score_actual, "The actual score is not equal to the nil" )
  end

  def test_compute_total_score_with_custom_assessments_many_questions
    assessments = [responses(:response_c0)]
    questions = [questions(:question_c1), questions(:question_c2)]
    score_actual = Score.compute_scores_statistics(assessments, questions)
    s = 80.0
    score_expected = {:min => s, :max => s, :avg => s}
    assert_equal(score_expected, score_actual, "The actual score is not equal to the expected score" )
  end

  def test_compute_total_score_with_custom_assessments_non_rating_questions
    assessments = [responses(:response_c0)]
    questions = [questions(:question_c2)]
    score_actual = Score.compute_scores_statistics(assessments, questions)
    s = -1
    score_expected = {:min => s, :max => s, :avg => s}
    assert_equal(score_expected, score_actual, "The actual score is not equal to the expected score" )
  end

  def test_get_total_score_with_response_many_questions
    assessment = responses(:response0)
    questions = [questions(:question1), questions(:question8), questions(:question9)]
    q_types = Array.new
    questions.each {
        | question |
      q_types << QuestionType.find_by_question_id(question.id)
    }
    score_actual = Score.get_total_score(:response => assessment, :questions => questions,:q_types => q_types )
    score_expected = ((55).to_f/(60).to_f)*100
    assert_equal(score_expected, score_actual, "The actual score is not equal to the expected value" )
  end

  def test_get_total_score_with_response_nil_questions
    assessment = responses(:response0)
    q_types = Array.new
    score_actual = Score.get_total_score(:response => assessment, :q_types => q_types )
    score_expected = -1
    assert_equal(score_expected, score_actual, "The actual score is not equal to the expected value" )
  end

  def test_get_total_score_with_nil_response_many_questions
    questions = [questions(:question1), questions(:question8), questions(:question9)]
    q_types = Array.new
    questions.each {
        | question |
      q_types << QuestionType.find_by_question_id(question.id)
    }
    score_actual = Score.get_total_score(:questions => questions,:q_types => q_types )
    score_expected = -1
    assert_equal(score_expected, score_actual, "The actual score is not equal to the expected value" )
  end

  def test_get_total_score_with_response_empty_questions
    assessment = responses(:response0)
    questions = []
    q_types = Array.new
    questions.each {
        | question |
      q_types << QuestionType.find_by_question_id(question.id)
    }
    score_actual = Score.get_total_score(:response => assessment, :questions => questions,:q_types => q_types )
    score_expected = -1
    assert_equal(score_expected, score_actual, "The actual score is not equal to the expected value" )
  end

  def test_assessment_validity_no_due_dates
    duedates = []
    invalid_actual = Score.is_assessment_valid(duedates)
    invalid_expected = 0
    assert_equal(invalid_expected, invalid_actual, "Expected was valid and actual shows invalid")
  end

  def test_get_total_score_with_custom_questionnaire_responses
    assessment = responses(:response_c0)
    questions = [questions(:question_c1), questions(:question_c2)]
    q_types = [question_types(:qt_1), question_types(:qt_2)]
    score_actual = Score.get_total_score(:response => assessment, :questions => questions,:q_types => q_types )
    score_expected = 80.0
    assert_equal(score_expected, score_actual, "The actual score is not equal to the expected value" )
  end

  def test_get_total_score_with_custom_questionnaire_responses_score_negative
    assessment = responses(:response_c0)
    questions = [questions(:question_c2)]
    q_types = [question_types(:qt_1), question_types(:qt_2)]
    score_actual = Score.get_total_score(:response => assessment, :questions => questions,:q_types => q_types )
    score_expected = -1
    assert_equal(score_expected, score_actual, "The actual score is not equal to the expected value" )
  end

  def test_assessment_validity_with_due_dates
    @response = responses(:response0)
    map=ResponseMap.find(@response.map_id)
    due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?", map.reviewed_object_id])
    invalid_actual = Score.is_assessment_valid(due_dates)
    invalid_expected = 0
    assert_equal(invalid_expected, invalid_actual, "Expected was valid and actual shows invalid")
  end

  def test_calculate_total_score_with_questions_response
    @response = responses(:response0)
    @questions = [questions(:question1), questions(:question8), questions(:question9)]
    score_expected = ((55).to_f/(60).to_f)*100
    score_actual = Score.calculate_total_score(:response => @response, :questions => @questions)
    assert_equal(score_expected, score_actual, "Expected score is not equal to the actual score")
  end

  def test_calculate_total_score_with_empty_questions_response
    @response = responses(:response0)
    @questions = []
    score_expected = -1
    score_actual = Score.calculate_total_score(:response => @response, :questions => @questions)
    assert_equal(score_expected, score_actual, "Expected score is not equal to the actual score")
  end

  def test_calculate_total_score_with_nil_questions_response
    @questions = [questions(:question1), questions(:question8), questions(:question9)]
    score_expected = -1
    score_actual = Score.calculate_total_score(:questions => @quesions)
    assert_equal(score_expected, score_actual, "Expected score is not equal to the actual score")
  end

  def test_calculate_total_score_with_questions_nil_response
    @response = responses(:response0)
    score_expected = -1
    score_actual = Score.calculate_total_score(:response => @response)
    assert_equal(score_expected, score_actual, "Expected score is not equal to the actual score")
  end

  def test_calculate_total_score_with_questions_response_not_matching
    @response = responses(:response1)
    @questions = [questions(:question1), questions(:question8), questions(:question9)]
    score_expected = -1
    score_actual = Score.calculate_total_score(:response => @response, :questions => @questions)
    assert_equal(score_expected, score_actual, "Expected score is not equal to the actual score")
  end

  def test_calculate_total_score_with_custom_questionnaire_responses
    assessment = responses(:response_c0)
    questions = [questions(:question_c1),questions(:question_c2)]
    q_types = [question_types(:qt_1), question_types(:qt_2)]
    score_actual = Score.calculate_total_score(:response => assessment, :questions => questions,:q_types => q_types )
    score_expected = 80.0
    assert_equal(score_expected, score_actual, "The actual score is not equal to the expected value" )
  end

  def test_calculate_total_score_with_custom_questionnaire_responses_score_negative
    assessment = responses(:response_c0)
    questions = [questions(:question_c2)]
    q_types = [question_types(:qt_1), question_types(:qt_2)]
    score_actual = Score.calculate_total_score(:response => assessment, :questions => questions,:q_types => q_types )
    score_expected = -1
    assert_equal(score_expected, score_actual, "The actual score is not equal to the expected value" )
  end

  def test_is_custom_rating_one_with_x_nil
    x = nil
    question = questions(:question1)
    q_types = ["Regular","Rating"]
    is_one_actual = Score.is_custom_rating_one(x, question, q_types)
    is_one_expected = false
    assert_equal(is_one_expected, is_one_actual)
  end

  def test_is_custom_rating_one_with_question_nil
    x = 0
    question = nil
    q_types = ["Regular","Rating"]
    is_one_actual = Score.is_custom_rating_one(x, question, q_types)
    is_one_expected = false
    assert_equal(is_one_expected, is_one_actual)
  end

  def test_is_custom_rating_one_with_qtypes_nil
    x = 0
    question = questions(:question1)
    q_types = nil
    is_one_actual = Score.is_custom_rating_one(x, question, q_types)
    is_one_expected = false
    assert_equal(is_one_expected, is_one_actual)
  end

  def test_is_custom_rating_one_with_qtypes_having_rating
    x = 0
    question = questions(:question_c1)
    q_types = [question_types(:qt_1), question_types(:qt_2)]
    is_one_actual = Score.is_custom_rating_one(x, question, q_types)
    is_one_expected = true
    assert_equal(is_one_expected, is_one_actual)
  end

  def test_is_custom_rating_one_with_qtypes_not_having_rating
    x = 1
    question = questions(:question_c1)
    q_types = [question_types(:qt_1), question_types(:qt_2)]
    is_one_actual = Score.is_custom_rating_one(x, question, q_types)
    is_one_expected = false
    assert_equal(is_one_expected, is_one_actual)
  end

  def test_is_custom_rating_one_with_qtypes_length_zero
    x = 0
    question = questions(:question_c1)
    q_types = []
    is_one_actual = Score.is_custom_rating_one(x, question, q_types)
    is_one_expected = true
    assert_equal(is_one_expected, is_one_actual)
  end
  
  #e611
  def test_check_min_max_score
    @questionnaire1.min_question_score = "ThisIsMinScore"
    @questionnaire1.max_question_score = "ThisIsMaxScore"
    assert !@questionnaire1.save
  end

  #e611
  def test_checkfor_positive_score
    @questionnaire1.max_question_score = -1
    assert !@questionnaire1.save
  end
end