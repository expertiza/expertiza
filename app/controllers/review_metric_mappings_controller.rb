class ReviewMetricMappingsController < ApplicationController
  before_action :set_review_metric_mapping, only: [:show, :edit, :update, :destroy]

  # Give permission to manage notifications to appropriate roles
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  # GET /review_metric_mappings
  def index
    @review_metric_mappings = ReviewMetricMapping.all
  end

  # GET /review_metric_mappings/1
  def show; end

  # GET /review_metric_mappings/new
  def new
    @review_metric_mapping = ReviewMetricMapping.new
  end

  # GET /review_metric_mappings/1/edit
  def edit; end

  # POST /review_metric_mappings
  def create
    @review_metric_mapping = ReviewMetricMapping.new(review_metric_mapping_params)

    if @review_metric_mapping.save
      redirect_to @review_metric_mapping, notice: 'Review metric mapping was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /review_metric_mappings/1
  def update
    if @review_metric_mapping.update(review_metric_mapping_params)
      redirect_to @review_metric_mapping, notice: 'Review metric mapping was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /review_metric_mappings/1
  def destroy
    @review_metric_mapping.destroy
    redirect_to review_metric_mappings_url, notice: 'Review metric mapping was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_review_metric_mapping
    @review_metric_mapping = ReviewMetricMapping.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def review_metric_mapping_params
    params.require(:review_metric_mapping).permit(:metric_link, :response_link, :review_metrics_id, :responses_id, :value)
  end
end
