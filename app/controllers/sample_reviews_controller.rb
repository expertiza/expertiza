class SampleReviewsController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator',
     'Student'].include?(current_role_name) &&
      ((%w[list].include? action_name) ? are_needed_authorizations_present?(params[:id], 'submitter') : true)
  end

  def index
    @all_assignments = SampleReview.where(assignment_id: params[:id])
    @response_ids = []
    @all_assignments.each do |assignment|
      @response_ids << assignment.response_id
      @assignment = Assignment.find(assignment.assignment_id)
    end
    @links = generate_links(@response_ids)
  end

  def show
    @response_id = params[:id]
    unless @response_id.nil?
      @ques_answer = Answer.where(response_id: @response_id)
      @response = Response.find(@response_id)
      @map = @response.map

    end
  end

  def generate_links(response_ids)
    links = []
    response_ids.each do |id|
      links.append('/sample_reviews/show/' + id.to_s)
    end
    links
  end

  def map_to_assignment
    params[:assignments].each do |assignment_id|
      @sample_review = SampleReview.create(response_id: params[:id], assignment_id: assignment_id)
    end
    @response = Response.find(params[:id])
    begin
      @map = @response.map

      # Updating visibility for the response object, by E2022 @khotAyush -->
      visibility = 'published'
      @response.update_attribute('visibility', visibility)
    rescue StandardError
      flash[:warn] = 'StandardError updating response attribute in map_to_assignment'
    end

    respond_to do |format|
      flash[:notice] = 'Review Marked as Example'
      format.json { render json: @sample_review.id, status: :created }
    end
  end

  def unmap_from_assignment
    SampleReview.where(response_id: params[:id]).delete_all

    @response = Response.find(params[:id])
    begin
      @map = @response.map

      # Updating visibility for the response object, by E2022 @khotAyush -->
      visibility = 'public'
      @response.update_attribute('visibility', visibility)
    rescue StandardError
      flash[:warn] = 'StandardError updating response attribute in unmap_from_assignment'
    end

    respond_to do |format|
      flash[:notice] = 'Review Unmarked as Example'
      format.json { head :no_content }
    end
  end
end
