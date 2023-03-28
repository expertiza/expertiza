class MetricsController < ApplicationController
  before_action :require_instructor_privileges, only: [:action_allowed?]
  before_action :set_assignment, only: [:query_assignment_statistics, :show]

  # Runs a query against all the link submissions for all teams for an entire assignment,
  # populating the DB fields that are used by the view_team in grades heatgrid showing user contributions.
  # This method must also be run to enable "Github metrics" link on the list_assignments page.
  def query_assignment_statistics
    @assignment.teams.each do |team|
      topic_identifier, topic_name, users_for_curr_team, participants = get_data_for_list_submissions(team)
      single_submission_initial_query(participants.first.id) unless participants.first.nil?
    end
    redirect_to list_submissions_assignment_path(@assignment)
  end
  # Renders the view_github_metrics page, which displays detailed metrics for a single team of participants.
  # Shows two charts, a barchart timeline, and a piechart of total contributions by team member, as well as pull request
  # statistics if available
  def show
    single_submission_initial_query(params[:id])
  end
  # Authorizes with token to use GitHub API with 5000 rate limits.
  # Unauthorized user only has 60 limits, which is not enough.
  def authorize_github
    redirect_to "https://github.com/login/oauth/authorize?client_id=#{GITHUB_CONFIG['client_key']}"
  end

  private

  def require_instructor_privileges
    head :forbidden unless current_user_has_instructor_privileges?
  end

  def set_assignment
    @assignment = Assignment.find(params[:id])
  end

# Master query method that runs a query based on links contained within a single team's submission. Sets up instance
# variables, then passes control to retrieve_github_data to handle the logic for the individual links. Finally, store
# a small subset of data as Metrics in the metrics table containing participants, their total contribution,
# (in number of commits), their github email, and a reference to their User account (if mapping exists or can be determined)
def single_submission_initial_query(id)
  redirect_to_authorize_github_and_return if session['github_access_token'].nil?

  @participant = AssignmentParticipant.find(id)
  @team = @participant.team
  @team_id = @team.id
  @parsed_data, @dates = retrieve_github_data_and_dates
  @merge_status = query_all_merge_statuses
  @participants = get_data_for_list_submissions(@team)

  create_github_metrics
end

private
##################### Process Links and Branch according to Pull Request or Repo ############################
# For a single assignment team, process the submitted links, determine whether they are pull request links or
# repository links, and branch accordingly to query github for the data from the type of link found. The github API
# works differently and has different available data for pull requests and repositories.
def redirect_to_authorize_github_and_return
  session['participant_id'] = id
  session['assignment_id'] = @participant.assignment.id
  session['github_view_type'] = 'view_submissions'
  redirect_to controller: 'metrics', action: 'authorize_github'
end

def retrieve_github_data_and_dates
  parsed_data = Hash.new { |h, k| h[k] = Hash.new(0) }
  dates = Set.new
  total_additions = 0
  total_deletions = 0
  total_commits = 0
  total_files_changed = 0

  @token = session['github_access_token']
  retrieve_github_data

  parsed_data.each do |author, commit_data|
    unless LOCAL_ENV['COLLABORATORS'].include? author[1]
      commits = commit_data.values.sum
      create_github_metric(@team_id, author[1], commits)
    end
  end

  [parsed_data, dates.to_a.sort]
end

def create_github_metrics
  @parsed_data.each do |author, commit_data|
    unless LOCAL_ENV['COLLABORATORS'].include? author[1]
      commits = commit_data.values.sum
      create_github_metric(@team_id, author[1], commits)
    end
  end
end

def retrieve_github_data
  pull_links, repo_links = @team.hyperlinks.partition { |link| link.match(/pull/) && link.match(/github.com/) }

  if pull_links.any?
    query_all_pull_requests(pull_links)
  else
    retrieve_repository_data(repo_links)
  end
end

def query_all_pull_requests(pull_links)
  pull_links.each do |link|
    hyperlink_data = extract_hyperlink_data(link)
    @head_refs[hyperlink_data["pull_request_number"]] = {
      head_commit: pull_request_data(hyperlink_data).dig("data", "repository", "pullRequest", "headRefOid"),
      owner: hyperlink_data["owner_name"],
      repository: hyperlink_data["repository_name"]
    }
    parse_pull_request_data(hyperlink_data)
  end
end

def extract_hyperlink_data(link)
  link.split('/').slice(3, 4, 6).zip(["owner_name", "repository_name", "pull_request_number"]).to_h
