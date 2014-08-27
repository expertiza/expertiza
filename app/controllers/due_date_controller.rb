#Author: Hao Liu
#Email: hliu11@ncsu.edu
#created at: May, 28, 2013
#update at: May, 28, 2013

#added the below lines E913
#No changes needed
#our changes end E913
class DueDateController < ApplicationController

  def delete_all
    if params[:assignment_id].nil?
      return #TODO: add error message
    end

    assignment = Assignment.find(params[:assignment_id])
    if assignment.nil?
      return #TODO: add error message
    end

    @due_dates = DueDate.where(assignment_id: params[:assignment_id])
    @due_dates.each do |due_date|
      due_date.delete
    end

    respond_to do |format|
      format.json { render :json => @due_dates }
    end
  end

  def create
    if params[:assignment_id].nil?
      return #TODO: add error message
    end

    assignment = Assignment.find(params[:assignment_id])
    if assignment.nil?
      return #TODO: add error message
    end

    due_at = DateTime.parse(params[:due_at])
    if due_at.nil?
      return #TODO: add error message
    end

    @due_date = DueDate.new(params)
    @due_date.save

    respond_to do |format|
      format.json { render :json => @due_date }
    end
  end
end
