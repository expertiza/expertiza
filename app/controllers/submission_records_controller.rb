require 'net/http'
require 'json'

class SubmissionRecordsController < ApplicationController
  before_action :set_submission_record, only: %i[show edit update destroy]

  def action_allowed?
    # currently we only have a index method which shows all the submission records given a team_id
    assignment_team = AssignmentTeam.find(params[:team_id])
    assignment = Assignment.find(assignment_team.parent_id)
    return true if ['Super-Administrator', 'Administrator'].include? current_role_name
    return true if assignment.instructor_id == current_user.id
    return true if TaMapping.exists?(ta_id: current_user.id, course_id: assignment.course_id) && (TaMapping.where(course_id: assignment.course_id).include? TaMapping.where(ta_id: current_user.id, course_id: assignment.course_id).first)
    return true if assignment.course_id && Course.find(assignment.course_id).instructor_id == current_user.id
    false
  end

  BASE_URI = 'https://api.github.com'.freeze
  API_TOKEN = "token #{ENV['EXPERTIZA_GITHUB_TOKEN']}".freeze
  GITHUB_REGEX = %r(https?:\/\/(?:[w]{3}\.)?github\.com\/([A-Z0-9_\-]+)\/([A-Z0-9_\-]+)\/pull\/([0-9]+)[\S]*)i

  # Show submission records.
  # expects to get team_id from params
  def index
    @submission_records = SubmissionRecord.where(team_id: params[:team_id])
    @submission_records.each do |submission|
      content = retrieve_github_url(submission)
      unless content.nil?
        pull_data = fetch_pull_commits(content[0], content[1], content[2])
        puts "Total Commits: #{pull_data.length}" unless pull_data.nil?
        pull_data[0,3].each do |commit|
          commit_data = fetch_commit(content[0], content[1], commit['sha'])
          next if commit_data.nil?
          puts "Message: #{commit_data["commit"]["message"]}, "\
                "Committer: #{commit_data["committer"]['login']}, "\
                "Additions: #{commit_data["stats"]['additions']}, "\
                "Deletions: #{commit_data["stats"]['deletions']}, "\
                "Total files: #{commit_data["files"].length}"
        end unless pull_data.nil?
       end
    end
  end

  def fetch_commit(owner, repo, commit)
    fetch_from_github("#{BASE_URI}/repos/#{owner}/#{repo}/commits/#{commit}")

  end

  def fetch_pull_commits(owner, repo, pull_number)
    commits = []
    page = 1
    loop do
      commit = fetch_from_github("#{BASE_URI}/repos/#{owner}/#{repo}/pulls/#{pull_number}/commits?page=#{page}")
      break if commit.nil? or commit.empty?
      commits = commits + commit
      page+=1
      break if page>5
    end
    commits
  end

  def fetch_from_github(url)
    uri = URI(url)
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = API_TOKEN
    response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == "https") {|http|
      http.request(req)
    }
    puts "Remaining requests: #{response['x-ratelimit-remaining']}"
    #response.each_header {|key,value| puts "#{key} = #{value}" }
    JSON.parse(response.body) if response.code == "200"
  end

  def retrieve_github_url(submission)
    if submission.operation != 'Submit Hyperlink'
     return nil
    end
    matches = GITHUB_REGEX.match(submission.content)
    return nil if matches.nil?
    matches[1,3]
  end
end
