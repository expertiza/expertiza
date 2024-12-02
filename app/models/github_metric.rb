# Handles retrieval and processing of GitHub metrics for team submissions
class GithubMetric
  attr_reader :participant, :assignment, :team, :token
  attr_accessor :head_refs, :parsed_metrics, :authors, :dates, :total_additions,
                :total_deletions, :total_commits, :total_files_changed,
                :merge_status, :check_statuses

  # Initializes a new GithubMetric instance with participant and assignment context
  # @param participant_id [Integer] ID of the assignment participant
  # @param assignment_id [Integer] ID of the assignment (optional if participant exists)
  # @param token [String] GitHub access token for API authentication
  def initialize(participant_id, assignment_id = nil, token = nil)
    @participant = AssignmentParticipant.find(participant_id)
    @assignment = assignment_id ? Assignment.find(assignment_id) : @participant.assignment
    @team = @participant.team
    @token = token
    initialize_metrics
  end

  # Main method to process all metrics for a team's GitHub submissions
  # @return [GithubMetric] Returns self after processing
  # @raise [StandardError] if GitHub token is missing
  def process_metrics
    return handle_missing_token unless @token
    retrieve_metrics
    query_all_merge_statuses
    self
  end

  # Formats the GraphQL query for pull request data
  # @param hyperlink_metrics [Hash] Contains owner, repository, and PR number information
  # @return [String] Formatted GraphQL query
  def pull_query(hyperlink_metrics)
    format(PULL_REQUEST_QUERY, {
      owner_name: hyperlink_metrics["owner_name"],
      repository_name: hyperlink_metrics["repository_name"],
      pull_request_number: hyperlink_metrics["pull_request_number"],
      after_clause: nil
    })
  end

  private

  # Initializes all metric tracking variables to their default values
  def initialize_metrics
    @head_refs = {}
    @parsed_metrics = {}
    @authors = {}
    @dates = {}
    @total_additions = 0
    @total_deletions = 0
    @total_commits = 0
    @total_files_changed = 0
    @merge_status = {}
    @check_statuses = {}
  end

  # Retrieves metrics from all pull request links submitted by the team
  # @raise [StandardError] if no pull request links are found
  def retrieve_metrics
    team_links = @team.hyperlinks
    pull_links = team_links.select { |link| link.match(/pull/) && link.match(/github.com/) }
    if pull_links.empty?
      raise StandardError, 'No pull request links have been submitted by this team.'
    end
    
    parse_all_pull_requests(pull_links)
  end

  # Processes each pull request link to gather metrics
  # @param pull_links [Array<String>] Array of pull request URLs
  def parse_all_pull_requests(pull_links)
    pull_links.each do |hyperlink|
      hyperlink_metrics = parse_hyperlink_metrics(hyperlink)
      github_metrics = retrieve_pull_request_metrics(hyperlink_metrics)
  
      @head_refs[hyperlink_metrics["pull_request_number"]] = {
        head_commit: github_metrics["data"]["repository"]["pullRequest"]["headRefOid"],
        owner: hyperlink_metrics["owner_name"],
        repository: hyperlink_metrics["repository_name"]
      }
      parse_pull_request_metrics(github_metrics)
    end
  end

  # Retrieves all commit data for a pull request, handling pagination
  # @param hyperlink_metrics [Hash] Pull request identification information
  # @return [Hash] Complete pull request data including all commits
  def retrieve_pull_request_metrics(hyperlink_metrics)
    has_next_page = true
    end_cursor = nil
    all_edges = []
    response_metrics = {}

    while has_next_page
      response_metrics = query_commit_statistics(pull_query(hyperlink_metrics))
      current_commits = response_metrics["data"]["repository"]["pullRequest"]["commits"]
      current_page_info = current_commits["pageInfo"]
      
      all_edges.push(*current_commits["edges"])
      
      has_next_page = current_page_info["hasNextPage"]
      end_cursor = current_page_info["endCursor"]
    end

    response_metrics["data"]["repository"]["pullRequest"]["commits"]["edges"] = all_edges
    response_metrics
  end

  # Parses and aggregates metrics from pull request data
  # @param github_metrics [Hash] Raw pull request data from GitHub API
  def parse_pull_request_metrics(github_metrics)
    team_statistics(github_metrics, :pull)
    commit_objects = github_metrics.dig("data", "repository", "pullRequest", "commits", "edges")
    commit_objects.each do |commit_object|
      commit = commit_object.dig("node", "commit")
      author_name = commit.dig("author", "name")
      # It is possible that a commit does not have a github username associated with it
      # in which case commit.dig("author", "user") is nil and will cause an error when it
      # looks for the ["login"] field
      author_login = commit.dig("author", "user").nil? ? commit.dig("author", "user") : commit.dig("author", "user")["login"]
      author_email = commit.dig("author", "email")
      commit_date = commit.dig("committedDate").to_s[0, 10]

      count_authors_and_dates(author_name, author_email, author_login, commit_date)
    end
    sort_commit_dates
  end

  # Queries status checks for all pull requests
  def query_all_merge_statuses
    @head_refs.each do |pull_number, pr_object|
      @check_statuses[pull_number] = query_pull_request_status(pr_object)
    end
  end

  # Updates metrics tracking for commit authors and dates
  # @param author_name [String] Name of commit author
  # @param author_email [String] Email of commit author
  # @param author_login [String] GitHub username of author
  # @param commit_date [String] Date of commit
  def count_authors_and_dates(author_name, author_email, author_login, commit_date)
    @authors[author_name] ||= author_login
    @dates[commit_date] ||= 1
    @parsed_metrics[author_name] ||= Hash.new(0)
    @parsed_metrics[author_name][commit_date] += 1
  end

  # Executes GraphQL query against GitHub API
  # @param metrics [String] GraphQL query string
  # @return [Hash] Parsed JSON response from GitHub
  def query_commit_statistics(metrics)
    uri = URI.parse("https://api.github.com/graphql")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  
    request = Net::HTTP::Post.new(
      uri.path,
      {
        'Authorization' => "Bearer #{@token}",
        'Content-Type' => 'application/json'
      }
    )
  
    request.body = { query: metrics }.to_json
    response = http.request(request)
    ActiveSupport::JSON.decode(response.body.to_s)
  end

  # Queries GitHub API for pull request status checks
  # @param pr_object [Hash] Pull request identification information
  # @return [Hash] Status check results
  def query_pull_request_status(pr_object)
    url = "https://api.github.com/repos/#{pr_object[:owner]}/#{pr_object[:repository]}/commits/#{pr_object[:head_commit]}/status"
    ActiveSupport::JSON.decode(Net::HTTP.get(URI(url)))
  end

  # Updates team-level statistics from pull request data
  # @param github_metrics [Hash] Pull request data
  # @param metrics_type [Symbol] Type of metrics being processed
  def team_statistics(github_metrics, metrics_type)
    if metrics_type == :pull
      if github_metrics["data"] && github_metrics["data"]["repository"] && github_metrics["data"]["repository"]["pullRequest"]
        pull_request = github_metrics["data"]["repository"]["pullRequest"]
        @total_additions += pull_request["additions"]
        @total_deletions += pull_request["deletions"]
        @total_files_changed += pull_request["changedFiles"]
        @total_commits += pull_request.dig("commits", "totalCount") || 0
        pull_request_number = pull_request["number"]
        @merge_status[pull_request_number] = if pull_request["merged"]
                                              "MERGED"
                                            else
                                              pull_request["mergeable"]
                                            end
      else
        set_unavailable_statistics
      end
    end
  end

  # Sets default values when statistics are unavailable
  def set_unavailable_statistics
    @total_additions = "Not Available"
    @total_deletions = "Not Available"
    @total_files_changed = "Not Available"
    pull_request_number = -1
    @merge_status[pull_request_number] = "Not A Pull Request"
  end

  # Handles case when GitHub token is missing
  # @raise [StandardError] Always raises error about missing token
  def handle_missing_token
    raise StandardError, "GitHub access token is required"
  end

  # GraphQL query template for pull request data
  PULL_REQUEST_QUERY = <<~QUERY
    query {
      repository(owner: "%<owner_name>s", name: "%<repository_name>s") {
        pullRequest(number: %<pull_request_number>s) {
          number additions deletions changedFiles mergeable merged headRefOid
          commits(first: 100 %<after_clause>s) {
            totalCount
            pageInfo {
              hasNextPage startCursor endCursor
            }
            edges {
              node {
                id commit {
                  author {
                    name email user{login}
                  }
                  additions deletions changedFiles committedDate
                }
              }
            }
          }
        }
      }
    }
  QUERY

  # Sorts commit dates in chronological order
  def sort_commit_dates
    @dates = @dates.keys.sort
  end

  # Extracts repository information from pull request URL
  # @param hyperlink [String] Pull request URL
  # @return [Hash] Parsed repository information
  def parse_hyperlink_metrics(hyperlink)
    tokens = hyperlink.split('/')
    {
      "pull_request_number" => tokens[6],
      "repository_name" => tokens[4],
      "owner_name" => tokens[3]
    }
  end
end