end
# Iterate across pages of 100 commits queried from the Github API, getting the query from the Metric model, running
# the query, then calling the data parser
def pull_request_data(hyperlink_data)
  # 1.make the query message
  # 2.make the http request with the query
  # response_data is a ruby Hash class
  response_data = {}
  # every commits in this pull request and page info

  all_edges = []

  loop do
    query = Metric.pull_query(hyperlink_data, end_cursor)
    response_data = query_commit_statistics(query)

    current_commits = response_data.dig("data", "repository", "pullRequest", "commits")
    # page info for commits in this pull request, because too many commits may spread multiple pages

    current_page_info = current_commits&.dig("pageInfo")
    # push every node, which is a single commit, onto all_edges
    # every element in all_edges is a single commit in the pull request
    break if current_page_info.nil?

    all_edges.concat(current_commits["edges"])
    # page info used in query for next page

    has_next_page, end_cursor = current_page_info.values_at("hasNextPage", "endCursor")
  end
  # add every single commit into response_data hash and return it

  response_data.dig("data", "repository", "pullRequest", "commits")&.[]=("edges", all_edges)
  response_data
end
# Parse through data returned from  github API, strip unnecessary layers from hashes, and organize data
# into accessible hash for use elsewhere
def parse_pull_request_data(github_data)
  team_statistics(github_data, :pull)
  commit_objects = github_data.dig("data", "repository", "pullRequest", "commits", "edges") || []
  # loop through all commits and do the accounting

  commit_objects.each do |commit_object|
    commit = commit_object.dig("node", "commit")
    next if commit.nil?

    author_name = commit.dig("author", "name")
    author_email = commit.dig("author", "email")
    commit_date = commit.dig("committedDate")&.to_s&.slice(0, 10) # limit to the first 10 characters
    next if commit_date.nil?

    count_github_authors_and_dates(author_name, author_email, commit_date)
  end
  # sort author's commits based on dates

  sort_commit_dates
end
# iterate through each pull request, and query for the merge and other status information (Merged, rejected, conflicted)

def query_all_merge_statuses
  @head_refs.each do |pull_number, pr_object|
    @check_statuses[pull_number] = query_pull_request_status(pr_object)
  end
end
####################### Handling of Repository Links #########################
# Iterate through repository links, and for each link, iterate across pages of 100 commits (API Limit), calling corresponding
# methods to query the github API  for data on each page, then parse and process the data accordingly.
def retrieve_repository_data(repo_links)
  repo_links.each do |hyperlink|
    submission_hyperlink_tokens = hyperlink.split('/')
    repository_name = submission_hyperlink_tokens[4].delete_suffix('.git')
    owner_name = submission_hyperlink_tokens[3]
    query_data = { repository_name: repository_name, owner_name: owner_name }
    end_cursor = nil
    loop do
      query_text = Metric.repo_query(query_data, @assignment.created_at, end_cursor)
      github_data = query_commit_statistics(query_text)
      break if github_data.nil? || github_data['errors']
      # Process data returned by a respository query, stripping unecessary layers off of data hash, and organizing data for use
      # elsewhere in the app. Also calls accounting method for each commit, and sorting method to sort the data upon completion.
      # Finally,  calls team_statistics to parse the organized datasets and assemble key instance variables for the views.
      parse_repository_data(github_data)
      page_info = github_data.dig('data', 'repository', 'ref', 'target', 'history', 'pageInfo')
      break unless page_info&.fetch('hasNextPage', false)

      end_cursor = page_info['endCursor']
    end
  end
end

def parse_repository_data(github_data)
  commit_objects = github_data.dig("data", "repository", "ref", "target", "history", "edges")
  commit_objects.each do |commit_object|
    commit_author = commit_object.dig("node", "author")
    author_name = commit_author["name"]
    author_email = commit_author["email"]
    commit_date = commit_author["date"][0, 10]
    count_github_authors_and_dates(author_name, author_email, commit_date) unless LOCAL_ENV["COLLABORATORS"].include?(author_name)
  end
  sort_commit_dates
  team_statistics(github_data, :repo)
end
####################### Shared Math/Stats and Sorting Methods ################

# Traverse organized datasets and assemble key instance variables for the views. Handles differences in dataset between
# pull request queries and repository queries
def count_github_authors_and_dates(author_name, author_email, commit_date)
  return if LOCAL_ENV["COLLABORATORS"].include?(author_name)

  authors = @authors
  dates = @dates
  parsed_data = @parsed_data

  authors[author_name] ||= author_email
  dates[commit_date] ||= 1
  parsed_data[author_name] ||= Hash.new(0)
  parsed_data[author_name][commit_date] += 1
end

def sort_commit_dates
  dates = @dates
  parsed_data = @parsed_data
  total_commits = @total_commits

  parsed_data.each do |author, commits|
    commits.default = 0
    dates.each_key { |date| commits[date] ||= 0 }
    parsed_data[author] = commits.sort_by { |date, _commit_count| date }.to_h
    total_commits += commits.values.sum
  end
