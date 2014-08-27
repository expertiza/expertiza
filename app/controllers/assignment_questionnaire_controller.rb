#Author: Hao Liu
#Email: hliu11@ncsu.edu

class AssignmentQuestionnaireController < ApplicationController
  #delete all AssignmentQuestionnaire entry that's associated with an assignment
  def delete_all
    assignment = Assignment.find(params[:assignment_id])
    if assignment.nil?
      return #TODO: add error message
    end

    @assignment_questionnaires = AssignmentQuestionnaire.where(assignment_id: params[:assignment_id])
    @assignment_questionnaires.each do |assignment_questionnaire|
      assignment_questionnaire.delete
    end

    respond_to do |format|
      format.json { render :json => @assignment_questionnaires }
    end
  end

  def create
    if params[:assignment_id].nil? or params[:questionnaire_id].nil?
      return #TODO: add error message
    end

    assignment = Assignment.find(params[:assignment_id])
    if assignment.nil?
      return #TODO: add error message
    end

    questionnaire = Questionnaire.find(params[:questionnaire_id])
    if questionnaire.nil?
      return #TODO: add error message
    end

    @assignment_questionnaire = AssignmentQuestionnaire.new(params)
    @assignment_questionnaire.save

    respond_to do |format|
      format.json { render :json => @assignment_questionnaire }
    end
  end
end
