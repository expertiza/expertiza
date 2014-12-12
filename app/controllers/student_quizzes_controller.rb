class StudentQuizzesController < ApplicationController

  def index
    participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(participant.user_id)
    @assignment = Assignment.find(participant.parent_id)
    @quiz_mappings = QuizResponseMap.get_mappings_for_reviewer(participant.id)
  end

  def finished_quiz
    @response = Response.where(map_id: params[:map_id])
    @response_map = ResponseMap.find(params[:map_id])
    @questions = Question.where(questionnaire_id: @response_map.reviewed_object_id)

    essay_not_graded = false
    quiz_score = 0.0

    @questions.each do |question|
      score = Score.where(response_id: @response.id, question_id:  question.id).first
      if score.score.eql? -1
        essay_not_graded = true
      else
        quiz_score += score.score
      end
    end

    question_count = @questions.length

    @quiz_score = (quiz_score/question_count) * 100
    if essay_not_graded
      flash.now[:note] = "Some essay questions in this quiz have not yet been graded."
    end
  end

  def self.take_quiz assignment_id , reviewer_id
    quizzes = Array.new
    reviewer = Participant.where(user_id: reviewer_id, parent_id: assignment_id).first
    Team.where(parent_id: assignment_id).each do |quiz_creator|
      unless TeamsUser.find_by_team_id(quiz_creator.id).user_id == reviewer_id
        Questionnaire.where(instructor_id: quiz_creator.id).each do |questionnaire|
          unless QuizResponseMap.where(reviewed_object_id: questionnaire.id, reviewer_id:  reviewer.id).first
            quizzes.push(questionnaire)
          end
        end
      end
    end
    return quizzes
  end

  def calculate_score map, response
    questionnaire = Questionnaire.find(map.reviewed_object_id)
    scores = Array.new
    valid = true
    questions = Question.where(questionnaire_id: questionnaire.id)
    questions.each do |question|
      score = 0
      correct_answers = QuizQuestionChoice.where(question_id: question.id, iscorrect: true)
      ques_type = (QuestionType.where( question_id: question.id)).q_type
      if ques_type.eql? 'MCC'
        if params["#{question.id}"].nil?
          valid = false
        else
          params["#{question.id}"].each do |choice|

            correct_answers.each do |correct|
              if choice.eql? correct.txt
                score += 1
              end

            end
            new_score = Score.new comments: choice, question_id: question.id, response_id: response.id

            unless new_score.valid?
              valid = false
            end
            scores.push(new_score)

          end
          if score.eql? correct_answers.count && score == params["#{question.id}"].count
            score = 1
          else
            score = 0
          end
          scores.each do |score_update|
            score_update.score = score
          end
        end
      else
        correct_answer = correct_answers.first
        if ques_type.eql? 'Essay'
          score = -1
        elsif  correct_answer && params["#{question.id}"]== correct_answer.txt
          score = 1
        end
        new_score = Score.new :comments => params["#{question.id}"], :question_id => question.id, :response_id => response.id, :score => score
        if new_score.comments.empty? || new_score.comments.nil?
          valid = false
        end
        scores.push(new_score)
      end
    end
    if valid
      scores.each do |score|
        score.save
      end
      redirect_to :controller => 'student_quizzes', :action => 'finished_quiz', :map_id => map.id
    else
      flash[:error] = "Please answer every question."
      redirect_to :action => :take_quiz, :assignment_id => params[:assignment_id], :questionnaire_id => questionnaire.id
    end
  end

  def record_response
    map = ResponseMap.find(params[:map_id])
    response = Response.new
    response.map_id = params[:map_id]
    response.created_at = DateTime.current
    response.updated_at = DateTime.current
    response.save

    calculate_score map,response

  end

  def submit_essay_grades
    params.inspect
    response_id = params[:response_id]
    question_id = params[:question_id]
    score = params[question_id][:score]
    if score.eql? ' '
      flash[:error] =  "Question was not graded. You must choose a score before submitting for grading."
    else
      updated_score = Score.where(question_id: question_id, response_id:  response_id).first
      updated_score.update_attributes(:score => score)
    end
    redirect_to :action => :grade_essays
  end

  def grade_essays
    scores = Score.where(score: -1)
    @questions = Array.new
    @answers = Hash.new
    @questionnaires = Array.new
    scores.each do |score|
      question = Question.find(score.question_id)
      @questions << question
      @questionnaires << QuizQuestionnaire.find(question.questionnaire_id)
      @answers.merge!({question: score})
    end
    @questionnaires.uniq!
  end

  def graded?(response, question)
    return (Score.where(question_id: question.id, response_id:  response.id).first)
  end
end
