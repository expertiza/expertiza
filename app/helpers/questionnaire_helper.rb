# OSS808 Change 28/10/2013
# FasterCSV replaced now by CSV which is present by default in Ruby
# require 'fastercsv'
# require 'csv'

module QuestionnaireHelper

  def self.create_questionnaire_csv(questionnaire, _user_name)
    csv_data = CSV.generate do |csv|
      questionnaire.questions.each do |question|
        # Each row is formatted as follows
        # Question, question advice (from high score to low), type, weight
        row = create_row_from_question(question)

        # loop through all the question advice from highest score to lowest score
        adjust_advice_size(questionnaire, question)
        (question.question_advices.sort {|x, y| y.score <=> x.score }).each do |advice|
          row << advice.advice
        end

        csv << row
      end
    end

    csv_data
  end

  def self.create_row_from_question(question)
    row = []
    row << question.txt
    row << question.type
    row << question.alternatives || ''
    row << question.size || ''
    row << question.weight
    row
  end

  def self.get_questions_from_csv(questionnaire, file)
    questions = []

    CSV::Reader.parse(file) do |row|
      unless row.empty?
        question = Question.new
        question.true_false = false

        question.txt = row[0].strip unless row[0].nil?
        question.true_false = row[1].downcase.strip == Question::TRUE_FALSE.downcase unless row[1].nil?
        question.weight = row[3].strip.to_i unless row[3].nil?

        (questionnaire.min_question_score..questionnaire.max_question_score).each do |i|
          question.question_advices << QuestionAdvice.new(score: i, advice: row[4 + i].strip) unless row[4 + i].nil?
        end

        question.save

        if questionnaire.section == "Custom"
          question_type = QuestionType.new
          question_type.q_type = row[1].strip
          question_type.parameters = row[2].strip
          question_type.question
          question_type.save
        end

        questions << question
      end
    end

    questions
  end

  def self.adjust_advice_size(questionnaire, question)
    # now we only support question advices for scored questions
    return unless question.is_a?(ScoredQuestion)
    return if questionnaire.max_question_score.nil? || questionnaire.min_question_score.nil?

    QuestionAdvice.delete_all(["question_id = ? AND (score > ? OR score < ?)", question.id, questionnaire.max_question_score, questionnaire.min_question_score])

    (questionnaire.min_question_score..questionnaire.max_question_score).each do |i|
      qas = QuestionAdvice.where("question_id = ? AND score = ?", question.id, i)
      question.question_advices << QuestionAdvice.new(score: i) if qas.first.nil?
      QuestionAdvice.delete(["question_id = ? AND score = ?", question.id, i]) if qas.size > 1
    end
  end
end
