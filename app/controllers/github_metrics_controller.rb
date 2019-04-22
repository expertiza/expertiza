class GithubMetricsController < ApplicationController
  helper :file
  helper :submitted_content
  helper :penalty
  include PenaltyHelper
  include StudentTaskHelper
  include AssignmentHelper
  include GradesHelper

  def action_allowed?
    case params[:action]
    when 'view_my_scores'
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator',
       'Student'].include? current_role_name and
          are_needed_authorizations_present?(params[:id], "reader", "reviewer") and
          check_self_review_status
    when 'view_team'
      if ['Student'].include? current_role_name # students can only see the head map for their own team
        participant = AssignmentParticipant.find(params[:id])
        session[:user].id == participant.user_id
      else
        true
      end
    else
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator'].include? current_role_name
    end
  end

  def retrieve_pull_request_data(pull_links)
    pull_links.each do |hyperlink|
      submission_hyperlink_tokens = hyperlink.split('/')
      hyperlink_data = {}
      hyperlink_data["pull_request_number"] = submission_hyperlink_tokens.pop
      submission_hyperlink_tokens.pop
      hyperlink_data["repository_name"] = submission_hyperlink_tokens.pop
      hyperlink_data["owner_name"] = submission_hyperlink_tokens.pop
      github_data = get_pull_request_details(hyperlink_data)
      @head_refs[hyperlink_data["pull_request_number"]] = {
          head_commit: github_data["data"]["repository"]["pullRequest"]["headRefOid"],
          owner: hyperlink_data["owner_name"],
          repository: hyperlink_data["repository_name"]
      }
      parse_github_pull_request_data(github_data)
    end
  end

  def retrieve_repository_data(repo_links)
    repo_links.each do |hyperlink|
      submission_hyperlink_tokens = hyperlink.split('/')
      hyperlink_data = {}
      hyperlink_data["repository_name"] = submission_hyperlink_tokens[4]
      next if hyperlink_data["repository_name"] == "servo" || hyperlink_data["repository_name"] == "expertiza"
      hyperlink_data["owner_name"] = submission_hyperlink_tokens[3]
      github_data = get_github_repository_details(hyperlink_data)
      parse_github_repository_data(github_data)
    end
  end

  def retrieve_github_data
    team_links = @team.hyperlinks
    pull_links = team_links.select do |link|
      link.match(/pull/) && link.match(/github.com/)
    end
    if !pull_links.empty?
      retrieve_pull_request_data(pull_links)
    else
      repo_links = team_links.select do |link|
        link.match(/github.com/)
      end
      retrieve_repository_data(repo_links)
    end
  end

  def get_statuses_for_pull_request(pr_object)
    url = "https://api.github.com/repos/" + pr_object[:owner] + "/" + pr_object[:repository] + "/commits/" + pr_object[:head_commit] + "/status"
    ActiveSupport::JSON.decode(Net::HTTP.get(URI(url)))
  end

  def retrieve_check_run_statuses
    @head_refs.each do |pull_number, pr_object|
      @check_statuses[pull_number] = get_statuses_for_pull_request(pr_object)
    end
  end

  def view_github_metrics
    if session["github_access_token"].nil?
      session["participant_id"] = params[:id]
      session["github_view_type"] = "view_submissions"
      redirect_to authorize_github_grades_path
      return
    end

    @head_refs = {}
    @parsed_data = {}
    @authors = {}
    @dates = {}
    @total_additions = 0
    @total_deletions = 0
    @total_commits = 0
    @total_files_changed = 0
    @merge_status = {}
    @check_statuses = {}

    @token = session["github_access_token"]

    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment
    @team = @participant.team
    @team_id = @team.id

    retrieve_github_data
    retrieve_check_run_statuses

    @authors = @authors.keys
    @dates = @dates.keys.sort
  end

  def authorize_github
    redirect_to "https://github.com/login/oauth/authorize?client_id=#{GITHUB_CONFIG['client_key']}"
  end

  def get_github_repository_details(hyperlink_data)
    data = {
        query: "query {
        repository(owner: \"" + hyperlink_data["owner_name"] + "\", name: \"" + hyperlink_data["repository_name"] + "\") {
          ref(qualifiedName: \"master\") {
            target {
              ... on Commit {
                id
                  history(first: 100) {
                    edges {
                      node {
                        id author {
                          name email date
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }"
    }
    make_github_graphql_request(data)
  end

  def get_pull_request_details(hyperlink_data)
    @has_next_page = true
    @end_cursor = ""
    all_edges = []
    response_data = {}
    while @has_next_page
      response_data = make_github_graphql_request(get_query(hyperlink_data))
      current_commits = response_data["data"]["repository"]["pullRequest"]["commits"]
      current_page_info = current_commits["pageInfo"]
      all_edges.push(*current_commits["edges"])
      @has_next_page = current_page_info["hasNextPage"]
      @end_cursor = current_page_info["endCursor"]
    end

    response_data["data"]["repository"]["pullRequest"]["commits"]["edges"] = all_edges
    response_data
  end

  def process_github_authors_and_dates(author_name, commit_date)
    @authors[author_name] ||= 1
    @dates[commit_date] ||= 1
    @parsed_data[author_name] ||= {}
    @parsed_data[author_name][commit_date] = if @parsed_data[author_name][commit_date]
                                               @parsed_data[author_name][commit_date] + 1
                                             else
                                               1
                                             end
  end

  def parse_github_pull_request_data(github_data)
    team_statistics(github_data)
    pull_request_object = github_data["data"]["repository"]["pullRequest"]
    commit_objects = pull_request_object["commits"]["edges"]
    commit_objects.each do |commit_object|
      commit = commit_object["node"]["commit"]
      author_name = commit["author"]["name"]
      commit_date = commit["committedDate"].to_s
      process_github_authors_and_dates(author_name, commit_date[0, 10])
    end
    organize_commit_dates
  end

  def parse_github_repository_data(github_data)
    commit_history = github_data["data"]["repository"]["ref"]["target"]["history"]
    commit_objects = commit_history["edges"]
    commit_objects.each do |commit_object|
      commit_author = commit_object["node"]["author"]
      author_name = commit_author["name"]
      commit_date = commit_author["date"].to_s
      process_github_authors_and_dates(author_name, commit_date[0, 10])
    end
    organize_commit_dates
  end

  def make_github_graphql_request(data)
    uri = URI.parse("https://api.github.com/graphql")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    request = Net::HTTP::Post.new(uri.path, 'Authorization' => 'Bearer' + ' ' + session["github_access_token"])
    request.body = data.to_json
    http.request(request)
    response = http.request(request)
    ActiveSupport::JSON.decode(response.body.to_s)
  end

  def organize_commit_dates
    @dates.each_key do |date|
      @parsed_data.each_value do |commits|
        commits[date] ||= 0
      end
    end
    @parsed_data.each {|author, commits| @parsed_data[author] = Hash[commits.sort_by {|date, _commit_count| date }] }
  end

  def team_statistics(github_data)
    @total_additions += github_data["data"]["repository"]["pullRequest"]["additions"]
    @total_deletions += github_data["data"]["repository"]["pullRequest"]["deletions"]
    @total_files_changed += github_data["data"]["repository"]["pullRequest"]["changedFiles"]
    @total_commits += github_data["data"]["repository"]["pullRequest"]["commits"]["totalCount"]
    pull_request_number = github_data["data"]["repository"]["pullRequest"]["number"]

    @merge_status[pull_request_number] = if github_data["data"]["repository"]["pullRequest"]["merged"]
                                           "MERGED"
                                         else
                                           github_data["data"]["repository"]["pullRequest"]["mergeable"]
                                         end
  end

  def get_query(hyperlink_data)
    {
        query: "query {
        repository(owner: \"" + hyperlink_data["owner_name"] + "\", name:\"" + hyperlink_data["repository_name"] + "\") {
          pullRequest(number: " + hyperlink_data["pull_request_number"] + ") {
            number additions deletions changedFiles mergeable merged headRefOid
              commits(first:100, after:" + @end_cursor + "){
                totalCount
                  pageInfo{
                    hasNextPage startCursor endCursor
                    }
                      edges{
                        node{
                          id  commit{
                                author{
                                  name
                                }
                               additions deletions changedFiles committedDate
                        }}}}}}}"
    }
  end
end
