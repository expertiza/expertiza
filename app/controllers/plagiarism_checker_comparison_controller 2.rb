class PlagiarismCheckerComparisonController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:save_results]
  skip_before_action :authorize, only: [:save_results]

  def index; end

  def save_results
    assignment_submission_id = params[:id]
    threshold = Assignment.find(params[:id]).simicheck_threshold
    PlagiarismCheckerHelper.store_results(assignment_submission_id, threshold)
    render nothing: true
  end
end
