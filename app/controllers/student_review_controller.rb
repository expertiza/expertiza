require 'octokit' # Use this gem with Github API operations
require 'uri'

class StudentReviewController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator',
     'Student'].include? current_role_name and
    ((%w(list).include? action_name) ? are_needed_authorizations_present?(params[:id], "submitter") : true)
  end

  def list
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)
    @assignment = @participant.assignment
    # Find the current phase that the assignment is in.
    @topic_id = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id)
    @review_phase = @assignment.get_current_stage(@topic_id)
    # ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments

    @review_mappings = ReviewResponseMap.where(reviewer_id: @participant.id)
    # if it is an calibrated assignment, change the response_map order in a certain way
    @review_mappings = @review_mappings.sort_by {|mapping| mapping.id % 5 } if @assignment.is_calibrated == true
    @metareview_mappings = MetareviewResponseMap.where(reviewer_id: @participant.id)
    # Calculate the number of reviews that the user has completed so far.

    @num_reviews_total = @review_mappings.size
    # Add the reviews which are requested and not began.
    @num_reviews_completed = 0
    @review_mappings.each do |map|
      @num_reviews_completed += 1 if !map.response.empty? && map.response.last.is_submitted
    end

    @num_reviews_in_progress = @num_reviews_total - @num_reviews_completed
    # Calculate the number of metareviews that the user has completed so far.
    @num_metareviews_total       = @metareview_mappings.size
    @num_metareviews_completed   = 0
    @metareview_mappings.each do |map|
      @num_metareviews_completed += 1 unless map.response.empty?
    end
    @num_metareviews_in_progress = @num_metareviews_total - @num_metareviews_completed
    @topic_id = SignedUpTeam.topic_id(@assignment.id, @participant.user_id)
  end

  def get_update_time(response)
    @response = response
    @last_review_time = response.updated_at
    @team = @response.map.contributor
    # @participant_of_response = AssignmentParticipant.find(participant_of_response.id)
    # @team = @participant_of_response.team

    update_times = {submission: nil, link_to_content: nil}
    update_times[:submission] = @latest_submisstion_time if submission_updated?
    update_times[:link_to_content] = @link_to_content_update_time if link_to_content_updated?
    update_times
    # @update_time = update_times.sort.last
  end

  def submission_updated?
    @submisstion_records = SubmissionRecord.where(@team.id)
    @latest_submisstion_time = nil

    record_times = []
    @submisstion_records.each do |record|
      record_times << record.created_at
    end
    @latest_submisstion_time = record_times.sort.last
    (@latest_submisstion_time <=> @last_review_time) == 1
  end

  def link_to_content_updated?
    @hyperlinks = @team.hyperlinks
    @link_to_content_update_time = nil

    update_times = []
    @hyperlinks.each do |link|
      time = get_link_update_time(link)
      update_times << time unless time.nil?
    end

    @link_to_content_update_time = update_times.sort.last
    (@link_to_content_update_time <=> @last_review_time) == 1
  end

  def get_link_update_time(submitted_link)
    # check validity of link
    url = submitted_link.slice(URI.regexp)
    return nil if url.nil?

    # recognize url type
    parsed_url = URI(url)

    case parsed_url.host
    when /^github(.*)/ # url is a GitHub link
      get_latest_commit_time(parsed_url)
    end
  end

  def get_latest_commit_time(github_url)
    client = Octokit::Client.new

    case github_url.host
    when 'github.ncsu.edu'
      client.access_token = '8289b47fe8db5c8bceb2f84b2e0c56fc31c5d9e5'
      client.api_endpoint = 'https://github.ncsu.edu/api/v3'
    end

    begin
      path = github_url.path.split('/')
      repo = path[1] + '/' + path[2]
      repo.slice!('.git')
      res = client.commit(repo, 'master')
      latest_commit = res.to_h
      latest_commit[:commit][:author][:date]
    rescue
      nil
    end
  end

  def file_updated? # this function hasn't been implemented
    @file_update_time = nil
    false
  end

  helper_method :get_update_time
end
