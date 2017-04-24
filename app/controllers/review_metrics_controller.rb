class ReviewMetricsController < ApplicationController
  before_action :set_review_metric, only: [:show, :edit, :update, :destroy]

  # Give permission to manage notifications to appropriate roles
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  # GET /review_metrics
  def index
    @review_metrics = ReviewMetric.all
  end

  # GET /review_metrics/1
  def show; end

  # GET /review_metrics/new
  def new
    @review_metric = ReviewMetric.new
  end

  # GET /review_metrics/1/edit
  def edit; end

  # POST /review_metrics
  def create
    @review_metric = ReviewMetric.new(review_metric_params)

    if @review_metric.save
      redirect_to @review_metric, notice: 'Review metric was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /review_metrics/1
  def update
    if @review_metric.update(review_metric_params)
      redirect_to @review_metric, notice: 'Review metric was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /review_metrics/1
  def destroy
    @review_metric.destroy
    redirect_to review_metrics_url, notice: 'Review metric was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_review_metric
    @review_metric = ReviewMetric.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def review_metric_params
    params.require(:review_metric).permit(:metric)
  end
end
