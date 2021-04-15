class MetricsController < ApplicationController
  helper :file
  helper :submitted_content
  helper :penalty
  include PenaltyHelper
  include StudentTaskHelper
  include AssignmentHelper
  include GradesHelper
  include AuthorizationHelper
  include MetricsHelper # this module is currently empty

  # currently only give instructor this right, can be further discussed
  def action_allowed?
    current_user_has_instructor_privileges?
  end

  # render the view_github_metrics page
  def view
    if session["github_access_token"].nil? # check if there is a github_access_token in current session
      session["participant_id"] = params[:id]
      session["github_view_type"] = "view_submissions"
      redirect_to authorize_github_grades_path # if no github_access_token present, redirect to authorization page
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

    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment # participant has belong_to relationship with assignment
    @team = @participant.team # team method in AssignmentParticipant return the AssignmentTeam of this participant
    @team_id = @team.id

    # retrieve github data and store in the instance variables defined above
    retrieve_github_data

    # get each PR's status info
    retrieve_check_run_statuses

    @authors = @authors.keys # only keep the author name info
    @dates = @dates.keys.sort # only keep the date info and sort
  end

  # Fall 2018, E1858
  # example pull_links: https://github.com/expertiza/expertiza/pull/1858
  def retrieve_pull_request_data(pull_links)
    pull_links.each do |hyperlink|
      submission_hyperlink_tokens = hyperlink.split('/') # parse the link
      hyperlink_data = {}
      hyperlink_data["pull_request_number"] = submission_hyperlink_tokens.pop # 1858
      submission_hyperlink_tokens.pop # keyword pull, not need to keep
      hyperlink_data["repository_name"] = submission_hyperlink_tokens.pop # expertiza
      hyperlink_data["owner_name"] = submission_hyperlink_tokens.pop # expertiza
      # yet another wrapper fot github api call, take repository name, owner name, and pull request number as parameter
      github_data = get_pull_request_details(hyperlink_data)
      # github_data hash, each field is explained in get_query:
      # {"data"=>{"repository"=>{"pullRequest"=>{"number", "additions", "deletions", "changedFiles", "mergeable", "merged", "headRefOid",
      #                                          "commits"=>{"totalCount",
      #                                                      "pageInfo"=>{"hasNextPage", "startCursor", "endCursor"},
      #                                                      "edges"=>[{"node"=>{"id",
      #                                                                          "commit"=>{"author"=>{"name"},
      #                                                                                     "additions", "deletions", "changedFiles", "committedDate"
      #                                                                                    }
      #                                                                         }
      #                                                                },
      #                                                                {"node"=>...}
      #                                                                {"node"=>...}
      #                                                                ...
      #                                                                each node stands for a commit in the pull request with the same fields listed above
      #                                                                ]
      #                                                      }
      #                                          }
      #                         }
      #           }
      # }
      # save the global reference id for this pull request
      @head_refs[hyperlink_data["pull_request_number"]] = {
        head_commit: github_data["data"]["repository"]["pullRequest"]["headRefOid"],
        owner: hyperlink_data["owner_name"],
        repository: hyperlink_data["repository_name"]
      }
      parse_github_pull_request_data(github_data)
    end
  end

  # Fall 2018, E1858
  # example repo_links: github.com/expertiza/expertiza/
  def retrieve_repository_data(repo_links)
    repo_links.each do |hyperlink|
      submission_hyperlink_tokens = hyperlink.split('/') # parse the link
      hyperlink_data = {}
      hyperlink_data["repository_name"] = submission_hyperlink_tokens[4]
      # next if hyperlink_data["repository_name"] == "servo" || hyperlink_data["repository_name"] == "expertiza"
      hyperlink_data["owner_name"] = submission_hyperlink_tokens[3]
      github_data = get_github_repository_details(hyperlink_data)
      parse_github_repository_data(github_data)
    end
  end

  # Fall 2018, E1858
  # retrieve pull request data and repo data respectively
  def retrieve_github_data
    team_links = @team.hyperlinks # all links that a team submitted
    pull_links = team_links.select do |link|
      link.match(/pull/) && link.match(/github.com/) # all links that contain both pull and github.com
    end
    if !pull_links.empty? # have pull links, retrieve pull request info
      retrieve_pull_request_data(pull_links)
    else # retrieve repo info if no PR is submitted
    repo_links = team_links.select do |link|
      link.match(/github.com/)
    end
    retrieve_repository_data(repo_links)
    end
  end

  # Fall 2018, E1858
  # pr_object contain head commit reference num, author name, and repo name
  # using the github api end point to get the pr status info
  def get_statuses_for_pull_request(pr_object)
    url = "https://api.github.com/repos/" + pr_object[:owner] + "/" + pr_object[:repository] + "/commits/" + pr_object[:head_commit] + "/status"
    ActiveSupport::JSON.decode(Net::HTTP.get(URI(url)))
  end

  # Fall 2018, E1858
  # save each PR's statuses in a hash, this is done by github REST API not graphql
  def retrieve_check_run_statuses
    @head_refs.each do |pull_number, pr_object|
      @check_statuses[pull_number] = get_statuses_for_pull_request(pr_object)
    end
  end

  # Fall 2018, E1858
  # render the view_github_metrics page
  def view_github_metrics
    byebug
    if session["github_access_token"].nil? # check if there is a github_access_token in current session
      session["participant_id"] = params[:id]
      session["github_view_type"] = "view_submissions"
      redirect_to authorize_github_grades_path # if no github_access_token present, redirect to authorization page
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

    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment # participant has belong_to relationship with assignment
    @team = @participant.team # team method in AssignmentParticipant return the AssignmentTeam of this participant
    @team_id = @team.id

    # retrieve github data and store in the instance variables defined above
    retrieve_github_data

    # get each PR's status info
    retrieve_check_run_statuses

    @authors = @authors.keys # only keep the author name info
    @dates = @dates.keys.sort # only keep the date info and sort
  end

  # Fall 2018, E1858
  # authorize with token to use github API with 5000 rate limits. Unauthorized user only has 60 limits, which is not enough.
  def authorize_github
    redirect_to "https://github.com/login/oauth/authorize?client_id=#{GITHUB_CONFIG['client_key']}"
  end

  # Fall 2018, E1858
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

  # Fall 2018, E1858
  def get_pull_request_details(hyperlink_data)
    @has_next_page = true # parameter for github api call
    @end_cursor = "" # parameter needed for github api call
    all_edges = []
    response_data = {}
    while @has_next_page
      # 1.make the query message
      # 2.make the http request with the query
      # response_data is a ruby Hash class
      response_data = make_github_graphql_request(get_query(hyperlink_data))
      # every commits in this pull request and page info
      current_commits = response_data["data"]["repository"]["pullRequest"]["commits"]
      # page info for commits in this pull request, because too many commits may spread multiple pages
      current_page_info = current_commits["pageInfo"]
      # push every node, which is a single commit, onto all_edges
      # every element in all_edges is a single commit in the pull request
      all_edges.push(*current_commits["edges"])
      # page info used in query for next page
      @has_next_page = current_page_info["hasNextPage"]
      @end_cursor = current_page_info["endCursor"]
    end
    # add every single commit into response_data hash and return it
    response_data["data"]["repository"]["pullRequest"]["commits"]["edges"] = all_edges
    response_data
  end
  # do accounting, aggregate each authors' number of commits on each date
  def process_github_authors_and_dates(author_name, commit_date)
    @authors[author_name] ||= 1 # a hash record all the authors
    @dates[commit_date] ||= 1 # a hash record all the date that has commits
    @parsed_data[author_name] ||= {} # a hash account each author's commits grouped by date
    @parsed_data[author_name][commit_date] = if @parsed_data[author_name][commit_date]
                                               @parsed_data[author_name][commit_date] + 1
                                             else
                                               1
                                             end
  end
  # save elements in the hash into corresponding variables
  def parse_github_pull_request_data(github_data)
    team_statistics(github_data)
    pull_request_object = github_data["data"]["repository"]["pullRequest"]
    commit_objects = pull_request_object["commits"]["edges"]
    # loop through all commits and do the accounting
    commit_objects.each do |commit_object|
      commit = commit_object["node"]["commit"] # each commit
      author_name = commit["author"]["name"]
      commit_date = commit["committedDate"].to_s # datetime object to string in format 2019-04-30T02:44:08Z
      # commit_date[0, 10]: xxxx-xx-xx year-month-date
      process_github_authors_and_dates(author_name, commit_date[0, 10])
    end
    # sort author's commits based on dates
    organize_commit_dates
  end

  # Fall 2018, E1858
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

  # Fall 2018, E1858
  # make the actual github api request with graphql and query message.
  # data: the query message made in get_query method. Documented in detail in get_query method
  def make_github_graphql_request(data)
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

  # Fall 2018, E1858
  # sort each author's commits based on date
  def organize_commit_dates
    @dates.each_key do |date|
      @parsed_data.each_value do |commits|
        commits[date] ||= 0
      end
    end
    @parsed_data.each {|author, commits| @parsed_data[author] = Hash[commits.sort_by {|date, _commit_count| date }] }
  end

  # Fall 2018, E1858
  # save valuable info that we queried from github into variables
  def team_statistics(github_data)
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
  end

  # Fall 2018, E1858
  # hyperlink_data: {"pull_request_number"=>"1858", "repository_name"=>"expertiza", "owner_name"=>"expertiza"}
  # make the query message string that will be used in the github graphql library.
  # For the detailed explanation check https://docs.github.com/en/graphql/reference/objects#pullrequest
  # and https://docs.github.com/en/graphql/reference/objects#repository
  # name: The name of the repository. owner: The User owner of the repository. number: Identifies the pull request number.
  # Everything between the opening #{ and closing } bits is evaluated as Ruby code,
  # and the result of this evaluation will be embedded into the string surrounding it.
  # #{"after:" + @end_cursor unless @end_cursor.empty? } This line only evaluate when
  # @end_cursor.empty evaluate to false, handle edge case that there is next page in the page info.
  # This query message queries the {owner}'s {name} repo's {number} pull request that you passed in.
  # For the example provided above, this query will queries expertiza's expertiza repo's pull request
  # number 1858.
  # In each pull request, it will return:
  # 1.number: pull request number
  # 2.additions: the number of additions in this pull request
  # 3.deletions: the number of deletions in this pull request
  # 4.changedFiles: the number of changed files in this pull request
  # 5.mergeable: whether or not the pull request can be merged based on the existence of merge conflicts
  # 6.merged: whether or not the pull request was merged
  # 7.headRefOid: identifies the oid of the head ref associated with the pull request, this is a global id
  # 8.A list(first 100) of commits present in this pull request
  # In the list of these commits, it will return:
  # 1.totalCount: identifies the total count of items in the connection
  # In each of the commit, it will return:
  # 1.name: the name in the Git commit
  # 2.additions: the number of additions in this pull request
  # 3.deletions: the number of deletions in this pull request
  # 4.changedFiles: the number of changed files in this pull request
  # 5.committedDate: The datetime when this commit was committed
  def get_query(hyperlink_data)
    {
      query: "query {
        repository(owner: \"" + hyperlink_data["owner_name"] + "\", name:\"" + hyperlink_data["repository_name"] + "\") {
          pullRequest(number: " + hyperlink_data["pull_request_number"] + ") {
            number additions deletions changedFiles mergeable merged headRefOid
              commits(first:100 #{"afterwhether or not the pull rwhether or not the pull request can be merged based on the existence of merge conflictsequest can be merged based on the existence of merge conflicts:" + @end_cursor unless @end_cursor.empty? }){
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






  def show
  end
end
