# OSS808 Change 28/10/2013
# FasterCSV replaced now by CSV which is present by default in Ruby
# require 'fastercsv'
# require 'csv'

# TODO: Move all functionality out of this file and delete it

module QuestionnaireHelper
  CSV_QUESTION = 0
  CSV_TYPE = 1
  CSV_PARAM = 2
  CSV_WEIGHT = 3

  def self.create_questionnaire_csv(questionnaire, _user_name)
    csv_data = CSV.generate do |csv|
      for question in questionnaire.questions
        # Each row is formatted as follows
        # Question, question advice (from high score to low), type, weight
        row = []
        row << question.txt
        row << question.type

        row << question.alternatives || ''
        row << question.size || ''

        row << question.weight

        # if questionnaire.section == "Custom"
        #  row << QuestionType.find_by_question_id(question.id).parameters
        # else
        #  row << ""
        # end

        # loop through all the question advice from highest score to lowest score
        adjust_advice_size(questionnaire, question)
        for advice in question.question_advices.sort {|x, y| y.score <=> x.score }
          row << advice.advice
        end

        csv << row
    end
    end

    csv_data
end

  def self.adjust_advice_size(questionnaire, question)
    # now we only support question advices for scored questions
    if question.is_a?(ScoredQuestion)

      max = questionnaire.max_question_score
      min = questionnaire.min_question_score

      QuestionAdvice.delete_all(["question_id = ? AND (score > ? OR score < ?)", question.id, max, min]) if !max.nil? && !min.nil?

      for i in (questionnaire.min_question_score..questionnaire.max_question_score)
        qas = QuestionAdvice.where("question_id = ? AND score = ?", question.id, i)
        question.question_advices << QuestionAdvice.new(score: i) if qas.first.nil?
        QuestionAdvice.delete(["question_id = ? AND score = ?", question.id, i]) if qas.size > 1

      end
    end
  end
end
