
class FeedbackSupportsController < ApplicationController
  before_action :set_feedback_support, only: [:show, :edit, :update, :destroy]

  # GET /feedback_supports
  def index
    @feedback_supports = FeedbackSupport.all
  end

  # GET /feedback_supports/1
  def show
  end

  # GET /feedback_supports/new
  def new
    @feedback_support = FeedbackSupport.new
  end

  # GET /feedback_supports/1/edit
  def edit
  end

  # POST /feedback_supports
  def create
    @feedback_support = FeedbackSupport.new(feedback_support_params)

    if @feedback_support.save
      redirect_to @feedback_support, notice: 'Feedback support was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /feedback_supports/1
  def update
    if @feedback_support.update(feedback_support_params)
      redirect_to @feedback_support, notice: 'Feedback support was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /feedback_supports/1
  def destroy
    @feedback_support.destroy
    redirect_to feedback_supports_url, notice: 'Feedback support was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feedback_support
      @feedback_support = FeedbackSupport.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def feedback_support_params
      params[:feedback_support]
    end
end
