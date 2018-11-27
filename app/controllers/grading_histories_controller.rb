class GradingHistoriesController < ApplicationController
  before_action :set_grading_history, only: [:show, :edit, :update, :destroy]

  # GET /grading_histories
  def index
    @grading_histories = GradingHistory.where(grade_receiver_id: params[:grade_receiver_id])
  end
end
