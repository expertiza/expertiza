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
    puts "in finished quiz"
    puts params[:map_id]

    @response_map = ResponseMap.find_by_id(params[:map_id])
    @questions = Question.find_all_by_questionnaire_id(@response_map.reviewed_object_id)
  end

  def self.take_quiz assignment_id , reviewer_id
    @questionnaire = Array.new
    @assignment = Assignment.find_by_id(assignment_id)
    if @assignment.team_assignment?
      teams = TeamsUser.find_all_by_user_id(reviewer_id)
      Team.find_all_by_parent_id(assignment_id).each do |quiz_creator|
        unless TeamsUser.find_by_team_id(quiz_creator.id).user_id == reviewer_id
          Questionnaire.find_all_by_instructor_id(quiz_creator.id).each do |questionnaire|
            @questionnaire.push(questionnaire)
          end
        end
      end
    else
      Participant.find_all_by_parent_id(assignment_id).each do |quiz_creator|
        unless quiz_creator.user_id == reviewer_id
          Questionnaire.find_all_by_instructor_id(quiz_creator.id).each do |questionnaire|
            @questionnaire.push(questionnaire)
          end
        end
      end
    end
    return @questionnaire
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
        correct_answer = QuizQuestionChoice.find_by_question_id_and_iscorrect(question.id, 1)
        if (QuestionType.find_by_question_id question.id).q_type == 'Essay'
          score = -1
        elsif params["#{question.id}"] == correct_answer.txt
          score = 1
        else
          score = 0
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

  def grade_essays
    @questionnaires = Array.new()
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
    end
  end

  def graded?(response, question)
    if Score.find_by_question_id_and_response_id(question.id, response.id)
      return true
    else
      return false
    end
  end


end
