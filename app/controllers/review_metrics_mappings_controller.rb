class ReviewMetricsMappingsController < ApplicationController
  before_action :set_review_metrics_mapping, only: [:show, :edit, :update, :destroy]

  # GET /review_metrics_mappings
  def index
    @review_metrics_mappings = ReviewMetricsMapping.all
  end

  # GET /review_metrics_mappings/1
  def show; end

  # GET /review_metrics_mappings/new
  def new
    @review_metrics_mapping = ReviewMetricsMapping.new
  end

  # GET /review_metrics_mappings/1/edit
  def edit; end

  # POST /review_metrics_mappings
  def create
    @review_metrics_mapping = ReviewMetricsMapping.new(review_metrics_mapping_params)

    if @review_metrics_mapping.save
      redirect_to @review_metrics_mapping, notice: 'Review metrics mapping was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /review_metrics_mappings/1
  def update
    if @review_metrics_mapping.update(review_metrics_mapping_params)
      redirect_to @review_metrics_mapping, notice: 'Review metrics mapping was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /review_metrics_mappings/1
  def destroy
    @review_metrics_mapping.destroy
    redirect_to review_metrics_mappings_url, notice: 'Review metrics mapping was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_review_metrics_mapping
    @review_metrics_mapping = ReviewMetricsMapping.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def review_metrics_mapping_params
    params.require(:review_metrics_mapping).permit(:response, :metric, :value)
  end
end
