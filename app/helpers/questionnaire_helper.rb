# frozen_string_literal: true

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

      if !max.nil? && !min.nil?
        QuestionAdvice.delete_all(['question_id = ? AND (score > ? OR score < ?)', question.id, max, min])
      end

      (questionnaire.min_question_score..questionnaire.max_question_score).each do |i|
        qas = QuestionAdvice.where('question_id = ? AND score = ?', question.id, i)
        if qas.first.nil?
          question.question_advices << QuestionAdvice.new(score: i)
        end
        if qas.size > 1
          QuestionAdvice.delete(['question_id = ? AND score = ?', question.id, i])
        end
      end
    end
  end
end
