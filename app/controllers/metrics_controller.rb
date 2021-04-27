class MetricsController < ApplicationController
  include AuthorizationHelper
  include AssignmentHelper
  include MetricsHelper

  # currently only give instructor this right, can be further discussed
  def action_allowed?
    current_user_has_instructor_privileges?
  end

  def create_github_metric(team_id, github_id, total_commits)
      metric = Metric.where("team_id = ? AND github_id = ?", team_id, github_id).first
      # Attempt to find user by their github email
      user = User.find_by_github_id(github_id)

      # If not set, attempt to figure out the association
      if user.nil?
        email = github_id.split('@')
        #Check if NCSU email
        if email[1] == 'ncsu.edu'
          user = User.find_by_email(github_id)
          user.github_id = github_id unless user.nil?
          user.save unless user.nil?
        else # if unityID@gmail.com or similar
          user = User.find_by_email(email[0] + "@ncsu.edu")
          user.github_id = github_id unless user.nil?
          user.save unless user.nil?
        end
      end

      # Finally, set user id to be used when creating DB table rows
      participant_id = user.nil? ? nil : user.id

      # Now, if a record exists for this user and assignment, update it
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

  #Runs a query against all the link submissions for an entire assignment, populating the DB fields that are
  # used by the view_team in grades heatgrid showing user contributions
  def query_assignment_statistics
    @assignment = Assignment.find(params[:id])
    teams = @assignment.teams
    teams.each do |team|
      topic_identifier, topic_name, users_for_curr_team, participants = get_data_for_list_submissions(team)
      single_submission_initial_query(participants.first.id)
    end

  end

  # render the view_github_metrics page
  def show
    single_submission_initial_query(params[:id])
  end

  # authorize with token to use github API with 5000 rate limits. Unauthorized user only has 60 limits, which is not enough.
  def authorize_github
    redirect_to "https://github.com/login/oauth/authorize?client_id=#{GITHUB_CONFIG['client_key']}"
  end

  def single_submission_initial_query(id)
    if session["github_access_token"].nil? # check if there is a github_access_token in current session
      session["participant_id"] = params[:id] # team number
      session["github_view_type"] = "view_submissions"
      #redirect_to authorize_github_grades_path # if no github_access_token present, redirect to authorization page
      redirect_to :controller => 'metrics', :action => 'authorize_github'
      return
    end

    @head_refs = {} # global reference hash, key is PR number, value is the head commit global id, owner, and repo
    @parsed_data = {} # a hash track each author's commits grouped by date
    @authors = {} # pull request authors
    @dates = {} # dates info for dates that have commits
    @total_additions = 0 # num of lines added
    @total_deletions = 0 # num of lines deleted
    @total_commits = 0 # num of commits in this PR
    @total_files_changed = 0 # num of files changed in this PR
    @merge_status = {} # merge status of this PR open or closed
    @check_statuses = {} # statuses info for each PR

    @token = session["github_access_token"]

    @participant = AssignmentParticipant.find(id)
    @assignment = @participant.assignment # participant has belong_to relationship with assignment
    @team = @participant.team # team method in AssignmentParticipant return the AssignmentTeam of this participant
    @team_id = @team.id

    # retrieve github data and store in the instance variables defined above
    retrieve_github_data

    # get each PR's status info
    query_all_merge_statuses

    #@authors = @authors.keys # only keep the author name info
    @dates = @dates.keys.sort # only keep the date info and sort

    @participants = get_data_for_list_submissions(@team)

    # Create database entry for basic statistics. These data are queried later by view_team in grades (the heatgrid)
    @authors.each do |author|
      unless LOCAL_ENV["BLACKLIST_AUTHOR"].include? author[0]
        data_object = {}
        data_object[:author] = author[0]
        data_object[:email] = author[1]
        data_object[:commits] = @parsed_data[author[0]].values.inject(0) {|sum, value| sum += value}
        # user = User.find_by_github_id(author[1])
        # user_id = user.nil? ? nil : user.id
        create_github_metric(@team_id, author[1], data_object[:commits])
      end
    end
  end



  private
  ##################### Process Links and Branch according to Pull Request or Repo ############################
  # retrieve pull request data and repo data respectively
  def retrieve_github_data
    team_links = @team.hyperlinks # all links that a team submitted
    pull_links = team_links.select do |link|
      link.match(/pull/) && link.match(/github.com/) # all links that contain both pull and github.com
    end
    if !pull_links.empty? # have pull links, retrieve pull request info
      query_all_pull_requests(pull_links)
    else # retrieve repo info if no PR is submitted
    repo_links = team_links.select do |link|
      link.match(/github.com/)
    end
    retrieve_repository_data(repo_links)
    end
  end


  ############### Handling of Pull Request Links #####################

  # example pull_links: https://github.com/expertiza/expertiza/pull/1858
  def query_all_pull_requests(pull_links)
    pull_links.each do |hyperlink|
      submission_hyperlink_tokens = hyperlink.split('/') # parse the link
      hyperlink_data = {}
      hyperlink_data["pull_request_number"] = submission_hyperlink_tokens[6] # 1858
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

  # call the api with hyperlink parameter
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

  # save elements in the hash into corresponding variables
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
      # commit_date[0, 10]: xxxx-xx-xx year-month-date
      count_github_authors_and_dates(author_name, author_email, commit_date[0, 10])
    end
    # sort author's commits based on dates
    sort_commit_dates
  end

  # save each PR's statuses in a hash, this is done by github REST API not graphql
  def query_all_merge_statuses
    @head_refs.each do |pull_number, pr_object|
      @check_statuses[pull_number] = query_pull_request_status(pr_object)
    end
  end


  ####################### Handling of Repository Links #########################
  # example repo_links: github.com/expertiza/expertiza/
  def retrieve_repository_data(repo_links)
    has_next_page = true # parameter for github api call
    end_cursor = nil # parameter needed for github api call

    repo_links.each do |hyperlink|
      submission_hyperlink_tokens = hyperlink.split('/') # parse the link
      hyperlink_data = {}
      hyperlink_data["repository_name"] = submission_hyperlink_tokens[4].gsub('.git', '')
      hyperlink_data["owner_name"] = submission_hyperlink_tokens[3]
      while has_next_page
        query_text = Metric.repo_query(hyperlink_data, @assignment.created_at, end_cursor)
        github_data = query_commit_statistics(query_text)
        parse_repository_data(github_data)
        has_next_page = false unless github_data["data"]["repository"]["ref"]["target"]["history"]["pageInfo"]["hasNextPage"] == "true"
      end

    end
  end

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

  # save valuable info that we queried from github into variables
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
    #unless Metric.blacklist_author(author_name)
    unless LOCAL_ENV["BLACKLIST_AUTHOR"].include? author_name
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
    request = Net::HTTP::Post.new(uri.path, 'Authorization' => 'Bearer' + ' ' + session["github_access_token"]) # set up authorization
    request.body = data.to_json # convert query message to json and pass as request body
    #    http.request(request)
    response = http.request(request) # make the actual request
    ActiveSupport::JSON.decode(response.body.to_s) # convert the response body to string, decoded then return
  end

  # pr_object contain head commit reference num, author name, and repo name
  # using the github api end point to get the pr status info
  def query_pull_request_status(pr_object)
    url = "https://api.github.com/repos/" + pr_object[:owner] + "/" + pr_object[:repository] + "/commits/" + pr_object[:head_commit] + "/status"
    ActiveSupport::JSON.decode(Net::HTTP.get(URI(url)))
  end

end
