# OSS808 Change 28/10/2013
# FasterCSV replaced now by CSV which is present by default in Ruby
# require 'fastercsv'
# require 'csv'

module QuestionnaireHelper
  CSV_QUESTION = 0
  CSV_TYPE = 1
  CSV_PARAM = 2
  CSV_WEIGHT = 3

  def self.adjust_advice_size(questionnaire, question)
    # now we only support question advices for scored questions
    if question.is_a?(ScoredQuestion)

      max = questionnaire.max_question_score
      min = questionnaire.min_question_score

      QuestionAdvice.delete_all(['question_id = ? AND (score > ? OR score < ?)', question.id, max, min]) if !max.nil? && !min.nil?

      (questionnaire.min_question_score..questionnaire.max_question_score).each do |i|
        qas = QuestionAdvice.where('question_id = ? AND score = ?', question.id, i)
        question.question_advices << QuestionAdvice.new(score: i) if qas.first.nil?
        QuestionAdvice.delete(['question_id = ? AND score = ?', question.id, i]) if qas.size > 1
      end
    end
  end

  def update_questionnaire_questions
    return if params[:question].nil?

    params[:question].each_pair do |k, v|
      question = Question.find(k)
      v.each_pair do |key, value|
        question.send(key + '=', value) unless question.send(key) == value
      end
      question.save
    end
  end

  def create_questionnaire_question(question_type, questionnaire_id, seq)
    Object.const_get(question_type).create(
      txt: '',
      questionnaire_id: questionnaire_id,
      seq: seq,
      type: question_type,
      break_before: true
    )
  end
  
  def configure_questionnaire_question(question, question_params)
    case question
    when ScoredQuestion
      question.weight = question_params[:weight]
      question.max_label = 'Strongly agree'
      question.min_label = 'Strongly disagree'
    when Criterion, Cake
      question.size = '50, 3'
    when Dropdown
      question.alternatives = '0|1|2|3|4|5'
    when TextArea
      question.size = '60, 5'
    when TextField
      question.size = '30'
    end
  end

end
