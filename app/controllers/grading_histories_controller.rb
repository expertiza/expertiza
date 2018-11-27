class GradingHistoriesController < ApplicationController
  before_action :set_grading_history, only: [:show, :edit, :update, :destroy]

  def action_allowed?
    true
  end

  # GET /grading_histories
  def index
    @grading_histories = GradingHistory.all
  end
end
