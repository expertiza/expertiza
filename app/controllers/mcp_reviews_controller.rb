# app/controllers/mcp_reviews_controller.rb
class McpReviewsController < ApplicationController
  # You will likely want to lock this behind service-account auth.
  # skip_before_action :verify_authenticity_token # if API-only or using token auth

  def create
    # payload: { response_id: <id> } OR { response_id: <id>, extra_metadata: {...} }
    service = MCPReviewService.new
    mcp_response = service.send_peer_review(response_id: params[:response_id], extra_metadata: params[:extra_metadata] || {})
    render json: { success: true, mcp: mcp_response }, status: :accepted
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def show
    service = MCPReviewService.new
    mcp_review = service.get_llm_generated_score_and_feedback(params[:id])
    render json: { success: true, mcp: mcp_review }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :not_found
  end

  # POST /mcp_reviews/:id/finalize
  # body: { finalized_score: 85, finalized_feedback: "..." , target_model: "review_scores" }
  def finalize
    service = MCPReviewService.new
    target = (params[:target_model] || :review_scores).to_sym
    record = service.publish_or_finalize_grade(
      mcp_review_id: params[:id],
      finalized_score: params[:finalized_score],
      finalized_feedback: params[:finalized_feedback],
      target_model_sym: target
    )
    render json: { success: true, record: record }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
