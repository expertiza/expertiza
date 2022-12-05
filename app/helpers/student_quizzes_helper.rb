module StudentQuizzesHelper
    # the way 'answers' table store the results of quiz
    def calculate_score(participant_response, quiz_response)
        scores = []
        valid = true
        # Get the entire questionnaire assigned to 'participant_response'
        get_all_questions(participant_response).each do |question|
            # Get correct answer for each question in the questionnaire
            correct_answers = QuizQuestionChoice.where(question_id: question.id, iscorrect: true)

            #Using Chain Of Responsibility pattern to calculate score
            valid = score_multiple_choice_checkbox(correct_answers, question, params, valid, scores, quiz_response)
        end
        score_response = Hash.new
        score_response["valid"] = valid
        score_response["scores"] = scores
        score_response["quiz_response"] = quiz_response
        score_response
    end

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
        unless question.type.eql? 'MultipleChoiceCheckbox'
            return score_single_choice_radio(correct_answers, params, question, scores, quiz_response, valid)
        end
        valid = is_valid_checkbox(params, question, valid)
        score = 0
        params[question.id.to_s].each do |choice|
            # loop the quiz taker's choices and see if 1)all the correct choice are checked and 2) # of quiz taker's choice matches the # of the correct choices
            correct_answers.each do |correct|
                score += 1 if choice.eql? correct.txt #adding scores based on each correct answer
            end
        end
        score = score == correct_answers.count && score == params[question.id.to_s].count ? 1 : 0
        # for MultipleChoiceCheckbox, score =1 means the quiz taker have done this question correctly, not just make select this choice correctly.
        score_checkbox(scores, params, question, valid, quiz_response, score)
    end

    # Update and append the new_score object in scores array and update the valid flag by performing validations
    def score_checkbox(scores, params, question, valid, quiz_response, score)
        params[question.id.to_s].each do |choice| # checking for the input for each of the checkbox pattern question
            new_score = Answer.new comments: choice, question_id: question.id, response_id: quiz_response.id, answer: score
            valid = false unless new_score.valid? #flagging false if the answer goes unattemtpted
            scores.push(new_score)
        end
        valid
    end

    
    def score_single_choice_radio(correct_answers, params, question, scores, quiz_response, valid)
        correct_answer = correct_answers.first
        score = correct_answer.txt == params[question.id.to_s] ? 1 : 0    #checking whether the answser is correct and assigning score 0 or 1
        new_score = Answer.new comments: params[question.id.to_s], question_id: question.id, response_id: quiz_response.id, answer: score
        valid = false if new_score.nil? || new_score.comments.nil? || new_score.comments.empty? # flagging false if questions goes unattempted
        scores.push(new_score) # Appending into score array
        valid
    end
end
