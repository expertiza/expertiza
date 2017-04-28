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

  # Upload file(s)
  def self.upload_files(assignment_submission_simicheck_id, team_id)
    # Setup file number (for unique files)
    filenumber = 1
    # Call method to parse text
    parsed_text = # TODO: David's parser
    # Set up filename structure: "teamID_000N.txt"
    filename = team_id + "_%04d.txt" % filenumber
    # Set up full filepath (in tmp dir)
    filepath = "tmp/" + filename
    # Create new file using parsed text
    File.open(filename, "w") { |file| file.write(parsed_text) }
    # Upload file to simicheck
    response = SimiCheckWebService.upload_file(assignment_submission_simicheck_id, filepath)
  end

  def self.start_plagiarism_checker(assignment_submission_simicheck_id, callback_url)
    response = SimiCheckWebService.post_similarity_nxn(assignment_submission_simicheck_id, callback_url)
  end

end