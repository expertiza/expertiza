class UseGithubMetricsController < ApplicationController

  skip_before_action :authorize
  helper_method :exist

  #check if assignment_id exists in the table use_github_metrics
  def self.exist(assignment_id)
    use_github = UseGithubMetric.find_by(assignment_id: assignment_id)
    !use_github.nil?
  end

  #if assignment_id does not exist in the table use_github_metrics, save it
  def self.save(assignment_id)
    unless exist(assignment_id)
      use_github = UseGithubMetric.new(assignment_id)
      use_github.assignment_id = assignment_id
      use_github.save
    end
  end

  #if assignment_id exists in the table use_github_metrics, delete it
  def self.delete(assignment_id)
    if exist(assignment_id)
      use_github = UseGithubMetric.find_by(assignment_id: assignment_id)
      use_github.destroy
    end
  end

  #check if assignment_id exists in the table use_github_metrics
  def exist
    assignment_id = params[:assignment_id]
    UseGithubMetricsController.exist(assignment_id)
  end

  #if assignment_id does not exist in the table use_github_metrics, save it
  def save
    assignment_id = params[:assignment_id]
    UseGithubMetricsController.save(assignment_id)
    respond_to do |format|
      format.json { render json: assignment_id }
    end
  end

  #if assignment_id exists in the table use_github_metrics, delete it
  def delete
    assignment_id = params[:assignment_id]
    UseGithubMetricsController.delete(assignment_id)
    respond_to do |format|
      format.json { render json: assignment_id }
    end
  end

end
