module QuestionnaireHelper
  
  questionnaireS_FOLDER = "public/temp-questionnaires/" # CSV files are stored in a temporary public directory
  CSV_ALLOWED_AGE = 60 * 5 # CSV files may be deleted if they are 5 minutes old

  CSV_QUESTION = 0
  CSV_TYPE = 1
  CSV_WEIGHT = 2

  def self.create_questionnaire_csv(questionnaire, user_name)
    questionnaireHelper::delete_expired_csv_files
    filename = questionnaireS_FOLDER + user_name + "-" + questionnaire.name + ".csv"
    buf = File.new(filename, 'w')
    
    for question in questionnaire.questions
      # Each row is formatted as follows
      # Question, question advice (from high score to low), type, weight
      row = Array.new
      row << question.txt
      row << "True/False" if question.true_false
      row << "Numeric" if !question.true_false
      row << question.weight
      
      # loop through all the question advice from highest score to lowest score
      adjust_advice_size(questionnaire, question)
      for advice in question.question_advices.sort {|x,y| y.score <=> x.score }
        row << advice.advice
      end
      
      CSV.generate_row(row, 3 + question.question_advices.length, buf)
    end
    
    buf.close
    return filename
  end
  
  def self.get_questions_from_csv(questionnaire, file)
    questions = Array.new
    
    CSV::Reader.parse(file) do |row|
      if row.length > 0
        i = 0
        score = questionnaire.max_question_score
        q = Question.new
        q.true_false = false
        
        for cell in row
          case i
            when CSV_QUESTION
              q.txt = cell.strip if cell != nil
            when CSV_TYPE
              if cell != nil and cell.downcase.strip === Question::TRUE_FALSE.downcase
                q.true_false = true
              else
                q.true_false = false
              end
            when CSV_WEIGHT
              q.weight = cell.strip.to_i if cell != nil
            else
              if score >= questionnaire.min_question_score and cell != nil
                a = QuestionAdvice.new(:score => score, :advice => cell.strip) if !q.true_false
                a = QuestionAdvice.new(:score => 1, :advice => cell.strip) if q.true_false and i == 3
                a = QuestionAdvice.new(:score => 0, :advice => cell.strip) if q.true_false and i == 4
                score = score - 1
                q.question_advices << a
              end
            end
          i = i + 1 
        end
       
        questions << q
      end
    end
  
    return questions
  end

  def self.delete_expired_csv_files
    # Deletes any old CSV files that reside in the temp directory
    files = Dir[questionnaireS_FOLDER + "*"]
    for file in files
      if Time.now > File.ctime(file) + CSV_ALLOWED_AGE and file.include? ".csv"
        File.delete(file)
      end 
    end
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
