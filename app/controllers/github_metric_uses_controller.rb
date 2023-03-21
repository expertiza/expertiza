class GithubMetricUsesController < ApplicationController

  skip_before_action :authorize
  helper_method :exist

  #check if assignment_id exists in the table github_metric_uses
  def self.exist(assignment_id)
    github_use = GithubMetricUses.find_by(assignment_id: assignment_id)
    !github_use.nil?
  end

  #if assignment_id does not exist in the table github_metric_uses, save it
  def self.save(assignment_id)
    unless exist(assignment_id)
      github_use = GithubMetricUses.new(assignment_id)
      github_use.assignment_id = assignment_id
      github_use.save
    end
  end

  #if assignment_id exists in the table github_metric_uses, delete it
  def self.delete(assignment_id)
    if exist(assignment_id)
      github_use = GithubMetricUses.find_by(assignment_id: assignment_id)
      github_use.destroy
    end
  end

  #check if assignment_id exists in the table github_metric_uses
  def exist
    assignment_id = params[:assignment_id]
    GithubMetricUsesController.exist(assignment_id)
  end

  #if assignment_id does not exist in the table github_metric_uses, save it
  def save
    assignment_id = params[:assignment_id]
    GithubMetricUsesController.save(assignment_id)
    respond_to do |format|
      format.json { render json: assignment_id }
    end
  end

  #if assignment_id exists in the table github_metric_uses, delete it
  def delete
    assignment_id = params[:assignment_id]
    GithubMetricUsesController.delete(assignment_id)
    respond_to do |format|
      format.json { render json: assignment_id }
    end
  end

end
