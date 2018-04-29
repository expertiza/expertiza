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
    @assignment = Assignment.find(params[:id])
    @id = params[:id]
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

    if @assignment.varying_rubrics_by_round?
      @authors, @all_review_response_ids_round_one, @all_review_response_ids_round_two, @all_review_response_ids_round_three =
          FeedbackResponseMap.feedback_response_report(@id, "FeedbackResponseMap")
      else
        @authors, @all_review_response_ids = FeedbackResponseMap.feedback_response_report(@id, "FeedbackResponseMap")
      end

    # private functions for generating a valid highchart
    min, max, number_of_review_questions = calculate_review_questions(@assignment, questionnaires)
    team_data = get_team_data(@assignment, questionnaires, @scores)
    highchart_data = get_highchart_data(team_data, @assignment, min, max, number_of_review_questions)
    highchart_series_data, highchart_categories, highchart_colors = generate_highchart(highchart_data, min, max, number_of_review_questions)
    @flot_series_data, @flot_categories = highchart_to_flot_adapter(min, max, highchart_series_data)
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
    questionnaires.each do |questionnaire|
      @round = if @assignment.varying_rubrics_by_round? && questionnaire.type == "ReviewQuestionnaire"
                 AssignmentQuestionnaire.find_by(assignment_id: @assignment.id, questionnaire_id: questionnaire.id).used_in_round
               end
      vm = VmQuestionResponse.new(questionnaire, @assignment)
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

  def calculate_review_questions(assignment, questionnaires)
    min = 0
    max = 5

    number_of_review_questions = 0
    questionnaires.each do |questionnaire|
      next unless assignment.varying_rubrics_by_round? && questionnaire.type == "ReviewQuestionnaire" # WHAT ABOUT NOT VARYING RUBRICS?
      number_of_review_questions = questionnaire.questions.size
      min = questionnaire.min_question_score < min ? questionnaire.min_question_score : min
      max = questionnaire.max_question_score > max ? questionnaire.max_question_score : max
      break
    end
    [min, max, number_of_review_questions]
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

  def get_team_data(assignment, questionnaires, scores)
    team_data = []
    for index in 0..scores[:teams].length - 1
      participant = AssignmentParticipant.find(scores[:teams][index.to_s.to_sym][:team].participants.first.id)
      team = participant.team
      vmlist = []

      questionnaires.each do |questionnaire|
        round = if assignment.varying_rubrics_by_round? && questionnaire.type == "ReviewQuestionnaire"
                  AssignmentQuestionnaire.find_by(assignment_id: assignment.id, questionnaire_id: questionnaire.id).used_in_round
                else
                  nil
                end

        vm = VmQuestionResponse.new(questionnaire, assignment)
        questions = questionnaire.questions
        vm.add_questions(questions)
        vm.add_team_members(team)
        vm.add_reviews(participant, team, assignment.varying_rubrics_by_round?)
        vm.get_number_of_comments_greater_than_10_words

        vmlist << vm
      end
      team_data << vmlist
    end
    team_data
  end

  def get_highchart_data(team_data, assignment, min, max, number_of_review_questions)
    chart_data = {}  # @chart_data is supposed to hold the general information for creating the highchart stack charts

    # Dynamic initialization
    for i in 1..assignment.rounds_of_reviews
      chart_data[i] = Hash[(min..max).map {|score| [score, Array.new(number_of_review_questions, 0)] }]
    end

    # Dynamically filling @chart_data with values (For each team, their score to each rubric in the related submission
    # round will be added to the count in the corresponded array field)
    team_data.each do |team|
      team.each do |vm|
        next if vm.round.nil?
        j = 0
        vm.list_of_rows.each do |row|
          row.score_row.each do |score|
            unless score.score_value.nil?
              chart_data[vm.round][score.score_value][j] += 1
            end
          end
          j += 1
        end
      end
    end
    chart_data
  end

  def generate_highchart(chart_data, min, max, number_of_review_questions)
    # Here we actually build the 'series' array which will be used directly in the highchart Object in the _team_charts view file
    # This array holds the actual data of our chart with legend names
    highchart_series_data = []
    chart_data.each do |round, scores|
      scores.to_a.reverse.to_h.each do |score, rubric_distribution|
        highchart_series_data.push(name: "Score #{score} - Submission #{round}", data: rubric_distribution, stack: "S#{round}")
      end
    end

    # Here we dynamically creates the categories which will be used later in the highchart Object
    highchart_categories = []
    for i in 1..number_of_review_questions
       highchart_categories.push("Rubric #{i}")
    end

    # Here we dynamically creates an array of the colors which the highchart uses to show the stack charts and rotate on
    # Currently we create 6 different colors based on the assumption that we always have scores from 0 to 5
    # Future Works: Maybe adding the minimum score and maximum score instead of the hard-coded 0..5 range
    highchart_colors = []
    for _i in min..max
      highchart_colors.push("\##{sprintf('%06x', (rand * 0xffffff))}")
    end
    [highchart_series_data, highchart_categories, highchart_colors]
  end

  def highchart_to_flot_adapter(min, max, highchart_series_data)
    flot_series_data = []
    flot_categories = []
    data = []
    flot_data = []
    j = 0
    k = 0
    rounds = 0
    review_round = highchart_series_data.to_a.reverse[0][:stack]
    flot_colors = ["#FF0000", "#FF6600", "#FFCC00", "#CCFF00", "#66FF00", "#00FF00"]
    highchart_series_data.to_a.reverse.each do |element|
      data = element[:data]
      stack = element[:stack]
      round = stack.scan(/[0-9]/)
      unless stack.eql?(review_round)
        rounds += 1
        review_round = stack
        k = 0
      end
      flot_categories.push([k + (rounds*data.size), "Rubric \##{k} Round \##{round[0]}"])
      k += 1
      for i in 0..data.size-1
        if rounds > 0
          flot_series_data[j][:data].push([i + (rounds*data.size), data[i]])
        end
        if rounds.zero?
          flot_data.push([i, data[i]])
        end
      end
      flot_series_data.push(data: flot_data, color: flot_colors[j]) if rounds.zero?

      j += 1
      if j > max
        j = 0
      end
      flot_data = []
      data = []
    end

    num_reviewees = 0
    for i in 0..flot_series_data[0][:data].size-1
      for j in 0..flot_series_data.size - 1
        num_reviewees += flot_series_data[j][:data][i][1]
      end
      for j in 0..flot_series_data.size - 1
        unless num_reviewees.zero?
          flot_series_data[j][:data][i][1] /= num_reviewees.to_f
          flot_series_data[j][:data][i][1] *= 100.0
        end
      end
      num_reviewees = 0
    end
    [flot_series_data, flot_categories]
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
