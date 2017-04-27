class PlagiarismCheckerHelper

  # PlagiarismCheckerHelper acts as the integration point between all services and models
  # related to PlagiarismChecker

  # Returns ID of new submission?
  def self.create_new_assignment_submission(submission_name = '')
    response = SimiCheckWebService.new_comparison(submission_name)
    json_response = JSON.parse(response.body)
    return json_response["id"]
  end

end