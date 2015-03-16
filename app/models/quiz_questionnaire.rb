class QuizQuestionnaire < Questionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Quiz'
  end

  def symbol
    return "quiz".to_sym
  end

  def get_assessments_for(participant)
    participant.get_quizzes_taken()
  end

  def get_weighted_score(scores)
    return compute_weighted_score(scores)
  end

  def compute_weighted_score(scores)
    if scores[:quiz][:scores][:avg]
      #dont bracket and to_f the whole thing - you get a 0 in the result.. what you do is just to_f the 100 part .. to get the fractions
      return scores[:quiz][:scores][:avg] * 100  / 100.to_f
      else
        return 0
    end
  end

  def self.valid_quiz(aid,new_question,question_type,new_choices)
    num_quiz_questions = Assignment.find(aid).num_quiz_questions
    valid = "valid"

    (1..num_quiz_questions).each do |i|
      if new_question[i.to_s][:txt] == ''
        #One of the questions text is not filled out
        valid = "Please make sure all questions have text"
        break
      elsif question_type[i.to_s][:type] == nil
        #A type isnt selected for a question
        valid = "Please select a type for each question"
        break
      else
        type = question_type[i.to_s][:type]
        if type == 'MCC' or type == 'MCR'
          correct_selected = false
          (1..4).each do |x|
            if new_choices[i.to_s][type][x.to_s][:txt] == ''
              #Text isnt provided for an option
              valid = "Please make sure every question has text for all options"
              break
            elsif type == 'MCR' and not new_choices[i.to_s][type][x.to_s][:iscorrect] == nil
              correct_selected = true
            elsif type == 'MCC' and not new_choices[i.to_s][type][x.to_s][:iscorrect] == 0.to_s
              correct_selected = true
            end
          end
          unless correct_selected == true
            #A correct option isnt selected for a check box or radio question
            valid = "Please select a correct answer for all questions"
            break
          end
        elsif type == 'TF'
          if new_choices[i.to_s]["TF"] == nil
            #A correct option isnt selected for a true/false question
            valid = "Please select a correct answer for all questions"
            break
          end
        end
      end
    end

    return valid
  end

end
