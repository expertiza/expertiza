# app/controllers/mcp_reviews_controller.rb
# MCP API - requires logged-in user with TA/instructor/admin privileges. Cannot be called without authentication.
class McpReviewsController < ApplicationController
  include AuthorizationHelper
  before_action :require_api_auth, prepend: true
  protect_from_forgery with: :null_session

  def action_allowed?
    current_user_has_ta_privileges?
  end

  private

  def require_api_auth
    return if current_user

    render json: { error: 'Unauthorized. Login required to access this API.' }, status: :unauthorized
    false  # halt filter chain
  end

  # POST /mcp_reviews
# Send peer review to MCP server
# payload: { assignment_id: <id> }
  def create
    # payload: { assignment_id: <id> }
    service = MCPReviewService.new
    mcp_response = service.send_peer_review(assignment_id: params[:assignment_id])
    render json: { success: true, mcp: mcp_response }, status: :accepted
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # GET /mcp_reviews/:id
  # Returns the LLM-generated score and feedback for the given MCP review ID
  # The :id parameter is the MCP review ID
  def show
    service = MCPReviewService.new
    mcp_review = service.get_llm_generated_score_and_feedback(params[:id])
    render json: { success: true, mcp: mcp_review }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :not_found
  end

end
