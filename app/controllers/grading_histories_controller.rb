class GradingHistoriesController < ApplicationController
  before_action :set_grading_history, only: %i[show edit update destroy]

  def action_allowed?
    return true if ['Instructor','Teaching Assistant','Super-Administrator', 'Administrator'].include? current_role_name
  end

  # GET /grading_histories
  def index
    @grading_histories = GradingHistory.where(grade_receiver_id: params[:grade_receiver_id])
  end
end
