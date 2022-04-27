# Author: Hao Liu
# Email: hliu11@ncsu.edu

class AssignmentQuestionnaireController < ApplicationController
  include AuthorizationHelper

  # According to Dr. Gehringer, only the instructor, an ancestor of the instructor,
  # or the TA for the course should be allowed to execute a method of this controller
  def action_allowed?
    assignment = Assignment.find(params[:assignment_id])

    if assignment
      current_user_teaching_staff_of_assignment?(assignment.id) ||
        current_user_ancestor_of?(assignment.instructor)
    else
      false
    end
  end

  # delete all AssignmentQuestionnaire entry that's associated with an assignment
  def delete_all
    assignment = Assignment.find(params[:assignment_id])

    if assignment.nil?
      flash[:error] = 'Assignment #' + params[:assignment_id].to_s + ' does not currently exist.'
      return
    end

    @assignment_questionnaires = AssignmentQuestionnaire.where(assignment_id: params[:assignment_id])
    @assignment_questionnaires.each(&:delete)

    respond_to do |format|
      format.json { render json: @assignment_questionnaires }
    end
  end

  def create
    if assignment_questionnaire_params[:assignment_id].nil?
      flash[:error] = "Missing assignment"
      return
    elsif assignment_questionnaire_params[:questionnaire_id].nil?
      flash[:error] = "Missing questionnaire"
      return
    end

    assignment = Assignment.find(assignment_questionnaire_params[:assignment_id])
    if assignment.nil?
      flash[:error] = 'Assignment #' + params[:assignment_id].to_s + ' does not currently exist.'
      return
    end

    questionnaire = Questionnaire.find(assignment_questionnaire_params[:questionnaire_id])
    if questionnaire.nil?
      flash[:error] = 'Questionnaire #' + params[:questionnaire_id].to_s + ' does not currently exist.'
      return
    end
    @assignment_questionnaire = AssignmentQuestionnaire.new(assignment_questionnaire_params)
    @assignment_questionnaire.save

    respond_to do |format|
      format.json { render json: @assignment_questionnaire }
    end
  end

  private

  def assignment_questionnaire_params
    params.permit(:assignment_id, :questionnaire_id,
                  :user_id, :notification_limit, :questionnaire_weight,
                  :used_in_round, :dropdown, :topic_id, :duty_id)
  end
end
