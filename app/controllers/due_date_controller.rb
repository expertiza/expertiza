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
    Rails.logger.info "Inside Create method of DueDateController"
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

    @due_date = AssignmentDueDate.new(params)
    @due_date.save
    Rails.logger.info "Calling the perform_in method"
    MailWorker.perform_in((@due_date.due_at - Time.now - 2*60), @due_date.parent_id, @due_date.deadline_name, @due_date.due_at )



    respond_to do |format|
      format.json { render json: @due_date }
    end
  end
end
