class GradingHistoriesController < ApplicationController
  before_action :set_grading_history, only: [:show, :edit, :update, :destroy]

  # GET /grading_histories
  def index
    @grading_histories = GradingHistory.all
  end

  # GET /grading_histories/1
  def show
  end

  # GET /grading_histories/new
  def new
    @grading_history = GradingHistory.new
  end

  # GET /grading_histories/1/edit
  def edit
  end

  # POST /grading_histories
  def create
    @grading_history = GradingHistory.new(grading_history_params)

    if @grading_history.save
      redirect_to @grading_history, notice: 'Grading history was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /grading_histories/1
  def update
    if @grading_history.update(grading_history_params)
      redirect_to @grading_history, notice: 'Grading history was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /grading_histories/1
  def destroy
    @grading_history.destroy
    redirect_to grading_histories_url, notice: 'Grading history was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grading_history
      @grading_history = GradingHistory.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def grading_history_params
      params.require(:grading_history).permit(:grading_type, :grade, :comment)
    end
end
