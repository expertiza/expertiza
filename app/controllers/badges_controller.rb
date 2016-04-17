class BadgesController < ApplicationController

  def action_allowed?
    true
  end

  def new i=0
    course_id = params[:course_id]
    @assignments = Assignment.where("course_id = ?", course_id)
  end

  def create
    i = 0
    j = 0
  end

  def show
  end

  def index
  end

  def configuration
  end
end
