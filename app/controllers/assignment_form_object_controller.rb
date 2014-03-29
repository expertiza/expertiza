class AssignmentFormObjectController < ApplicationController

  def new

  end

  def create
    @assignment_form_object = AssignmentFormObject.new(params)
    if @assignment_form_object.save
      alert("Form saved")
    else
      alert("Error saving form")
    end

  end

  # copied from ~/assignments/set_due_date
  def add_due_date
    if params[:due_date][:assignment_id].nil?
      return
    end

    assignment = Assignment.find(params[:due_date][:assignment_id])
    if assignment.nil?
      return
    end

    due_at = DateTime.parse(params[:due_date][:due_at])
    if due_at.nil?
      return
    end

    due_date = DueDate.new(params[:due_date])
    @assignment_form_object.add_due_date(due_date)
    #@due_date.save

    respond_to do |format|
      format.json { render :json => @due_date }
    end
  end


end
