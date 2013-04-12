require 'fastercsv'
require 'csv'

module QuestionnaireHelper
  
  CSV_QUESTION = 0
  CSV_TYPE = 1
  CSV_WEIGHT = 2
  #CSV_PARAM = 3

  def self.create_questionnaire_csv(questionnaire, user_name)
   csv_data = FasterCSV.generate do |csv|
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
    
    CSV::Reader.parse(file) do |row|
      if row.length > 0
        i = 0
        score = questionnaire.max_question_score
        q = Question.new

        #if questionnaire.section == "Custom"
          #q_type = QuestionType.new
        #  q_type.question_id = q.id
        #end
        q.true_false = false
        
        for cell in row
          case i
            when CSV_QUESTION
              q.txt = cell.strip if cell != nil
            when CSV_TYPE
              if cell != nil
                if cell.downcase.strip === Question::TRUE_FALSE.downcase
                  q.true_false = true
                elsif cell.downcase.strip === Question::NUMERIC.downcase
                  q.true_false = false
                else
                 # q_type.q_type = cell.strip
                end
              end
            when CSV_WEIGHT
              q.weight = cell.strip.to_i if cell != nil
            #when CSV_PARAM
            #  if questionnaire.section != "Custom"
            #    if score >= questionnaire.min_question_score and cell != nil
            #      a = QuestionAdvice.new(:score => score, :advice => cell.strip) if !q.true_false
            #    end
            #  else
            #      q_type.parameters = cell.strip
            #  end
            else
                if score >= questionnaire.min_question_score and cell != nil
                  #if questionnaire.section == "Custom"
                   a = QuestionAdvice.new(:score => score, :advice => cell.strip)
                  #end
                  a = QuestionAdvice.new(:score => 1, :advice => cell.strip) if q.true_false and i == 4
                  a = QuestionAdvice.new(:score => 0, :advice => cell.strip) if q.true_false and i == 5
                  score = score - 1
                  q.question_advices << a
                end
            end

          i = i + 1
        end

        #q_type.save
        #@q << q_type
        questions << q

      end
    end
  
    return questions
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
        qa = QuestionAdvice.find(:first, 
                                 :conditions=>"question_id = #{question.id} AND score = #{i}")
                                 
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
