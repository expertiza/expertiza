class GradesController < ApplicationController
  helper :file
  helper :submitted_content
  helper :penalty
  include PenaltyHelper
  include StudentTaskHelper
  include AssignmentHelper
  include GradesHelper
  include AuthorizationHelper

  def action_allowed?
    case params[:action]
    when 'view_my_scores'
      current_user_has_student_privileges? and
      are_needed_authorizations_present?(params[:id], "reader", "reviewer") and
      self_review_finished?
    when 'view_team'
      if current_user_is_a? 'Student' # students can only see the heat map for their own team
        participant = AssignmentParticipant.find(params[:id])
        current_user_is_assignment_participant?(participant.assignment.id)
      else
        true
      end
    else
      current_user_has_ta_privileges?
    end
  end

  # the view grading report provides the instructor with an overall view of all the grades for
  # an assignment. It lists all participants of an assignment and all the reviews they received.
  # It also gives a final score, which is an average of all the reviews and greatest difference
  # in the scores of all the reviews.
  def view
    # This code needs to be moved to the new github metrics controller slated as part of E2111, and needs to be
    # made optional in some manner. TAs and instructors should not HAVE to have an authorized github token to
    # browse this page. Instead, this authorization should take place only if github metrics are specifically requested.
    #
    # if session["github_access_token"].nil?
    #    session["assignment_id"] = params[:id]
    #    session["github_view_type"] = "view_scores"
    #    return redirect_to authorize_github_grades_path
    # end
    @assignment = Assignment.find(params[:id])
    questionnaires = @assignment.questionnaires

    if @assignment.varying_rubrics_by_round?
      @questions = retrieve_questions questionnaires, @assignment.id
    else
      @questions = {}
      questionnaires.each do |questionnaire|
        @questions[questionnaire.symbol] = questionnaire.questions
      end
    end

    @scores = @assignment.scores(@questions)
    averages = vector(@assignment.scores(@questions))
    @average_chart = bar_chart(averages, 300, 100, 5)
    @avg_of_avg = mean(averages)
    penalties(@assignment.id)

    @show_reputation = false
  end

  def view_my_scores
    @participant = AssignmentParticipant.find(params[:id])
    @team_id = TeamsUser.team_id(@participant.parent_id, @participant.user_id)
    return if redirect_when_disallowed
    @assignment = @participant.assignment
    questionnaires = @assignment.questionnaires
    @questions = retrieve_questions questionnaires, @assignment.id
    # @pscore has the newest versions of response for each response map, and only one for each response map (unless it is vary rubric by round)
    @pscore = @participant.scores(@questions)
    make_chart
    @topic_id = SignedUpTeam.topic_id(@participant.assignment.id, @participant.user_id)
    @stage = @participant.assignment.get_current_stage(@topic_id)
    penalties(@assignment.id)
    # prepare feedback summaries
    summary_ws_url = WEBSERVICE_CONFIG["summary_webservice_url"]
    sum = SummaryHelper::Summary.new.summarize_reviews_by_reviewee(@questions, @assignment, @team_id, summary_ws_url, session)
    @summary = sum.summary
    @avg_scores_by_round = sum.avg_scores_by_round
    @avg_scores_by_criterion = sum.avg_scores_by_criterion
  end

  # method for alternative view
  def view_team
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment
    @team = @participant.team
    @team_id = @team.id
    questionnaires = @assignment.questionnaires
    @questions = retrieve_questions questionnaires, @assignment.id
    @pscore = @participant.scores(@questions)
    @vmlist = []

    # loop through each questionnaire, and populate the view model for all data necessary
    # to render the html tables.
    counter_for_same_rubric = 0
    questionnaires.each do |questionnaire|
      @round = nil
      if @assignment.vary_by_round && questionnaire.type == "ReviewQuestionnaire"
        questionnaires = AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id: questionnaire.id)
        if questionnaires.count > 1
          @round = questionnaires[counter_for_same_rubric].used_in_round
          counter_for_same_rubric += 1
        else
          @round = questionnaires[0].used_in_round
          counter_for_same_rubric = 0
        end
      end
      @vmlist << populate_view_model(questionnaire)
    end
    @current_role_name = current_role_name
  end

  def edit
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment
    @questions = list_questions(@assignment)
    @scores = @participant.scores(@questions)
  end

  def instructor_review
    participant = AssignmentParticipant.find(params[:id])
    reviewer = AssignmentParticipant.find_or_create_by(user_id: session[:user].id, parent_id: participant.assignment.id)
    reviewer.set_handle if reviewer.new_record?
    review_exists = true
    reviewee = participant.team
    review_mapping = ReviewResponseMap.find_or_create_by(reviewee_id: reviewee.id, reviewer_id: reviewer.id, reviewed_object_id: participant.assignment.id)
    if review_mapping.new_record?
      review_exists = false
    else
      review = Response.find_by(map_id: review_mapping.map_id)
    end
    if review_exists
      redirect_to controller: 'response', action: 'edit', id: review.id, return: "instructor"
    else
      redirect_to controller: 'response', action: 'new', id: review_mapping.map_id, return: "instructor"
    end
  end

  # This method is used from edit methods
  def list_questions(assignment)
    questions = {}
    questionnaires = assignment.questionnaires
    questionnaires.each do |questionnaire|
      questions[questionnaire.symbol] = questionnaire.questions
    end
    questions
  end

  def update
    participant = AssignmentParticipant.find(params[:id])
    total_score = params[:total_score]
    if format("%.2f", total_score) != params[:participant][:grade]
      participant.update_attribute(:grade, params[:participant][:grade])
      message = if participant.grade.nil?
                  "The computed score will be used for " + participant.user.name + "."
                else
                  "A score of " + params[:participant][:grade] + "% has been saved for " + participant.user.name + "."
                end
    end
    flash[:note] = message
    redirect_to action: 'edit', id: params[:id]
  end

  def save_grade_and_comment_for_submission
    participant = AssignmentParticipant.find_by(id: params[:participant_id])
    @team = participant.team
    @team.grade_for_submission = params[:grade_for_submission]
    @team.comment_for_submission = params[:comment_for_submission]
    begin
      @team.save
      flash[:success] = 'Grade and comment for submission successfully saved.'
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
    redirect_to controller: 'grades', action: 'view_team', id: participant.id
    end

