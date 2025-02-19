module PlagiarismCheckerHelper
  require 'simicheck_webservice'
  require 'submission_content_fetcher'

  # PlagiarismCheckerHelper acts as the integration point between all services and models
  # related to PlagiarismChecker

  def self.run(assignment_id)
    assignment = Assignment.find(assignment_id)
    teams = Team.where(parent_id: assignment_id)

    code_assignment_submission_id = create_new_assignment_submission(assignment.name + ' (Code)')
    doc_assignment_submission_id  = create_new_assignment_submission(assignment.name + ' (Doc)')

    teams.each do |team|
      file_number = 1

      team.hyperlinks do |url| # in assignment_team model
        fetcher = SubmissionContentFetcher.code_factory(url)
        id = code_assignment_submission_id

        unless fetcher
          fetcher = SubmissionContentFetcher.doc_factory(url)
          id = doc_assignment_submission_id
        end

        next unless fetcher

        content = fetcher.fetch_content
        upload_file(id, team.id, content, file_number) unless content.empty?
      end # each submission per team
    end # each team

    # Start comparison on code submission
    callback_url = request.protocol + request.host + '/plagiarism_checker_results/' + code_assignment_submission_id
    start_plagiarism_checker(code_assignment_submission_id, callback_url)
    # Start comparison on doc submission
    callback_url = request.protocol + request.host + '/plagiarism_checker_results/' + doc_assignment_submission_id
    start_plagiarism_checker(doc_assignment_submission_id, callback_url)
  end

  # Create a new PlagiarismCheckerAssignmentSubmission
  def self.create_new_assignment_submission(submission_name = '')
    # Start by creating a new assignment submission
    response = SimiCheckWebService.new_comparison(submission_name)
    json_response = JSON.parse(response.body)
    as_name = json_response['name']
    as_id = json_response['id']
    assignment_submission = PlagiarismCheckerAssignmentSubmission.new(name: as_name, simicheck_id: as_id)
    assignment_submission.save!
    as_id
  end

  # Upload file
  def self.upload_file(assignment_submission_simicheck_id, team_id, parsed_text, file_number)
    # Set up filename structure: "teamID_000N.txt"
    filename = 'team' + team_id.to_s + format('_%04d.txt', file_number)
    # Set up full filepath (in tmp dir)
    filepath = 'tmp/' + filename
    # Create new file using parsed text
    File.open(filepath, 'w') { |file| file.write(parsed_text) }
    # Upload file to simicheck
    SimiCheckWebService.upload_file(assignment_submission_simicheck_id, filepath)
    # Delete temporary file
    File.delete(filepath) if File.exist?(filepath)
  end

  def self.start_plagiarism_checker(assignment_submission_simicheck_id, callback_url)
    # callback_url = server.com/plagiarism_checker_results/<assignment_submission_simicheck_id>
    SimiCheckWebService.post_similarity_nxn(assignment_submission_simicheck_id, callback_url)
  end

  def self.store_results(assignment_submission_simicheck_id, threshold)
    response = SimiCheckWebService.get_similarity_nxn(assignment_submission_simicheck_id)
    json_response = JSON.parse(response.body)
    json_response['similarities'].each do |similarity|
      next unless similarity['similarity'] >= threshold

      # Similarity Percent
      percent_similar = similarity['similarity'].to_s
      # File 1 name
      f1_name = similarity['fn1']
      # File 2 name
      f2_name = similarity['fn2']
      # File 1 ID
      f1_id = similarity['fid1']
      # File 2 ID
      f2_id = similarity['fid2']
      # Team ID is embedded in the file name
      # Team 1 ID
      t1_id = f1_name.split('_').first.sub('team', '')
      # Team 2 ID
      t2_id = f2_name.split('_').first.sub('team', '')
      # Get similarity display link
      get_sim_link_response = SimiCheckWebService.visualize_comparison(assignment_submission_simicheck_id, f1_id, f2_id)
      sim_link = 'https://www.simicheck.com' + get_sim_link_response.body

      as_id = PlagiarismCheckerAssignmentSubmission.find_by(simicheck_id: assignment_submission_simicheck_id).id
      comparison = PlagiarismCheckerComparison.new(plagiarism_checker_assignment_submission_id: as_id,
                                                   similarity_link: sim_link,
                                                   similarity_percentage: percent_similar,
                                                   file1_name: f1_name,
                                                   file1_id: f1_id,
                                                   file1_team: t1_id,
                                                   file2_name: f2_name,
                                                   file2_id: f2_id,
                                                   file2_team: t2_id)
      comparison.save!
    end
  end
end
