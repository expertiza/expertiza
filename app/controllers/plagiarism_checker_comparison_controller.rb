class PlagiarismCheckerComparisonController < ApplicationController
  def index
    plagiarism_checker_assignment_submission_id = session[:plagiarism_checker_assignment_submission_id]
    @PlagiarismCheckerComparisons = PlagiarismCheckerComparison.where(plagiarism_checker_assignment_submission_id: plagiarism_checker_assignment_submission_id)
  end
end