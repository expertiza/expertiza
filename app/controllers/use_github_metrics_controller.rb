class UseGithubMetricsController < ApplicationController
  before_action :set_use_github_metric, only: [:show, :edit, :update, :destroy]

  # GET /use_github_metrics
  def index
    @use_github_metrics = UseGithubMetric.all
  end

  def exist(assignment_id)
    u = UseGithubMetric.find_by(id: assignment_id)
    !u.nil?
  end

  def save(assignment_id)
    unless exist(assignment_id)
      u = UseGithubMetric.new(assignment_id)
      u.save
    end
  end

  def delete(assignment_id)
    if exist(assignment_id)
      UseGithubMetric.delete(id: assignment_id)
    end
  end

  # GET /use_github_metrics/1
  def show
  end

  # GET /use_github_metrics/new
  def new
    @use_github_metric = UseGithubMetric.new
  end

  # GET /use_github_metrics/1/edit
  def edit
  end

  # POST /use_github_metrics
  def create
    @use_github_metric = UseGithubMetric.new(use_github_metric_params)

    if @use_github_metric.save
      redirect_to @use_github_metric, notice: 'Use github metric was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /use_github_metrics/1
  def update
    if @use_github_metric.update(use_github_metric_params)
      redirect_to @use_github_metric, notice: 'Use github metric was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /use_github_metrics/1
  def destroy
    @use_github_metric.destroy
    redirect_to use_github_metrics_url, notice: 'Use github metric was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_use_github_metric
      @use_github_metric = UseGithubMetric.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def use_github_metric_params
      params.require(:use_github_metric).permit(:id)
    end
end
