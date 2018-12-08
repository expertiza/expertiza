class GradesController < ApplicationController
  helper :file
  helper :submitted_content
  helper :penalty
  include PenaltyHelper
  include StudentTaskHelper
  include AssignmentHelper

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
    @questions = {}
    questionnaires = @assignment.questionnaires
    if @assignment.varying_rubrics_by_round?
      retrieve_questions questionnaires
    else # if this assignment does not have "varying rubric by rounds" feature
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

  # This method is used to retrieve questions for different review rounds
  def retrieve_questions(questionnaires)
    questionnaires.each do |questionnaire|
      round = AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id: questionnaire.id).first.used_in_round
      questionnaire_symbol = if !round.nil?
                               (questionnaire.symbol.to_s + round.to_s).to_sym
                             else
                               questionnaire.symbol
                             end
      @questions[questionnaire_symbol] = questionnaire.questions
    end
  end

  def view_my_scores
    @participant = AssignmentParticipant.find(params[:id])
    @team_id = TeamsUser.team_id(@participant.parent_id, @participant.user_id)
    return if redirect_when_disallowed
    @assignment = @participant.assignment
    @questions = {} # A hash containing all the questions in all the questionnaires used in this assignment
    questionnaires = @assignment.questionnaires
    retrieve_questions questionnaires
    # @pscore has the newest versions of response for each response map, and only one for each response map (unless it is vary rubric by round)
    @pscore = @participant.scores(@questions)
    make_chart
    @topic_id = SignedUpTeam.topic_id(@participant.assignment.id, @participant.user_id)
    @stage = @participant.assignment.get_current_stage(@topic_id)
    calculate_all_penalties(@assignment.id)
    # prepare feedback summaries
    summary_ws_url = WEBSERVICE_CONFIG["summary_webservice_url"]
    sum = SummaryHelper::Summary.new.summarize_reviews_by_reviewee(@questions, @assignment, @team_id, summary_ws_url)
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
    @questions = {}
    questionnaires = @assignment.questionnaires
    retrieve_questions questionnaires
    @pscore = @participant.scores(@questions)
    @vmlist = []

    # loop through each questionnaire, and populate the view model for all data necessary
    # to render the html tables.
    counter_for_same_rubric = 0
    questionnaires.each do |questionnaire|
      @round = nil
      if @assignment.varying_rubrics_by_round? && questionnaire.type == "ReviewQuestionnaire"
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
      vm.add_reviews(@participant, @team, @assignment.varying_rubrics_by_round?)
      vm.get_number_of_comments_greater_than_10_words
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
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
    redirect_to controller: 'assignments', action: 'list_submissions', id: @team.parent_id
  end

  def get_statuses_for_pull_request(ref)
    url = "https://api.github.com/repos/expertiza/expertiza/commits/" + ref + "/status"
    ActiveSupport::JSON.decode(Net::HTTP.get(URI(url)))
  end

  def retrieve_pull_request_data(pull_links)
    pull_links.each do |hyperlink|
      submission_hyperlink_tokens = hyperlink.split('/')
      hyperlink_data = {}
      hyperlink_data["pull_request_number"] = submission_hyperlink_tokens.pop
      @merge_status[hyperlink_data["pull_request_number"].to_i] = nil
      submission_hyperlink_tokens.pop
      hyperlink_data["repository_name"] = submission_hyperlink_tokens.pop
      hyperlink_data["owner_name"] = submission_hyperlink_tokens.pop
      github_data = get_pull_request_details_pull(hyperlink_data)
      parse_github_data_pull(github_data)
    end
  end

  def retrieve_repository_data(repo_links)
    repo_links.each do |hyperlink|
      submission_hyperlink_tokens = hyperlink.split('/')
      hyperlink_data = {}
      hyperlink_data["repository_name"] = submission_hyperlink_tokens[4]
      next if hyperlink_data["repository_name"] == "servo" || hyperlink_data["repository_name"] == "expertiza"
      hyperlink_data["owner_name"] = submission_hyperlink_tokens[3]
      github_data = get_github_data_repo(hyperlink_data)
      parse_github_data_repo(github_data)
    end
  end

  def retrieve_github_data(team_links)
    pull_links = team_links.select do |link|
      link.match(/pull/) && link.match(/github.com/)
    end
    if pull_links.length > 0
      retrieve_pull_request_data(pull_links)
    else
      repo_links = team_links.select do |link|
        link.match(/github.com/)
      end
      retrieve_repository_data(repo_links)
    end
  end

  def view_github_metrics
    if session["github_access_token"].nil?
      session["participant_id"] = params[:id]
      session["github_view_type"] = "view_submissions"
      redirect_to authorize_github_grades_path
      return
    end

    @headRefs = {}
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

    retrieve_github_data(@team.hyperlinks)

    @authors=@authors.keys
    @dates=@dates.keys.sort

    @headRefs.each do |pull_number, ref|
      @check_statuses[pull_number] = get_statuses_for_pull_request(ref)
    end
  end

  def authorize_github
    redirect_to "https://github.com/login/oauth/authorize?client_id=#{GITHUB_CONFIG['client_key']}"
  end

  def get_github_data_repo(hyperlink_data)
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
                      }"}
    return make_github_api_request(data)
  end

  def get_pull_request_details(hyperlink_data)
    is_initial_page = true
    data = get_query(is_initial_page, hyperlink_data)
    response_data = make_github_api_request(data)

    @has_next_page = response_data["data"]["repository"]["pullRequest"]["commits"]["pageInfo"]["hasNextPage"]
    if @has_next_page
      is_initial_page = false
    end
    @end_cursor = response_data["data"]["repository"]["pullRequest"]["commits"]["pageInfo"]["endCursor"]

    while @has_next_page
      data = get_query(is_initial_page, hyperlink_data)
      new_response_data = make_github_api_request(data)
      response_data["data"]["repository"]["pullRequest"]["commits"]["edges"].push(*new_response_data["data"]["repository"]["pullRequest"]["commits"]["edges"])
      @has_next_page = new_response_data["data"]["repository"]["pullRequest"]["commits"]["pageInfo"]["hasNextPage"]
      @end_cursor = new_response_data["data"]["repository"]["pullRequest"]["commits"]["pageInfo"]["endCursor"]
    end

    return response_data
  end

  def parse_github_data_pull(github_data)
    set_team_statistics(github_data)
    commit_objects = github_data["data"]["repository"]["pullRequest"]["commits"]["edges"]
    commit_objects.each do |commit_object|
      author_name = commit_object["node"]["commit"]["author"]["name"];
      commit_date = commit_object["node"]["commit"]["committedDate"].to_s;
      commit_date = commit_date[0, 10]
      unless @authors.key?(author_name)
        @authors[author_name] = 1
      end
      unless @dates.key?(commit_date)
        @dates[commit_date] = 1
      end
      unless @parsed_data[author_name]
        @parsed_data[author_name] = {}
      end
      if @parsed_data[author_name][commit_date]
        @parsed_data[author_name][commit_date] = @parsed_data[author_name][commit_date] + 1
      else
        @parsed_data[author_name][commit_date] = 1
      end
    end
    organize_commit_dates
  end

  def parse_github_data_repo(github_data)
    commit_objects = github_data["data"]["repository"]["ref"]["target"]["history"]["edges"]
    commit_objects.each do |commit_object|
      author_name = commit_object["node"]["author"]["name"];
      commit_date = commit_object["node"]["author"]["date"].to_s;
      commit_date = commit_date[0, 10]
      unless @authors.key?(author_name)
        @authors[author_name] = 1
      end
      unless @dates.key?(commit_date)
        @dates[commit_date] = 1
      end
      unless @parsed_data[author_name]
        @parsed_data[author_name] = {}
      end
      if @parsed_data[author_name][commit_date]
        @parsed_data[author_name][commit_date] = @parsed_data[author_name][commit_date] + 1
      else
        @parsed_data[author_name][commit_date] = 1
      end
    end
    organize_commit_dates
  end

  def make_github_api_request(data)
    url = "https://api.github.com/graphql"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.path, initheader = {'Authorization' => 'Bearer' + ' ' + session["github_access_token"]})
    request.body = data.to_json
    http.request(request)
    response = http.request(request)
    response_body = ActiveSupport::JSON.decode(response.body.to_s)
    return response_body
  end

  def organize_commit_dates
    @dates.each do |date, commit_count|
      @parsed_data.each do |author, commits|
        unless commits[date]
          commits[date] = 0
        end
      end
    end
    @parsed_data.each {|author, commits| @parsed_data[author] = Hash[commits.sort_by {|date, commit_count| date}]}
  end

  def set_team_statistics(github_data)
    @total_additions += github_data["data"]["repository"]["pullRequest"]["additions"]
    @total_deletions += github_data["data"]["repository"]["pullRequest"]["deletions"]
    @total_files_changed += github_data["data"]["repository"]["pullRequest"]["changedFiles"]
    @total_commits += github_data["data"]["repository"]["pullRequest"]["commits"]["totalCount"]
    pull_request_number = github_data["data"]["repository"]["pullRequest"]["number"]
    @headRefs[pull_request_number] = github_data["data"]["repository"]["pullRequest"]["headRefOid"]

    if github_data["data"]["repository"]["pullRequest"]["merged"]
      @merge_status[pull_request_number] = "MERGED"
    else
      @merge_status[pull_request_number] = github_data["data"]["repository"]["pullRequest"]["mergeable"]
    end
  end

  def get_query(is_initial_page, hyperlink_data)

    if is_initial_page
      commit_query_line = "commits(first:10){"
    else
      commit_query_line = "commits(first:10, after:" + @end_cursor + "){"
    end

    data = {query: "query {
                            repository(owner: \"" + hyperlink_data["owner_name"] + "\", name:\"" + hyperlink_data["repository_name"] + "\") {
                              pullRequest(number: " + hyperlink_data["pull_request_number"] + ") {
                                number additions deletions changedFiles mergeable merged headRefOid
                                " + commit_query_line + "
                                  totalCount
                                  pageInfo{
                                    hasNextPage startCursor endCursor
                                  }
                                  edges{
                                    node{
                                      id
                                      commit{
                                        author{
                                          name
                                        }
                                        additions deletions changedFiles committedDate
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }"}
    return data
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
        calculate_penatly_attributes(@participant) if calculate_for_participants
      end
      assign_all_penalties(participant, penalties)
    end
    @assignment.update_attribute(:is_penalty_calculated, true) unless @assignment.is_penalty_calculated
  end

  def calculate_penatly_attributes(_participant)
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
      if @assignment.varying_rubrics_by_round?
        (1..@assignment.rounds_of_reviews).each do |round|
          responses = @pscore[:review][:assessments].select {|response| response.round == round }
          scores = scores.concat(get_scores_for_chart(responses, 'review' + round.to_s))
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
      scores = get_scores_for_chart @participant_score[symbol][:assessments], symbol.to_s
      scores -= [-1.0]
      @grades_bar_charts[symbol] = bar_chart(scores)
    end
  end

  def get_scores_for_chart(reviews, symbol)
    scores = []
    reviews.each do |review|
      scores << Answer.get_total_score(response: [review], questions: @questions[symbol.to_sym], q_types: [])
    end
    scores
  end

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

  def check_self_review_status
    participant = Participant.find(params[:id])
    assignment = participant.try(:assignment)
    if assignment.try(:is_selfreview_enabled) and unsubmitted_self_review?(participant.try(:id))
      return false
    else
      return true
    end
  end

  def mean(array)
    array.inject(0) {|sum, x| sum += x } / array.size.to_f
  end
end
