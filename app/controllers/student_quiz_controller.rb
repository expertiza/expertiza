class StudentQuizController < ApplicationController
  def list
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @assignment = Assignment.find(@participant.parent_id)

    # Find the current phase that the assignment is in.
    @quiz_phase = @assignment.get_current_stage(AssignmentParticipant.find(params[:id]).topic_id)

    @quiz_mappings = QuizResponseMap.find_all_by_reviewer_id(@participant.id)

    # Calculate the number of quizzes that the user has completed so far.
    @num_quizzes_total = @quiz_mappings.size

    @num_quizzes_completed = 0
    @quiz_mappings.each do |map|
      @num_quizzes_completed += 1 if map.response
    end

    if @assignment.staggered_deadline?
      @quiz_mappings.each { |quiz_mapping|
        if @assignment.team_assignment?
          participant = AssignmentTeam.get_first_member(quiz_mapping.reviewee_id)
        else
          participant = quiz_mapping.reviewee
        end

        if !participant.nil? and !participant.topic_id.nil?
          quiz_due_date = TopicDeadline.find_by_topic_id_and_deadline_type_id(participant.topic_id,1)
        end
      }
      deadline_type_id = DeadlineType.find_by_name('quiz').id
    end
  end

  def finished_quiz
    @response = Response.find_by_map_id(params[:map_id])
    @response_map = ResponseMap.find_by_id(params[:map_id])
    @questions = Question.find_all_by_questionnaire_id(@response_map.reviewed_object_id)

    essay_not_graded = false
    quiz_score = 0.0

    @questions.each do |question|
      score = Score.find_by_response_id_and_question_id(@response.id, question.id)
      if score.score == -1
        essay_not_graded = true
      else
        quiz_score += score.score
      end
    end

    question_count = @questions.length

    @quiz_score = (quiz_score/question_count) * 100
    if essay_not_graded == true
      flash.now[:note] = "Some essay questions in this quiz have not yet been graded."
    end
  end

  def self.take_quiz assignment_id , reviewer_id
    @quizzes = Array.new
    reviewer = Participant.find_by_user_id_and_parent_id(reviewer_id,assignment_id)
    @assignment = Assignment.find_by_id(assignment_id)
      teams = TeamsUser.find_all_by_user_id(reviewer_id)
      Team.find_all_by_parent_id(assignment_id).each do |quiz_creator|
        unless TeamsUser.find_by_team_id(quiz_creator.id).user_id == reviewer_id
          Questionnaire.find_all_by_instructor_id(quiz_creator.id).each do |questionnaire|
           if !@assignment.team_assignment?
            unless QuizResponseMap.find_by_reviewed_object_id_and_reviewer_id(questionnaire.id, reviewer.id)
              @quizzes.push(questionnaire)
            end
          else unless QuizResponseMap.find_by_reviewed_object_id_and_reviewer_id(questionnaire.id, reviewer_id)
                 @quizzes.push(questionnaire)
               end
          end
        end
      end
    end
    return @quizzes
  end

  def record_response
    @map = ResponseMap.find(params[:map_id])
    @response = Response.new()
    @response.map_id = params[:map_id]
    @response.created_at = DateTime.current
    @response.updated_at = DateTime.current
    @response.save

    @questionnaire = Questionnaire.find_by_id(@map.reviewed_object_id)
    scores = Array.new
    new_scores = Array.new
    valid = 0
    questions = Question.find_all_by_questionnaire_id @questionnaire.id
    questions.each do |question|
      score = 0
      if (QuestionType.find_by_question_id question.id).q_type == 'MCC'
        score = 0
        if params["#{question.id}"] == nil
          valid = 1
        else
          correct_answer = QuizQuestionChoice.find_all_by_question_id_and_iscorrect(question.id, 1)
          params["#{question.id}"].each do |choice|

            correct_answer.each do |correct|
              if choice == correct.txt
                score += 1
              end

            end
            new_score = Score.new :comments => choice, :question_id => question.id, :response_id => @response.id

            unless new_score.valid?
              valid = 1
            end
            new_scores.push(new_score)

          end
          unless score == correct_answer.count
            score = 0
          else
            score = 1
          end
          new_scores.each do |score_update|
            score_update.score = score
            scores.push(score_update)
          end
        end
      else
        score = 0
        correct_answer = QuizQuestionChoice.find_by_question_id_and_iscorrect(question.id, 1)
        if (QuestionType.find_by_question_id question.id).q_type == 'Essay'
          score = -1
        elsif  correct_answer and params["#{question.id}"] == correct_answer.txt
          score = 1
        end
        new_score = Score.new :comments => params["#{question.id}"], :question_id => question.id, :response_id => @response.id, :score => score
        unless new_score.comments != "" && new_score.comments
          valid = 1
        end
        scores.push(new_score)
      end
    end
    if valid == 0
      scores.each do |score|
        score.save
      end
      redirect_to :controller => 'student_quiz', :action => 'finished_quiz', :map_id => @map.id
    else
      flash[:error] = "Please answer every question."
      redirect_to :action => :take_quiz, :assignment_id => params[:assignment_id], :questionnaire_id => @questionnaire.id
    end

  end

  def submit_essay_grades
    params.inspect
    response_id = params[:response_id]
    question_id = params[:question_id]
    score = params[question_id][:score]
    if score !=  ' '
      updated_score = Score.find_by_question_id_and_response_id(question_id, response_id)
      updated_score.update_attributes(:score => score)
    else
      flash[:error] =  "Question was not graded. You must choose a score before submitting for grading."
    end
    redirect_to :action => :grade_essays
  end

  def grade_essays
    scores = Score.find_all_by_score(-1)
    @questions = Array.new
    @answers = Hash.new()
    @questionnaires = Array.new
    scores.each do |score|
      question = Question.find(score.question_id)
      @questions << question
      @questionnaires << QuizQuestionnaire.find(question.questionnaire_id)
      @answers = @answers.merge({Question.find(score.question_id) => score})
    end
    @questionnaires = @questionnaires.uniq
    %%@questionnaires = Array.new()
    @questionnaires = Questionnaire.find_all_by_type("QuizQuestionnaire")
    @questionnaire_questions = Hash.new()
    @questionnaires.each do |questionnaire|
      questions = Question.find_all_by_questionnaire_id(questionnaire.id)
      essay_questions = Array.new()
      questions.each do |question|
        if QuestionType.find_by_question_id(question.id).q_type == "Essay"
          essay_questions << question
        end
      end
      @questionnaire_questions = @questionnaire_questions.merge({questionnaire.id => essay_questions})
    end

    @quiz_responses = Hash.new()
    @questionnaires.each do |questionnaire|
      @questionnaire_questions[questionnaire.id].each do |question|
        ungraded_quiz_responses = Array.new()
        quiz_responses = QuizResponse.find_all_by_question_id(question.id)
        quiz_responses.each do |response|
          if !graded?(response, question)
            ungraded_quiz_responses << response
          end
        end

        @quiz_responses = @quiz_responses.merge({question => ungraded_quiz_responses})
      end
    end%
  end

  def graded?(response, question)
    if Score.find_by_question_id_and_response_id(question.id, response.id)
      return true
    else
      return false
    end
  end


end
