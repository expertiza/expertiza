class GithubMetricUsesController < ApplicationController
  skip_before_action :authorize
  
  # Check if a record with the given assignment_id exists in the GithubMetricUses table
  def record_exists?
    assignment_id = params[:assignment_id]
    github_use = GithubMetricUses.find_by(assignment_id: assignment_id)
    render json: !github_use.nil?
  end

  # Save a new record with the given assignment_id to the GithubMetricUses table
  # if a record with the same assignment_id doesn't already exist
  def save
    assignment_id = params[:assignment_id]
    github_use = GithubMetricUses.find_or_create_by(assignment_id: assignment_id)
    render json: assignment_id
  end

  # Delete the record with the given assignment_id from the GithubMetricUses table
  # if it exists
  def delete
    assignment_id = params[:assignment_id]
    github_use = GithubMetricUses.find_by(assignment_id: assignment_id)
    github_use&.destroy
    render json: assignment_id
  end
end