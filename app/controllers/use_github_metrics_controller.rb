class UseGithubMetricsController < ApplicationController

  skip_before_action :authorize
  helper_method :exist

  def self.exist(assignment_id)
    @u = UseGithubMetric.find_by(assignment_id: assignment_id)
    !@u.nil?
  end

  def self.save(assignment_id)
    unless exist(assignment_id)
      @u = UseGithubMetric.new(assignment_id)
      @u.assignment_id = assignment_id
      @u.save
    end
  end

  def self.delete(assignment_id)
    if exist(assignment_id)
      @u = UseGithubMetric.find_by(assignment_id: assignment_id)
      @u.destroy
    end
  end

  def exist
    @assignment_id = params[:assignment_id]
    UseGithubMetricsController.exist(@assignment_id)
  end

  def save
    @assignment_id = params[:assignment_id]
    UseGithubMetricsController.save(@assignment_id)
    respond_to do |format|
      format.json { render json: @assignment_id }
    end
  end

  def delete
    @assignment_id = params[:assignment_id]
    UseGithubMetricsController.delete(@assignment_id)
    respond_to do |format|
      format.json { render json: @assignment_id }
    end
  end

end
