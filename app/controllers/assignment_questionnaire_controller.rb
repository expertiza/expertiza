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
      flash[:error] = "Assignment #" + assignment.id + " does not currently exist."
      return
    end

    @assignment_questionnaires = AssignmentQuestionnaire.where(assignment_id: params[:assignment_id])
    @assignment_questionnaires.each(&:delete)

    respond_to do |format|
      format.json { render json: @assignment_questionnaires }
    end
  end

  def create
    if params[:assignment_id].nil?
      flash[:error] = "Missing assignment:" + params[:assignment_id]
      return
    elsif params[:questionnaire_id].nil?
      flash[:error] = "Missing questionnaire:" + params[:questionnaire_id]
      return
    end

    assignment = Assignment.find(params[:assignment_id])
    if assignment.nil?
      flash[:error] = "Assignment #" + assignment.id + " does not currently exist."
      return
    end

    questionnaire = Questionnaire.find(params[:questionnaire_id])
    if questionnaire.nil?
      flash[:error] = "Questionaire #" + questionnaire.id + " does not currently exist."
      return
    end

    @assignment_questionnaire = AssignmentQuestionnaire.new(params)
    @assignment_questionnaire.save

    respond_to do |format|
      format.json { render json: @assignment_questionnaire }
    end
  end
end
