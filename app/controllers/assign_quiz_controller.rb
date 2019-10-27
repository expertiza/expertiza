class AssignQuizController < ApplicationController
  
  def choose_case(action_in_params)
    if ['assign_quiz_dynamically'].include? action_in_params
      return true
    else ['Instructor', 'Teaching Assistant', 'Administrator'].include? current_role_name
    end
  end

  def action_allowed?
    # case params[:action]
    return choose_case(params[:action])
  end

  # assigns the quiz dynamically to the participant
  def assign_quiz_dynamically
    begin
      assignment = Assignment.find(params[:assignment_id])
      reviewer = AssignmentParticipant.where(user_id: params[:reviewer_id], parent_id: assignment.id).first
      if ResponseMap.where(reviewed_object_id: params[:questionnaire_id], reviewer_id: params[:participant_id]).first
        flash[:error] = "You have already taken that quiz."
      else
        @map = QuizResponseMap.new
        @map.reviewee_id = Questionnaire.find(params[:questionnaire_id]).instructor_id
        @map.reviewer_id = params[:participant_id]
        @map.reviewed_object_id = Questionnaire.find_by(instructor_id: @map.reviewee_id).id
        @map.save
      end
    rescue StandardError => e
      flash[:alert] = e.nil? ? $ERROR_INFO : e
    end
    redirect_to student_quizzes_path(id: reviewer.id)
  end
end
