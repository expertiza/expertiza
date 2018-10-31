class QuizQuestionnaire < Questionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Quiz'
  end

  def symbol
    "quiz".to_sym
  end

  def get_assessments_for(participant)
    participant.quizzes_taken
  end

  def get_weighted_score(scores)
    compute_weighted_score(scores)
  end

  def compute_weighted_score(scores)
    if scores[:quiz][:scores][:avg]
      # dont bracket and to_f the whole thing - you get a 0 in the result.. what you do is just to_f the 100 part .. to get the fractions
      scores[:quiz][:scores][:avg] * 100 / 100.to_f
    else
      0
      end
    end

  def valid
    num_quiz_questions = Assignment.find(params[:aid]).num_quiz_questions
    valid = "valid"

    (1..num_quiz_questions).each do |i|
      if params[:questionnaire][:name] == ""
        # questionnaire name is not specified
        valid = "Please specify quiz name (please do not use your name or id)."
        break
      elsif !params.key?(:question_type) || !params[:question_type].key?(i.to_s) || params[:question_type][i.to_s][:type].nil?
        # A type isnt selected for a question
        valid = "Please select a type for each question"
        break
      else
        @new_question = Object.const_get(params[:question_type][i.to_s][:type]).create(txt: '', type: params[:question_type][i.to_s][:type], break_before: true)
        @new_question.update_attributes(txt: params[:new_question][i.to_s])
        type = params[:question_type][i.to_s][:type]
        choice_info = params[:new_choices][i.to_s][type] # choice info for one question of its type
        if choice_info.nil?
          valid = "Please select a correct answer for all questions"
          break
        else
          valid = @new_question.isvalid(choice_info)
          break if valid != "valid"
        end
      end
    end
    valid
  end  

  def change_question_types(quiz_question_choice, type, id, i)
	if type == "MultipleChoiceCheckbox"
            if params[:quiz_question_choices][id.to_s][type][i.to_s]
              quiz_question_choice.update_attributes(iscorrect: params[:quiz_question_choices][id.to_s][type][i.to_s][:iscorrect], txt: params[:quiz_question_choices][id.to_s][type][i.to_s][:txt])
            else
              quiz_question_choice.update_attributes(iscorrect: '0', txt: params[:quiz_question_choices][quiz_question_choice.id.to_s][:txt])
            end
          end
          if type == "MultipleChoiceRadio"
            if params[:quiz_question_choices][id.to_s][type][:correctindex] == i.to_s
              quiz_question_choice.update_attributes(iscorrect: '1', txt: params[:quiz_question_choices][id.to_s][type][i.to_s][:txt])
            else
              quiz_question_choice.update_attributes(iscorrect: '0', txt: params[:quiz_question_choices][id.to_s][type][i.to_s][:txt])
            end
          end
          if type == "TrueFalse"
            if params[:quiz_question_choices][id.to_s][type][1.to_s][:iscorrect] == "True" # the statement is correct
              if quiz_question_choice.txt == "True"
                quiz_question_choice.update_attributes(iscorrect: '1') # the statement is correct so "True" is the right answer
              else
                quiz_question_choice.update_attributes(iscorrect: '0')
              end
            else # the statement is not correct
              if quiz_question_choice.txt == "True"
                quiz_question_choice.update_attributes(iscorrect: '0')
              else
                quiz_question_choice.update_attributes(iscorrect: '1') # the statement is not correct so "False" is the right answer
              end
            end
          end
  end

  def taken_by_anyone?
    !ResponseMap.where(reviewed_object_id: self.id, type: 'QuizResponseMap').empty?
  end

  def taken_by? participant
    !ResponseMap.where(reviewed_object_id: self.id, type: 'QuizResponseMap', reviewer_id: participant.id).empty?
  end
  end
