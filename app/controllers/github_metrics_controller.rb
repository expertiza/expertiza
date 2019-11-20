class GithubMetricsController < ApplicationController
  helper :file
  helper :submitted_content
  helper :penalty
  include PenaltyHelper
  include StudentTaskHelper
  include AssignmentHelper
  include GradesHelper
  include GithubMetricsHelper

  def view
    session["github_base"] = parse_hostname AssignmentParticipant.find(params[:id]).team.hyperlinks[0]
    session["github_tokens"] = nil
    if session["github_tokens"].nil?
      session["github_tokens"] = Hash.new
    end
    if session["github_tokens"][session["github_base"]].nil?
      session["participant_id"] = params[:id]
      session["github_view_type"] = "view_scores"
      session["github_view_type"] = "view_scores"
      return redirect_to authorize_github_github_metrics_path
    end
  end

  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator'].include? current_role_name
  end

  # Authorize to Expertiza to access github data.
  def authorize_github
    if session["github_base"] == "github.com"
      redirect_to "https://github.com/login/oauth/authorize?client_id=#{GITHUB_CONFIG['client_key']}"
    else
      redirect_to "https://#{session["github_base"]}/login/oauth/authorize?client_id=#{GITHUB_CONFIG['enterprise_client_key']}"
    end
  end

  # This function is used to show github_metrics information by redirecting to view.
  def view_github_metrics
    session["github_base"] = parse_hostname AssignmentParticipant.find(params[:id]).team.hyperlinks[0]
    #session["github_tokens"] = nil
    if session["github_tokens"].nil?
      session["github_tokens"] = Hash.new
    end
    if session["github_tokens"][session["github_base"]].nil?
      session["participant_id"] = params[:id]
      session["github_view_type"] = "view_submissions"
      redirect_to authorize_github_github_metrics_path
      return
    end

    # Variables to store github statistics
    @gitVariable = {
                     :head_refs => {},
                     :parsed_data => {},
                     :authors => {},
                     :dates => {},
                     :total_additions => 0,
                     :total_deletions => 0,
                     :total_commits => 0,
                     :total_files_changed => 0,
                     :merge_status => {},
                     :check_statuses => {},
                     :commits => []
    }

    #@token = session["github_access_token"]
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment
    @team = @participant.team
    @team_id = @team.id
    @submission = parse_hostname(@team.hyperlinks[0])

    retrieve_github_data
    retrieve_pull_request_statuses_data

    @gitVariable[:authors] = @gitVariable[:authors].keys
    @gitVariable[:dates] = @gitVariable[:dates].keys.sort
  end

  def parse_hostname(url)
    return URI.parse(url).host
  end

  # Retrieve github data from hyperlinks provided  by teams.
  # If the hyperlink is a pull request link, call auxiliary function "retrieve_pull_request_data" to get data.
  # If the hyperlink is a repository link, call auxiliary function "retrieve_repository_data" to get data.
  # After calling this function, all gtihub statistics will be generated and stored in corresponding variables.
  def retrieve_github_data
    team_links = @team.hyperlinks
    pull_links = team_links.select do |link|
      link.match(/pull/) && link.match(/github/)
    end
    if !pull_links.empty?
      retrieve_pull_request_data(pull_links)
    else
      repo_links = team_links.select do |link|
        link.match(/github/)
      end
      retrieve_repository_data(repo_links)
    end
  end

  # This function is used to get github statistics of a team. Statistics includes:
  # Pull request number
  # Total number of commits
  # Number of files changed
  # Number of files changed
  # Number of lines of code added
  # Number of lines of code removed
  # Number of lines of code changed
  # Merge statues
  def get_team_github_statistics(github_data)
    @gitVariable[:total_additions] += github_data["data"]["repository"]["pullRequest"]["additions"]
    @gitVariable[:total_deletions] += github_data["data"]["repository"]["pullRequest"]["deletions"]
    @gitVariable[:total_files_changed] += github_data["data"]["repository"]["pullRequest"]["changedFiles"]
    @gitVariable[:total_commits] += github_data["data"]["repository"]["pullRequest"]["commits"]["totalCount"]
    pull_request_number = github_data["data"]["repository"]["pullRequest"]["number"]

    @gitVariable[:merge_status][pull_request_number] = if github_data["data"]["repository"]["pullRequest"]["merged"]
                                                         "MERGED"
                                                       else
                                                         github_data["data"]["repository"]["pullRequest"]["mergeable"]
                                                       end
  end

  # This function is used to retrieve data for each pull requests status.
  def retrieve_pull_request_statuses_data
    @gitVariable[:head_refs].each do |pull_number, pr_object|
      @gitVariable[:check_statuses][pull_number] = get_statuses_for_pull_request(pr_object)
    end
  end

  # This function is used to get statuses of a pull request. This is an auxiliary function for "retrieve_pull_request_statuses_data"
  def get_statuses_for_pull_request(pr_object)
    url = "https://api.#{session["github_base"]}/repos/" + pr_object[:owner] + "/" + pr_object[:repository] + "/commits/" + pr_object[:head_commit] + "/status"
    ActiveSupport::JSON.decode(Net::HTTP.get(URI(url)))
  end

  # This function is used to retrieve github data from a pull request link.
  def retrieve_pull_request_data(pull_links)
    pull_links.each do |hyperlink|
      submission_hyperlink_tokens = hyperlink.split('/')
      hyperlink_data = {}
      hyperlink_data["pull_request_number"] = submission_hyperlink_tokens.pop
      submission_hyperlink_tokens.pop
      hyperlink_data["repository_name"] = submission_hyperlink_tokens.pop
      hyperlink_data["owner_name"] = submission_hyperlink_tokens.pop
      github_data = get_pull_request_details(hyperlink_data)
      @gitVariable[:head_refs][hyperlink_data["pull_request_number"]] = {
          head_commit: github_data["data"]["repository"]["pullRequest"]["headRefOid"],
          owner: hyperlink_data["owner_name"],
          repository: hyperlink_data["repository_name"]
      }
      parse_github_pull_request_data(github_data)
    end
  end

  # This function is used to retrieve github data from a repository link.
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

  # An auxiliary function for "retrieve_repository_data". It is used to get github data from repository links with the help of graphql.
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

  # An auxiliary function for "Retrieve_pull_request_data". It is used to get github data from a pull request link.
  def get_pull_request_details(hyperlink_data)
    @has_next_page = true
    @end_cursor = ""
    all_edges = []
    response_data = {}
    while @has_next_page
      response_data = make_github_graphql_request(get_query_for_pull_request_links(hyperlink_data))
      session["debugger"] = response_data
      current_commits = response_data["data"]["repository"]["pullRequest"]["commits"]
      current_page_info = current_commits["pageInfo"]
      all_edges.push(*current_commits["edges"])
      @has_next_page = current_page_info["hasNextPage"]
      @end_cursor = current_page_info["endCursor"]
    end

    response_data["data"]["repository"]["pullRequest"]["commits"]["edges"] = all_edges
    response_data
  end

  # An auxiliary function for "Retrieve pull request data". @github_data include data details obtained from "get_pull_request_details" function.
  # After calling this function, github statistic data could be extracted.
  def parse_github_pull_request_data(github_data)
    get_team_github_statistics(github_data)
    pull_request_object = github_data["data"]["repository"]["pullRequest"]
    commit_objects = pull_request_object["commits"]["edges"]
    commit_objects.each do |commit_object|
      commit = commit_object["node"]["commit"]
      @gitVariable[:commits].push(commit)
      #author_name = commit["author"]["name"]
      author_email = commit["author"]["email"]
      commit_date = commit["committedDate"].to_s
      process_github_authors_and_dates(author_email, commit_date[0, 10])
    end
    organize_commit_dates_in_sorted_order
  end

  # An auxiliary function for "retrieve_repository_data". @github_data include data details obtained from "get_repository_details" function.
  def parse_github_repository_data(github_data)
    commit_history = github_data["data"]["repository"]["ref"]["target"]["history"]
    commit_objects = commit_history["edges"]
    commit_objects.each do |commit_object|
      commit_author = commit_object["node"]["author"]
      author_name = commit_author["name"]
      commit_date = commit_author["date"].to_s
      process_github_authors_and_dates(author_name, commit_date[0, 10])
    end
    organize_commit_dates_in_sorted_order
  end

  # Make github graphql request
  def make_github_graphql_request(data)
    uri = URI.parse("https://api.#{session["github_base"]}/graphql")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    request = Net::HTTP::Post.new(uri.path, 'Authorization' => 'Bearer' + ' ' + session["github_tokens"][session["github_base"]])
    request.body = data.to_json
    http.request(request)
    response = http.request(request)
    ActiveSupport::JSON.decode(response.body.to_s)
  end

  # An auxiliary function for "get_pull_requests_details". This function is used to conduct query for details github commits data
  # using a pull request link.
  def get_query_for_pull_request_links(hyperlink_data)
    {


        query: <<~HEREDOC
        query {
          repository(owner: "#{hyperlink_data['owner_name']}", name:"#{hyperlink_data['repository_name']}") {
            pullRequest(number: #{hyperlink_data['pull_request_number']}) {
              number additions deletions changedFiles mergeable merged headRefOid
                commits(first:100, after:"#{@end_cursor}"){
                  totalCount
                    pageInfo{
                      hasNextPage startCursor endCursor
                      }
                      edges{
                        node{
                          id  commit{
                            author{
                                    name email
                                  }
                                  additions deletions changedFiles committedDate url
                            }}}}}}}
        HEREDOC
    }
  end

  # An auxiliary function to organize authors and their commit dates. Each author has a list of commit dates.
  def process_github_authors_and_dates(author_name, commit_date)
    @gitVariable[:authors][author_name] ||= 1
    @gitVariable[:dates][commit_date] ||= 1
    @gitVariable[:parsed_data][author_name] ||= {}
    @gitVariable[:parsed_data][author_name][commit_date] = if @gitVariable[:parsed_data][author_name][commit_date]
                                                             @gitVariable[:parsed_data][author_name][commit_date] + 1
                                                           else
                                                             1
                                                           end
  end

  # An auxiliary function. Sort commit dates for each author to make them in order.
  def organize_commit_dates_in_sorted_order
    @gitVariable[:dates].each_key do |date|
      @gitVariable[:parsed_data].each_value do |commits|
        commits[date] ||= 0
      end
    end
    @gitVariable[:parsed_data].each {|author, commits| @gitVariable[:parsed_data][author] = Hash[commits.sort_by {|date, _commit_count| date }] }
  end
end
