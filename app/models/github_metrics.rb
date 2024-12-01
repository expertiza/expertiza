class GithubMetrics
    attr_reader :participant, :assignment, :team, :token
    attr_accessor :head_refs, :parsed_data, :authors, :dates, :total_additions,
                  :total_deletions, :total_commits, :total_files_changed,
                  :merge_status, :check_statuses
  
    def initialize(participant_id, assignment_id = nil, token = nil)
      @participant = AssignmentParticipant.find(participant_id)
      @assignment = assignment_id ? Assignment.find(assignment_id) : @participant.assignment
      @team = @participant.team
      @token = token
      initialize_metrics
    end
  
    def process_metrics
      return handle_missing_token unless @token
      retrieve_github_metrics
      query_all_merge_statuses
      process_dates
      self
    end
  
    private
  
    def initialize_metrics
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
    end
  
    def retrieve_github_metrics
      team_links = @team.hyperlinks
      pull_links = team_links.select { |link| link.match(/pull/) && link.match(/github.com/) }
      
      if pull_links.empty?
        raise StandardError, 'No pull request links have been submitted by this team.'
      end
      
      parse_all_pull_requests(pull_links)
    end
  
    def parse_all_pull_requests(pull_links)
      pull_links.each do |hyperlink|
        hyperlink_data = parse_hyperlink_data(hyperlink)
        github_data = retrieve_pull_request_metrics(hyperlink_data)
    
        @head_refs[hyperlink_data["pull_request_number"]] = {
          head_commit: github_data["data"]["repository"]["pullRequest"]["headRefOid"],
          owner: hyperlink_data["owner_name"],
          repository: hyperlink_data["repository_name"]
        }
        parse_pull_request_metrics(github_data)
      end
    end
  
    def retrieve_pull_request_metrics(hyperlink_data)
      has_next_page = true
      end_cursor = nil
      all_edges = []
      response_data = {}
  
      while has_next_page
        response_data = query_commit_statistics(Metric.pull_query(hyperlink_data))
        current_commits = response_data["data"]["repository"]["pullRequest"]["commits"]
        current_page_info = current_commits["pageInfo"]
        
        all_edges.push(*current_commits["edges"])
        
        has_next_page = current_page_info["hasNextPage"]
        end_cursor = current_page_info["endCursor"]
      end
  
      response_data["data"]["repository"]["pullRequest"]["commits"]["edges"] = all_edges
      response_data
    end
  
    def parse_pull_request_metrics(github_data)
      team_statistics(github_data, :pull)
      commit_objects = github_data.dig("data", "repository", "pullRequest", "commits", "edges")
  
      commit_objects.each do |commit_object|
        commit = commit_object.dig("node", "commit")
        author_name = commit.dig("author", "name")
        author_email = commit.dig("author", "email")
        commit_date = commit.dig("committedDate").to_s[0, 10]
  
        count_github_authors_and_dates(author_name, author_email, commit_date)
      end
  
      sort_commit_dates
    end
  
    def query_all_merge_statuses
      @head_refs.each do |pull_number, pr_object|
        @check_statuses[pull_number] = query_pull_request_status(pr_object)
      end
    end
  
    def count_github_authors_and_dates(author_name, author_email, commit_date)
      @authors[author_name] ||= author_email
      @dates[commit_date] ||= 1
      @parsed_data[author_name] ||= Hash.new(0)
      @parsed_data[author_name][commit_date] += 1
    end
  
    def query_commit_statistics(data)
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
    
      request.body = { query: data }.to_json
      response = http.request(request)
      ActiveSupport::JSON.decode(response.body.to_s)
    end
  
    def query_pull_request_status(pr_object)
      url = "https://api.github.com/repos/#{pr_object[:owner]}/#{pr_object[:repository]}/commits/#{pr_object[:head_commit]}/status"
      ActiveSupport::JSON.decode(Net::HTTP.get(URI(url)))
    end
  
    def team_statistics(github_data, data_type)
      if data_type == :pull
        if github_data["data"] && github_data["data"]["repository"] && github_data["data"]["repository"]["pullRequest"]
          pull_request = github_data["data"]["repository"]["pullRequest"]
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
  
    private
  
    def set_unavailable_statistics
      @total_additions = "Not Available"
      @total_deletions = "Not Available"
      @total_files_changed = "Not Available"
      pull_request_number = -1
      @merge_status[pull_request_number] = "Not A Pull Request"
    end
  
    def handle_missing_token
      raise StandardError, "GitHub access token is required"
    end
  
    def process_dates
      @dates = @dates.keys.sort
    end
  end