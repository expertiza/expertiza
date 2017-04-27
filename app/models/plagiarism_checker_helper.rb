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

  def self.upload_files(assignment_submission_simicheck_id, team_name)
    filenumber = 1
    parsed_text = # TODO: David's parser
    filename = "%04d.txt" % filenumber
    filepath = "tmp/" + filename
    File.open(filename, "w") { |file| file.write(parsed_text) }
    response = SimiCheckWebService.upload_file(assignment_submission_simicheck_id, filepath)
    json_response = JSON.parse(response.body)
    file_id = json_response["id"]
    


    # response = SimiCheckWebService.upload_file(new_id, '/tmp/not_helloworld.txt')
    # puts response.code
    # json_response = JSON.parse(response.body)
    # not_helloworld_id = json_response["id"]
    # puts json_response["name"] + ' (' + json_response["id"] + ')'

  end

end