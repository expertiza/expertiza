module StudentQuizzesHelper
  # This method as whole fetches the answers provided and calculates the final scores for the quiz.
  # Also calls separate methods for handling single answer/ true or false evaluations and multiple answer evaluations for calculating score.
  def calculate_score(map, response)
    questionnaire = Questionnaire.find(map.reviewed_object_id)
    answers = []
    has_response = true
    questions = Question.where(questionnaire_id: questionnaire.id)
    questions.each do |question|
      correct_answers = QuizQuestionChoice.where(question_id: question.id, iscorrect: true)
      ques_type = question.type
      if ques_type.eql? 'MultipleChoiceCheckbox'
        has_response = multiple_answer_evaluation(answers, params, question, correct_answers, has_response, response)
      # TrueFalse and MultipleChoiceRadio
      else
        has_response = single_answer_evaluation(answers, params, question, correct_answers, has_response, response)
      end
    end
    if has_response
      answers.each(&:save)
      redirect_to controller: 'student_quizzes', action: 'finished_quiz', map_id: map.id
    else
      response.destroy
      flash[:error] = 'Please answer every question.'
      redirect_to action: :take_quiz, assignment_id: params[:assignment_id], questionnaire_id: questionnaire.id, map_id: map.id
    end
  end

  # Evaluates scores for questions that contains multiple answers
  def multiple_answer_evaluation(answers, params, question, correct_answers, has_response, response)
    score = 0
    if params[question.id.to_s].nil?
      has_response = false
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
        new_answer = Answer.new comments: choice, question_id: question.id, response_id: response.id, answer: score

        has_response = false unless new_answer.valid?
        answers.push(new_answer)
      end
    end
    return has_response
  end

  # Evaluates scores for questions that contains only single/ true or false answers
  def single_answer_evaluation(answers, params, question, correct_answers, has_response, response)
    correct_answer = correct_answers.first
    score = correct_answer.txt == params[question.id.to_s] ? 1 : 0
    new_score = Answer.new comments: params[question.id.to_s], question_id: question.id, response_id: response.id, answer: score
    has_response = false if new_score.nil? || new_score.comments.nil? || new_score.comments.empty?
    answers.push(new_score)
    return has_response
  end
end
