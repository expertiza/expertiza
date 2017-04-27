require 'simicheck_webservice'

class PlagiarismCheckerHelper

  # PlagiarismCheckerHelper acts as the integration point between all services and models
  # related to PlagiarismChecker

  # Create a new PlagiarismCheckerAssignmentSubmission
  def self.create_new_assignment_submission(submission_name = '')
    # Start by creating a new assignment submission
    response = SimiCheckWebService.new_comparison(submission_name)
    json_response = JSON.parse(response.body)
    as_name = json_response["name"]
    as_id = json_response["id"]
    assignment_submission = PlagiarismCheckerAssignmentSubmission.new(name: as_name, simicheck_id: as_id)
    assignment_submission.save!
  end

end