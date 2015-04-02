# OSS808 Change 28/10/2013
# FasterCSV replaced now by CSV which is present by default in Ruby
#require 'fastercsv'
#require 'csv'

module QuestionnaireHelper

  CSV_QUESTION = 0
  CSV_TYPE = 1
  CSV_PARAM = 2
  CSV_WEIGHT = 3

  def self.create_questionnaire_csv(questionnaire, user_name)
    csv_data = CSV.generate do |csv|
      for question in questionnaire.questions
        # Each row is formatted as follows
        # Question, question advice (from high score to low), type, weight
        row = Array.new
        row << question.txt
        if questionnaire.section != "Custom"
          row << "True/False" if question.true_false
          row << "Numeric" if !question.true_false
        else
          row << QuestionType.find_by_question_id(question.id).q_type
        end

        row << question.question_type.try(:parameters) || ''

        row << question.weight

        #if questionnaire.section == "Custom"
        #  row << QuestionType.find_by_question_id(question.id).parameters
        #else
        #  row << ""
        #end

        # loop through all the question advice from highest score to lowest score
        adjust_advice_size(questionnaire, question)
        for advice in question.question_advices.sort {|x,y| y.score <=> x.score }
          row << advice.advice
        end

        csv << row
    end
  end

  return csv_data
end

def self.get_questions_from_csv(questionnaire, file)
  questions = Array.new
  custom_rubric = questionnaire.section == "Custom"

  CSV::Reader.parse(file) do |row|
    if row.length > 0
      i = 0
      score = questionnaire.max_question_score
      q = Question.new

      q_type = QuestionType.new if custom_rubric

      q.true_false = false

      row.each do |cell|
        case i
        when CSV_QUESTION
          q.txt = cell.strip if cell != nil
        when CSV_TYPE
          if cell != nil
            q.true_false = cell.downcase.strip == Question::TRUE_FALSE.downcase
            q_type.q_type = cell.strip if custom_rubric
          end
        when CSV_PARAM
          if custom_rubric
            q_type.parameters = cell.strip if cell
          end
        when CSV_WEIGHT
          q.weight = cell.strip.to_i if cell
        else
          if score >= questionnaire.min_question_score and cell != nil
            a = QuestionAdvice.new(:score => score, :advice => cell.strip) if custom_rubric
            a = QuestionAdvice.new(:score => questionnaire.min_question_score + i - 4, :advice => cell.strip)
            score = score - 1
            q.question_advices << a
          end
        end

        i = i + 1
      end

      q.save

      q_type.question = q if custom_rubric
      q_type.save if custom_rubric

      questions << q
    end
  end

  questions
end

def self.adjust_advice_size(questionnaire, question)
  if question.true_false and question.question_advices.length != 2
    question.question_advices << QuestionAdvice.new(:score=>0)
    question.question_advices << QuestionAdvice.new(:score=>1)

    QuestionAdvice.delete_all(["question_id = ? AND (score > 1 OR score < 0)", question.id])
    return true
  elsif question.true_false == false
    for i in (questionnaire.min_question_score..questionnaire.max_question_score)
      print "\n#{i}: #{question.id}"
      qa = QuestionAdvice.where("question_id = #{question.id} AND score = #{i}").first

        if qa == nil
          print " NEW "
          question.question_advices << QuestionAdvice.new(:score=>i)
      end
    end

    QuestionAdvice.delete_all(["question_id = ? AND (score > ? OR score < ?)",
                               question.id, questionnaire.max_question_score, questionnaire.min_question_score])
    return true
  end

  return false
end
end
