module StudentQuizzesHelper
    # the way 'answers' table store the results of quiz
    def calculate_score(map, response)
        questionnaire = Questionnaire.find(map.reviewed_object_id)
        scores = []
        valid = true
        questions = Question.where(questionnaire_id: questionnaire.id)
        questions.each do |question|
            score = 0
            correct_answers = QuizQuestionChoice.where(question_id: question.id, iscorrect: true)
            ques_type = question.type
            if ques_type.eql? 'MultipleChoiceCheckbox'
                if params[question.id.to_s].nil?
                    valid = false
                else
                    params[question.id.to_s].each do |choice|
                        # loop the quiz taker's choices and see if 1)all the correct choice are checked and 2) # of quiz taker's choice matches the # of the correct choices
                        correct_answers.each do |correct|
                            score += 1 if choice.eql? correct.txt
                        end
                    end
                    score = score == correct_answers.count && score == params[question.id.to_s].count ? 1 : 0
                    # for MultipleChoiceCheckbox, score =1 means the quiz taker have done this question correctly, not just make select this choice correctly.
                    params[question.id.to_s].each do |choice|
                        new_score = Answer.new comments: choice, question_id: question.id, response_id: response.id, answer: score
                        valid = false unless new_score.valid?
                        scores.push(new_score)
                    end
                end
            else # TrueFalse and MultipleChoiceRadio
                correct_answer = correct_answers.first
                score = correct_answer.txt == params[question.id.to_s] ? 1 : 0
                new_score = Answer.new comments: params[question.id.to_s], question_id: question.id, response_id: response.id, answer: score
                valid = false if new_score.nil? || new_score.comments.nil? || new_score.comments.empty?
                scores.push(new_score)
            end
        end
        if valid
            scores.each(&:save)
            redirect_to controller: 'student_quizzes', action: 'finished_quiz', map_id: map.id
        else
            response.destroy
            flash[:error] = 'Please answer every question.'
            redirect_to action: :take_quiz, assignment_id: params[:assignment_id], questionnaire_id: questionnaire.id, map_id: map.id
        end
    end
end