end

def team_statistics(github_data, data_type)
  if data_type == :pull
    pull_request = github_data.dig("data", "repository", "pullRequest")
    @total_additions += pull_request["additions"]
    @total_deletions += pull_request["deletions"]
    @total_files_changed += pull_request["changedFiles"]
    @total_commits += pull_request.dig("commits", "totalCount")
    pull_request_number = pull_request["number"]
    @merge_status[pull_request_number] = pull_request["merged"] ? "MERGED" : pull_request["mergeable"]
  else
    @total_additions = "Not Available"
    @total_deletions = "Not Available"
    @total_files_changed = "Not Available"
    pull_request_number = -1
    @merge_status[pull_request_number] = "Not A Pull Request"
  end
end
# do accounting, aggregate each authors' number of commits on each date
  def count_github_authors_and_dates(author_name, author_email, commit_date)
  # Only count a commit if it was not made by a member of the Expertiza development team
def parse_repository_data(github_data)
  commit_objects = github_data.dig("data", "repository", "ref", "target", "history", "edges")
  commit_objects.each do |commit_object|
    commit_author = commit_object.dig("node", "author")
    author_name = commit_author["name"]
    author_email = commit_author["email"]
    commit_date = commit_author["date"][0, 10]
    count_github_authors_and_dates(author_name, author_email, commit_date) unless LOCAL_ENV["COLLABORATORS"].include?(author_name)
  end
  sort_commit_dates
  team_statistics(github_data, :repo)
end
  end
def count_github_authors_and_dates(author_name, author_email, commit_date)
  return if LOCAL_ENV["COLLABORATORS"].include?(author_name)

  authors = @authors
  dates = @dates
  parsed_data = @parsed_data

  authors[author_name] ||= author_email
  dates[commit_date] ||= 1
  parsed_data[author_name] ||= Hash.new(0)
  parsed_data[author_name][commit_date] += 1
end
  # sort each author's commits based on date

def sort_commit_dates
  dates = @dates
  parsed_data = @parsed_data
  total_commits = @total_commits

  parsed_data.each do |author, commits|
    commits.default = 0
    dates.each_key { |date| commits[date] ||= 0 }
    parsed_data[author] = commits.sort_by { |date, _commit_count| date }.to_h
    total_commits += commits.values.sum
  end
end

  ######################## HTTP Query Execution #########################

  # make the actual github api request with graphql and query message.
  # data: the query message made in get_query method. Documented in detail in get_query method
def team_statistics(github_data, data_type)
  if data_type == :pull
    pull_request = github_data.dig("data", "repository", "pullRequest")
    @total_additions += pull_request["additions"]
    @total_deletions += pull_request["deletions"]
    @total_files_changed += pull_request["changedFiles"]
    @total_commits += pull_request.dig("commits", "totalCount")
    pull_request_number = pull_request["number"]
    @merge_status[pull_request_number] = pull_request["merged"] ? "MERGED" : pull_request["mergeable"]
  else
    @total_additions = "Not Available"
    @total_deletions = "Not Available"
    @total_files_changed = "Not Available"
    pull_request_number = -1
    @merge_status[pull_request_number] = "Not A Pull Request"
  end
end
  # Handle the create action for a github metric, which stores a datapoint mapping a team id, and a github email address
  # to an expertiza User, with a datapoint for their total contributions to the project. Users are asked to create the
  # mapping from their Github email within their user profile, but we also try to intelligently determine that mapping if
  # the user has not provided an email, and their profile contains enough clues.
def create_github_metric(team_id, github_id, total_commits)
  metric = Metric.find_by(team_id: team_id, github_id: github_id)
  user = User.find_by_github_id(github_id)

  # If user mapping does not exist, attempt to find the user by their email
  if user.nil?
    email = github_id.split('@')
    if email[1] == 'ncsu.edu'
      user = User.find_by_email(github_id)
      # If user found by email, save this mapping for future queries
      user.update(github_id: github_id) unless user.nil?
    else # Try mapping from unityID@any_email_provider.com or unityID@anotherprovider.com
      user = User.find_by_email("#{email[0]}@ncsu.edu")
      # If user found by email, save this mapping for future queries
      user.update(github_id: github_id) unless user.nil?
    end
  end

  participant_id = user&.id # Use the user ID to set the participant ID to be stored in the metrics table

  # If a record already exists for this user and assignment, update it. Otherwise, create a new record
  if metric.present?
    metric.update(total_commits: total_commits, participant_id: participant_id)
  else
    Metric.create(metric_source_id: MetricSource.find_by_name("Github").id,
                  team_id: team_id,
                  github_id: github_id,
                  participant_id: participant_id,
                  total_commits: total_commits)
    end
  end
end

