# Author: Hao Liu
# Email: hliu11@ncsu.edu
# created at: May, 28, 2013
# update at: May, 28, 2013

# added the below lines E913
# No changes needed
# our changes end E913
class DueDateController < ApplicationController
  def delete_all
    if params[:assignment_id].nil?
      flash[:error] = "Missing assignment:" + params[:assignment_id]
      return
    end

    assignment = Assignment.find(params[:assignment_id])
    if assignment.nil?
      flash[:error] = "Assignment #" + assignment.id + " does not currently exist."
      return
    end

    @due_dates = AssignmentDueDate.where(parent_id: params[:assignment_id])
    @due_dates.each(&:delete)

    respond_to do |format|
      format.json { render json: @due_dates }
    end
  end

  def create
    if params[:assignment_id].nil?
      flash[:error] = "Missing assignment:" + params[:assignment_id]
      return
    end

    assignment = Assignment.find(params[:assignment_id])
    if assignment.nil?
      flash[:error] = "Assignment #" + assignment.id + " does not currently exist."
      return
    end

    due_at = DateTime.parse(params[:due_at])
    if due_at.nil?
      flash[:error] = "You need to specify all due dates and times."
      return
    end

    @due_date = AssignmentDueDate.new(assignment_due_date_params)
    @due_date.save

    respond_to do |format|
      format.json { render json: @due_date }
    end
  end

  private

  # Only allow a trusted parameter "white list" through.
  def assignment_due_date_params
    params.permit(:due_at, :deadline_type_id, :parent_id,
                  :submission_allowed_id, :review_allowed_id,
                  :review_of_review_allowed_id, :round, :flag, :threshold,
                  :delayed_job_id, :deadline_name, :description_url,
                  :quiz_allowed_id, :teammate_review_allowed_id, :type)
  end
end
