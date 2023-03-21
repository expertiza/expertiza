      hyperlink_data["pull_request_number"] = submission_hyperlink_tokens[6]
      hyperlink_data["repository_name"] = submission_hyperlink_tokens[4] # expertiza
      hyperlink_data["owner_name"] = submission_hyperlink_tokens[3] # expertiza
      # yet another wrapper fot github api call, take repository name, owner name, and pull request number as parameter
      github_data = pull_request_data(hyperlink_data)

      # save the global reference id for this pull request
      @head_refs[hyperlink_data["pull_request_number"]] = {
        head_commit: github_data["data"]["repository"]["pullRequest"]["headRefOid"],
        owner: hyperlink_data["owner_name"],
        repository: hyperlink_data["repository_name"]
      }
      parse_pull_request_data(github_data)
    end
  end

  # Iterate across pages of 100 commits queried from the Github API, getting the query from the Metric model, running
  # the query, then calling the data parser
  def pull_request_data(hyperlink_data)
    has_next_page = true # parameter for github api call
    end_cursor = nil # parameter needed for github api call
    all_edges = []
    response_data = {}
    while has_next_page
      # 1.make the query message
      # 2.make the http request with the query
      # response_data is a ruby Hash class
      response_data = query_commit_statistics(Metric.pull_query(hyperlink_data, end_cursor))
      # every commits in this pull request and page info
      current_commits = response_data["data"]["repository"]["pullRequest"]["commits"]
      # page info for commits in this pull request, because too many commits may spread multiple pages
      current_page_info = current_commits["pageInfo"]
      # push every node, which is a single commit, onto all_edges
      # every element in all_edges is a single commit in the pull request
      all_edges.push(*current_commits["edges"])
      # page info used in query for next page
      has_next_page = current_page_info["hasNextPage"]
      end_cursor = current_page_info["endCursor"]
    end
    # add every single commit into response_data hash and return it
    response_data["data"]["repository"]["pullRequest"]["commits"]["edges"] = all_edges
    response_data
  end

  # Parse through data returned from  github API, strip unnecessary layers from hashes, and organize data
  # into accessible hash for use elsewhere
  def parse_pull_request_data(github_data)
    team_statistics(github_data, :pull)
    pull_request_object = github_data["data"]["repository"]["pullRequest"]
    commit_objects = pull_request_object["commits"]["edges"]
    # loop through all commits and do the accounting
    commit_objects.each do |commit_object|
      commit = commit_object["node"]["commit"] # each commit
      author_name = commit["author"]["name"]
      author_email = commit["author"]["email"]
      commit_date = commit["committedDate"].to_s # datetime object to string in format 2019-04-30T02:44:08Z
      count_github_authors_and_dates(author_name, author_email, commit_date[0, 10])
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
    has_next_page = true # parameter for github api call
    end_cursor = nil # parameter needed for github api call

    repo_links.each do |hyperlink|
      submission_hyperlink_tokens = hyperlink.split('/') # parse the link
      hyperlink_data = {}
      #Example: https://github.com/student/expertiza.git
      # submission_hyperlink_tokens[4] == "expertiza.git"
      # submission_hyperlink_tokens[3] == "student"
      # submission_hyperlink_tokens[2] == "github.com"
      # submission_hyperlink_tokens[1] == ""
      # submission_hyperlink_tokens[0] == "https:"
      hyperlink_data["repository_name"] = submission_hyperlink_tokens[4].gsub('.git', '')
      hyperlink_data["owner_name"] = submission_hyperlink_tokens[3]
      while has_next_page
        query_text = Metric.repo_query(hyperlink_data, @assignment.created_at, end_cursor)
        github_data = query_commit_statistics(query_text)
        # Parse repository data only if API did not return  an error; otherwise, drop API return hash
        parse_repository_data(github_data) unless github_data.nil? || github_data["errors"] || github_data["data"].nil? || github_data["data"]["repository"].nil? || github_data["data"]["repository"]["ref"].nil?
        # Only run iteration across an additional page in case of no API errors and presence of additional pages of commits are detected
        has_next_page = false if github_data.nil? || github_data["data"].nil? || github_data["data"]["repository"].nil? || github_data["data"]["repository"]["ref"].nil?|| github_data["errors"] || github_data["data"]["repository"]["ref"]["target"]["history"]["pageInfo"]["hasNextPage"] != "true"
      end
    end
  end

  # Process data returned by a respository query, stripping unecessary layers off of data hash, and organizing data for use
  # elsewhere in the app. Also calls accounting method for each commit, and sorting method to sort the data upon completion.
  # Finally,  calls team_statistics to parse the organized datasets and assemble key instance variables for the views.
  def parse_repository_data(github_data)
    commit_objects = github_data["data"]["repository"]["ref"]["target"]["history"]["edges"]
    commit_objects.each do |commit_object|
      commit_author = commit_object["node"]["author"]
      author_name = commit_author["name"]
      author_email = commit_author["email"]
      commit_date = commit_author["date"].to_s
      count_github_authors_and_dates(author_name, author_email, commit_date[0, 10])
    end
    sort_commit_dates
    team_statistics(github_data, :repo)
  end

  ####################### Shared Math/Stats and Sorting Methods ################

  # Traverse organized datasets and assemble key instance variables for the views. Handles differences in dataset between
  # pull request queries and repository queries
  def team_statistics(github_data, data_type)
    if data_type == :pull
      @total_additions += github_data["data"]["repository"]["pullRequest"]["additions"] # additions in this PR
      @total_deletions += github_data["data"]["repository"]["pullRequest"]["deletions"] # deletions in this PR
      @total_files_changed += github_data["data"]["repository"]["pullRequest"]["changedFiles"] # num of files changed in this PR
      @total_commits += github_data["data"]["repository"]["pullRequest"]["commits"]["totalCount"] # num of commits in this PR
      pull_request_number = github_data["data"]["repository"]["pullRequest"]["number"] # PR number
      # merged or mergeable
      @merge_status[pull_request_number] = if github_data["data"]["repository"]["pullRequest"]["merged"]
                                             "MERGED"
                                           else
                                             github_data["data"]["repository"]["pullRequest"]["mergeable"]
                                           end
    else
      @total_additions = "Not Available" # additions in this PR
      @total_deletions = "Not Available" # deletions in this PR
      @total_files_changed = "Not Available" # num of files changed in this PR
      pull_request_number = -1
      # merged or mergeable
      @merge_status[pull_request_number] = "Not A Pull Request"
    end
  end

  # do accounting, aggregate each authors' number of commits on each date
  def count_github_authors_and_dates(author_name, author_email, commit_date)
    # Only count a commit if it was not made by a member of the Expertiza development team
    unless LOCAL_ENV["COLLABORATORS"].include? author_name
      @authors[author_name] ||= author_email # a hash record all the authors and their emails
      @dates[commit_date] ||= 1 # a hash record all the date that has commits
      @parsed_data[author_name] ||= {} # a hash account each author's commits grouped by date
      @parsed_data[author_name][commit_date] = if @parsed_data[author_name][commit_date]
                                                 @parsed_data[author_name][commit_date] + 1
                                               else
                                                 1
                                               end

    end
  end

  # sort each author's commits based on date
  def sort_commit_dates
    @dates.each_key do |date|
      @parsed_data.each_value do |commits|
        commits[date] ||= 0
      end
    end
    @parsed_data.each do |author, commits|
      @parsed_data[author] = Hash[commits.sort_by {|date, _commit_count| date }]
      @total_commits += commits.inject (0) {|sum,value| sum + value[1] }
    end
  end

  ######################## HTTP Query Execution #########################

  # make the actual github api request with graphql and query message.
  # data: the query message made in get_query method. Documented in detail in get_query method
  def query_commit_statistics(data)
    uri = URI.parse("https://api.github.com/graphql")
    http = Net::HTTP.new(uri.host, uri.port) # host: api.github.com, port: 443
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    # request = Net::HTTP::Post.new(uri.path, 'Authorization' => 'Bearer' + ' ' + session["github_access_token"]) # set up authorization
    request = Net::HTTP::Post.new(uri.path) # set up authorization
    # send the token in the header
    request['Authorization'] = 'Bearer' + ' ' + session["github_access_token"]
    request.body = data.to_json # convert query message to json and pass as request body
    response = http.request(request) # make the actual request
    ActiveSupport::JSON.decode(response.body.to_s) # convert the response body to string, decoded then return
  end

  # pr_object contains head commit reference num, author name, and repo name
  # using the github api end point to get the pull request status info
  def query_pull_request_status(pr_object)
    url = "https://api.github.com/repos/" + pr_object[:owner] + "/" + pr_object[:repository] + "/commits/" + pr_object[:head_commit] + "/status"
    ActiveSupport::JSON.decode(Net::HTTP.get(URI(url)))
  end

  # Handle the create action for a github metric, which stores a datapoint mapping a team id, and a github email address
  # to an expertiza User, with a datapoint for their total contributions to the project. Users are asked to create the
  # mapping from their Github email within their user profile, but we also try to intelligently determine that mapping if
  # the user has not provided an email, and their profile contains enough clues.
  def create_github_metric(team_id, github_id, total_commits)
    metric = Metric.where("team_id = ? AND github_id = ?", team_id, github_id).first
    # Attempt to find user by their github email -- Mapping already exists
    user = User.find_by_github_id(github_id)

    # If mapping does not exist, attempt to figure out their github email from the information we have
    if user.nil?
      email = github_id.split('@')
      #Check if NCSU email
      if email[1] == 'ncsu.edu'
        user = User.find_by_email(github_id)
        # If success, go ahead and save this mapping for future queries
        user.github_id = github_id unless user.nil?
        user.save unless user.nil?
      else # Try mapping from unityID@any_email_provider.com or unityID@anotherprovider.com
        user = User.find_by_email(email[0] + "@ncsu.edu")
        # If success, go ahead and save this mapping for future queries
        user.github_id = github_id unless user.nil?
        user.save unless user.nil?
      end
    end

    # Finally, use results of mapping attempts, or successful query, to set the participant ID to be stored in the
    # metrics table. If no participant ID is found, store as NULL, and handle NULL results at the view
    participant_id = user.nil? ? nil : user.id

    # Now, if a record already exists for this user and assignment, update it
    unless metric.nil?
      metric.total_commits=total_commits
      metric.participant_id = participant_id
      metric.save
    else #Otherwise, create a new record
    Metric.create :metric_source_id => MetricSource.find_by_name("Github").id,
                  :team_id => team_id,
                  :github_id => github_id,
                  :participant_id => participant_id,
                  :total_commits => total_commits
    end
  end
end
