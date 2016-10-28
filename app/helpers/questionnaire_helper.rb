# OSS808 Change 28/10/2013
# FasterCSV replaced now by CSV which is present by default in Ruby
# require 'fastercsv'
 require 'csv'

module QuestionnaireHelper
  CSV_QUESTION = 0
  CSV_TYPE = 1
  CSV_PARAM = 2
  CSV_WEIGHT = 3



  def self.get_questions_from_csv(file_data,id)
    CSV.parse(file_data, headers: true) do |row|
      #  row.each do |cell|
      questions_hash = row.to_hash
      ques = Question.new(questions_hash)
      ques.questionnaire_id=id
      ques.save
    end # end CSV.parse
  end

  def self.adjust_advice_size(questionnaire, question)
    # now we only support question advices for scored questions
    if question.is_a?(ScoredQuestion)

      max = questionnaire.max_question_score
      min = questionnaire.min_question_score

      if !max.nil? && !min.nil?
        QuestionAdvice.delete_all(["question_id = ? AND (score > " + max.to_s + " OR score < " + min.to_s + ")", question.id])
      end

      for i in (questionnaire.min_question_score..questionnaire.max_question_score)
        qas = QuestionAdvice.where("question_id = #{question.id} AND score = #{i}")
        if qas.first.nil?
          question.question_advices << QuestionAdvice.new(score: i)
        end
        if qas.size > 1
          QuestionAdvice.delete("question_id = #{question.id} AND score = #{i}")
        end

      end
    end
  end
end
