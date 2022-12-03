module StudentQuizzesHelper
    # the way 'answers' table store the results of quiz
    def calculate_score(participant_response, quiz_response)
        scores = []
        valid = true
        # Get the entire questionnaire assigned to 'participant_response'
        get_all_questions(participant_response).each do |question|
            correct_answers = QuizQuestionChoice.where(question_id: question.id, iscorrect: true) # Get correct answer for each question in the questionnaire
            ques_type = question.type
            # Update valid flag based on the question type i.e. Radio or Multiple Checkbox or True or False.
            if ques_type.eql? 'MultipleChoiceCheckbox'
                valid = is_valid_checkbox(params, question, valid)
                valid = score_multiple_choice_checkbox(correct_answers, question, params, valid, scores, quiz_response)
            else # TrueFalse and MultipleChoiceRadio
                valid = score_multiple_choice_radio(correct_answers, params, question, scores, quiz_response, valid)
            end
        end
        #save_scores_if_valid?(valid, scores, quiz_response,participant_response)
        score_response = Hash.new
        score_response["valid"] = valid
        score_response["scores"] = scores
        score_response["quiz_response"] = quiz_response
        score_response
    end

#     def save_scores_if_valid?(valid, scores, quiz_response,participant_response)
#         if valid
#             scores.each(&:save)
#             redirect_to controller: 'student_quizzes', action: 'finished_quiz', map_id: participant_response.id
#         else
#             quiz_response.destroy
#             flash[:error] = 'Please answer every question.'
#             questionnaire = Questionnaire.find(participant_response.reviewed_object_id)
#             redirect_to action: :take_quiz, assignment_id: params[:assignment_id], questionnaire_id: questionnaire.id, map_id: participant_response.id
#         end
#     end
    
    # Return all the questions in the questionnaire which is fetched via the review done by the student
    def get_all_questions(participant_response)
        questionnaire = Questionnaire.find(participant_response.reviewed_object_id)
        Question.where(questionnaire_id: questionnaire.id)
    end

    def is_valid_checkbox(params, question, valid)
        # Checking whether the answer was attempted or left empty
        if params[question.id.to_s].nil?
            valid = false;
        end
        valid
    end

    def score_multiple_choice_checkbox(correct_answers, question, params, valid, scores, quiz_response)
        score = 0
        params[question.id.to_s].each do |choice|
            # loop the quiz taker's choices and see if 1)all the correct choice are checked and 2) # of quiz taker's choice matches the # of the correct choices
            correct_answers.each do |correct|
                score += 1 if choice.eql? correct.txt
            end
        end
        score = score == correct_answers.count && score == params[question.id.to_s].count ? 1 : 0
        # for MultipleChoiceCheckbox, score =1 means the quiz taker have done this question correctly, not just make select this choice correctly.
        score_checkbox(scores, params, question, valid, quiz_response, score)
    end

    def score_checkbox(scores, params, question, valid, quiz_response, score)
        params[question.id.to_s].each do |choice|
            new_score = Answer.new comments: choice, question_id: question.id, response_id: quiz_response.id, answer: score
            valid = false unless new_score.valid?
            scores.push(new_score)
        end
        valid
    end

    def score_multiple_choice_radio(correct_answers, params, question, scores, quiz_response, valid)
        correct_answer = correct_answers.first
        score = correct_answer.txt == params[question.id.to_s] ? 1 : 0    #checking whether the answser is correct and assigning score 0 or 1
        new_score = Answer.new comments: params[question.id.to_s], question_id: question.id, response_id: quiz_response.id, answer: score
        valid = false if new_score.nil? || new_score.comments.nil? || new_score.comments.empty?
        scores.push(new_score)
        valid
    end
end
