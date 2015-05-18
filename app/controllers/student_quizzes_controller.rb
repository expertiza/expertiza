class StudentQuizzesController < ApplicationController
  def action_allowed?
    ['Administrator',
     'Instructor',
     'Teaching Assistant','Student'].include? current_role_name
  end

  def index
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)
    @assignment = Assignment.find(@participant.parent_id)
    @quiz_mappings = QuizResponseMap.get_mappings_for_reviewer(@participant.id)
  end

  def finished_quiz
    @response = Response.where(map_id: params[:map_id]).first
    @response_map = ResponseMap.find(params[:map_id])
    @questions = Question.where(questionnaire_id: @response_map.reviewed_object_id) #for quiz response map, the reivewed_object_id is questionnaire id
    @map = ResponseMap.find(params[:map_id])
    @participant = AssignmentTeam.find(@map.reviewee_id).participants.first

    quiz_score = 0.0

    @questions.each do |question|
      score = Score.where(response_id: @response.id, question_id:  question.id).first
      if score.score.eql? -1
        #This used to be designed for ungraded essay question.
      else
        quiz_score += score.score
      end
    end

    question_count = @questions.length

    @quiz_score = (quiz_score/question_count) * 100
  end

  #Create an array of candidate quizzes for current reviewer
  def self.take_quiz assignment_id , reviewer_id
    quizzes = Array.new
    reviewer = Participant.where(user_id: reviewer_id, parent_id: assignment_id).first
    reviewed_team_response_maps = TeamReviewResponseMap.where(reviewer_id:reviewer.id)
    reviewed_team_response_maps.each do |team_response_map_record|
      reviewee_id=team_response_map_record.reviewee_id
      reviewee_team = Team.find(reviewee_id) #reviewees should always be teams
      if reviewee_team.parent_id!=assignment_id
        next
      end
      quiz_questionnaire = QuizQuestionnaire.where(instructor_id:reviewee_team.id).first
      if quiz_questionnaire
        quizzes << quiz_questionnaire
      end
    end
    quizzes
  end

  def calculate_score map, response
    questionnaire = Questionnaire.find(map.reviewed_object_id)
    scores = Array.new
    valid = true
    questions = Question.where(questionnaire_id: questionnaire.id)
    questions.each do |question|
      score = 0
      correct_answers = QuizQuestionChoice.where(question_id: question.id, iscorrect: true)
      ques_type = (QuestionType.where( question_id: question.id).first).q_type
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
      else #TF and MCR
        correct_answer = correct_answers.first
        if correct_answer.txt==params["#{question.id}"]
          score=1
        else
          score=0
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

  def graded?(response, question)
    return (Score.where(question_id: question.id, response_id:  response.id).first)
  end

  private
  #special_role: reader,submitter, reviewer
  def permission_of_special_roles
    @participant = Participant.find(params[:id])
    if @participant.special_role == 'submitter' or @participant.special_role == 'reviewer'
      flash[:error] = "Access denied!"
      redirect_to controller: 'student_task', action:'view', id: @participant.id
    end
  end
end