=begin
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
=end

  def bar_chart(scores, width = 100, height = 100, spacing = 1)
    link = nil
    GoogleChart::BarChart.new("#{width}x#{height}", " ", :vertical, false) do |bc|
      data = scores
      bc.data "Line green", data, '990000'
      bc.axis :y, range: [0, data.max], positions: data.minmax
      bc.show_legend = false
      bc.stacked = false
      bc.width_spacing_options(bar_width: (width - 30) / (data.size + 1), bar_spacing: 1, group_spacing: spacing)
      bc.data_encoding = :extended
      link = bc.to_url
    end
    link
  end

  private

  def populate_view_model(questionnaire)
    vm = VmQuestionResponse.new(questionnaire, @assignment, @round)
    vmquestions = questionnaire.questions
    vm.add_questions(vmquestions)
    vm.add_team_members(@team)
    vm.add_reviews(@participant, @team, @assignment.vary_by_round)
    vm.number_of_comments_greater_than_10_words
    vm
  end

  def redirect_when_disallowed
    # For author feedback, participants need to be able to read feedback submitted by other teammates.
    # If response is anything but author feedback, only the person who wrote feedback should be able to see it.
    ## This following code was cloned from response_controller.

    # ACS Check if team count is more than 1 instead of checking if it is a team assignment
    if @participant.assignment.max_team_size > 1
      team = @participant.team
      unless team.nil? || (team.user? session[:user])
          flash[:error] = 'You are not on the team that wrote this feedback'
          redirect_to '/'
          return true
      end
    else
      reviewer = AssignmentParticipant.where(user_id: session[:user].id, parent_id: @participant.assignment.id).first
      return true unless current_user_id?(reviewer.try(:user_id))
    end
    false
  end

  def assign_all_penalties(participant, penalties)
    @all_penalties[participant.id] = {
      submission: penalties[:submission],
      review: penalties[:review],
      meta_review: penalties[:meta_review],
      total_penalty: @total_penalty
    }
  end

  def make_chart
    @grades_bar_charts = {}
    participant_score_types = %i[metareview feedback teammate]
    if @pscore[:review]
      scores = []
      if @assignment.vary_by_round
        (1..@assignment.rounds_of_reviews).each do |round|
          responses = @pscore[:review][:assessments].select {|response| response.round == round }
          scores = scores.concat(score_vector(responses, 'review' + round.to_s))
          scores -= [-1.0]
        end
        @grades_bar_charts[:review] = bar_chart(scores)
      else
        charts(:review)
      end
    end
    participant_score_types.each {|symbol| charts(symbol) }
  end

  def self_review_finished?
    participant = Participant.find(params[:id])
    assignment = participant.try(:assignment)
    self_review_enabled=assignment.try(:is_selfreview_enabled)
    not_submitted=unsubmitted_self_review?(participant.try(:id))
    if self_review_enabled
      !not_submitted
    else
      true
    end
  end
end
