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
      if current_user_is_a? 'Student' # students can only see the head map for their own team
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
    if session["github_access_token"].nil?
      session["assignment_id"] = params[:id]
      session["github_view_type"] = "view_scores"
      return redirect_to authorize_github_grades_path
    end
    @assignment = Assignment.find(params[:id])
    questionnaires = @assignment.questionnaires

    if @assignment.vary_by_round
      @questions = retrieve_questions questionnaires, @assignment.id
    else
      @questions = {}
      questionnaires.each do |questionnaire|
        @questions[questionnaire.symbol] = questionnaire.questions
      end
    end

    @scores = @assignment.scores(@questions)
    averages = calculate_average_vector(@assignment.scores(@questions))
    @average_chart = bar_chart(averages, 300, 100, 5)
    @avg_of_avg = mean(averages)
    calculate_all_penalties(@assignment.id)
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
    calculate_all_penalties(@assignment.id)
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
      vm = VmQuestionResponse.new(questionnaire, @assignment, @round)
      vmquestions = questionnaire.questions
      vm.add_questions(vmquestions)
      vm.add_team_members(@team)
      vm.add_reviews(@participant, @team, @assignment.vary_by_round)
      vm.number_of_comments_greater_than_10_words
      @vmlist << vm
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
      #  next if hyperlink_data["repository_name"] == "servo" || hyperlink_data["repository_name"] == "expertiza"
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
    #    http.request(request)
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
              commits(first:100 #{"after:" + @end_cursor unless @end_cursor.empty? }){
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

  private

  def redirect_when_disallowed
    # For author feedback, participants need to be able to read feedback submitted by other teammates.
    # If response is anything but author feedback, only the person who wrote feedback should be able to see it.
    ## This following code was cloned from response_controller.

    # ACS Check if team count is more than 1 instead of checking if it is a team assignment
    if @participant.assignment.max_team_size > 1
      team = @participant.team
      unless team.nil?
        unless team.user? session[:user]
          flash[:error] = 'You are not on the team that wrote this feedback'
          redirect_to '/'
          return true
        end
      end
    else
      reviewer = AssignmentParticipant.where(user_id: session[:user].id, parent_id: @participant.assignment.id).first
      return true unless current_user_id?(reviewer.try(:user_id))
    end
    false
  end

  def calculate_all_penalties(assignment_id)
    @all_penalties = {}
    @assignment = Assignment.find(assignment_id)
    calculate_for_participants = true unless @assignment.is_penalty_calculated
    Participant.where(parent_id: assignment_id).each do |participant|
      penalties = calculate_penalty(participant.id)
      @total_penalty = 0

      unless penalties[:submission].zero? || penalties[:review].zero? || penalties[:meta_review].zero?

        @total_penalty = (penalties[:submission] + penalties[:review] + penalties[:meta_review])
        l_policy = LatePolicy.find(@assignment.late_policy_id)
        @total_penalty = l_policy.max_penalty if @total_penalty > l_policy.max_penalty
        calculate_penalty_attributes(@participant) if calculate_for_participants
      end
      assign_all_penalties(participant, penalties)
    end
    @assignment.update_attribute(:is_penalty_calculated, true) unless @assignment.is_penalty_calculated
  end

  def calculate_penalty_attributes(_participant)
    deadline_type_id = [1, 2, 5]
    penalties_symbols = %i[submission review meta_review]
    deadline_type_id.zip(penalties_symbols).each do |id, symbol|
      CalculatedPenalty.create(deadline_type_id: id, participant_id: @participant.id, penalty_points: penalties[symbol])
    end
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
          scores = scores.concat(build_score_vector(responses, 'review' + round.to_s))
          scores -= [-1.0]
        end
        @grades_bar_charts[:review] = bar_chart(scores)
      else
        remove_negative_scores_and_build_charts(:review)
      end
    end
    participant_score_types.each {|symbol| remove_negative_scores_and_build_charts(symbol) }
  end

  def remove_negative_scores_and_build_charts(symbol)
    if @participant_score and @participant_score[symbol]
      scores = build_score_vector @participant_score[symbol][:assessments], symbol.to_s
      scores -= [-1.0]
      @grades_bar_charts[symbol] = bar_chart(scores)
    end
  end

  def build_score_vector(reviews, symbol)
    scores = []
    reviews.each do |review|
      scores << Answer.get_total_score(response: [review], questions: @questions[symbol.to_sym], q_types: [])
    end
    scores
  end

  # Filters all non nil values and converts them to integer
  # Returns a vector
  def calculate_average_vector(scores)
    scores[:teams].reject! {|_k, v| v[:scores][:avg].nil? }
    scores[:teams].map {|_k, v| v[:scores][:avg].to_i }
  end

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

  def self_review_finished?
    participant = Participant.find(params[:id])
    assignment = participant.try(:assignment)
    # Below is only false when self review is enabled and not submitted
    return ! ( assignment.try(:is_selfreview_enabled) and unsubmitted_self_review?(participant.try(:id)) )
  end

  def mean(array)
    array.inject(0) {|sum, x| sum += x } / array.size.to_f
  end
end
