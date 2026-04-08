module GradesHelper
  include PenaltyHelper
  # Render the title
  def accordion_title(last_topic, new_topic)
    if last_topic.nil?
      # this is the first accordion
      render partial: 'response/accordion', locals: { title: new_topic, is_first: true }
    elsif !new_topic.eql? last_topic
      # render new accordion
      render partial: 'response/accordion', locals: { title: new_topic, is_first: false }
    end
  end

  def score_vector(reviews, symbol)
    scores = []
    reviews.each do |review|
      scores << Response.score(response: [review], questions: @questions[symbol.to_sym], q_types: [])
    end
    scores
  end

  # This function removes negative scores and build charts
  def charts(symbol)
    if @participant_score && @participant_score[symbol]
      scores = score_vector @participant_score[symbol][:assessments], symbol.to_s
      scores.select! { |score| score > 0 }
      @grades_bar_charts[symbol] = GradesController.bar_chart(scores)
    end
  end

  # Filters all non nil values and converts them to integer
  # Returns a vector
  def vector(scores)
    scores[:teams].reject! { |_k, v| v[:scores][:avg].nil? }
    scores[:teams].map { |_k, v| v[:scores][:avg].to_i }
  end

  # This function returns the average
  def mean(array)
    array.inject(0) { |sum, x| sum + x } / array.size.to_f
  end

  # This function returns the penalty attributes
  def attributes(_participant)
    deadline_type_id = [1, 2, 5]
    penalties_symbols = %i[submission review meta_review]
    deadline_type_id.zip(penalties_symbols).each do |id, symbol|
      CalculatedPenalty.create(deadline_type_id: id, participant_id: @participant.id, penalty_points: penalties[symbol])
    end
  end

  # This function calculates all the penalties
  def penalties(assignment_id)
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
        attributes(@participant) if calculate_for_participants
      end
      assign_all_penalties(participant, penalties)
    end
    @assignment[:is_penalty_calculated] = true unless @assignment.is_penalty_calculated
  end

  def has_team_and_metareview?
    if params[:action] == 'view'
      @assignment = Assignment.find(params[:id])
      @assignment_id = @assignment.id
    elsif %w[view_my_scores view_review].include? params[:action]
      @assignment_id = Participant.find(params[:id]).parent_id
    end
    has_team = @assignment.max_team_size > 1
    has_metareview = AssignmentDueDate.exists?(parent_id: @assignment_id, deadline_type_id: 5)
    true_num = if has_team && has_metareview
                 2
               elsif has_team || has_metareview
                 1
               else
                 0
               end
    { has_team: has_team, has_metareview: has_metareview, true_num: true_num }
  end

  def get_css_style_for_hamer_reputation(reputation_value)
    css_class = if reputation_value < 0.5
                  'c1'
                elsif (reputation_value >= 0.5) && (reputation_value <= 1)
                  'c2'
                elsif  (reputation_value > 1) && (reputation_value <= 1.5)
                  'c3'
                elsif  (reputation_value > 1.5) && (reputation_value <= 2)
                  'c4'
                else
                  'c5'
                end
    css_class
  end

  def get_css_style_for_lauw_reputation(reputation_value)
    css_class = if reputation_value < 0.2
                  'c1'
                elsif (reputation_value >= 0.2) && (reputation_value <= 0.4)
                  'c2'
                elsif  (reputation_value > 0.4) && (reputation_value <= 0.6)
                  'c3'
                elsif  (reputation_value > 0.6) && (reputation_value <= 0.8)
                  'c4'
                else
                  'c5'
                end
    css_class
  end

  def view_heatgrid(participant_id, type)
    # get participant, team, questionnaires for assignment.
    @participant = AssignmentParticipant.find(participant_id)
    @assignment = @participant.assignment
    @team = @participant.team
    @team_id = @team.id
    @type = type
    questionnaires = @assignment.questionnaires
    @vmlist = []

    # loop through each questionnaire, and populate the view model for all data necessary
    # to render the html tables.
    questionnaires.each do |questionnaire|
      @round = if @assignment.varying_rubrics_by_round? && questionnaire.type == 'ReviewQuestionnaire'
                 AssignmentQuestionnaire.find_by(assignment_id: @assignment.id, questionnaire_id: questionnaire.id).used_in_round
               end
      next unless questionnaire.type == type

      vm = VmQuestionResponse.new(questionnaire, @assignment, @round)
      questions = questionnaire.questions
      vm.add_questions(questions)
      vm.add_team_members(@team)
      vm.add_reviews(@participant, @team, @assignment.varying_rubrics_by_round?)
      vm.number_of_comments_greater_than_10_words
      @vmlist << vm
    end
    # @current_role_name = current_role_name/
    render 'grades/view_heatgrid.html.erb'
  end

  def restricted_grades_questionnaire?(questionnaire_display_type)
    ['Metareview', 'Author Feedback', 'Teammate Review'].include?(questionnaire_display_type)
  end

  # Controls whether a questionnaire section should be visible in the grades view.
  # Restricted questionnaire types are hidden unless the current user is teaching
  # staff for the assignment (instructor or mapped TA).
  def show_grades_questionnaire?(questionnaire_display_type, assignment = @assignment)
    return true unless restricted_grades_questionnaire?(questionnaire_display_type)

    assignment&.id && current_user_teaching_staff_of_assignment?(assignment.id)
  end

  # Determines whether reviewer identity can be displayed for a review column.
  # Teaching staff for the assignment can always see identities; non-staff users
  # are further constrained by questionnaire type and assignment anonymity rules.
  def show_grades_reviewer_identity?(assignment, questionnaire_display_type, role_name = @current_role_name)
    return true if assignment&.id && current_user_teaching_staff_of_assignment?(assignment.id)
    return false if restricted_grades_questionnaire?(questionnaire_display_type)

    !assignment.is_anonymous
  end

  # Returns the header label shown for each review column in the heatgrid.
  # Uses a neutral "Review N" label when identity should be hidden, and resolves
  # the actual reviewer/reviewee full name only when identity disclosure is allowed.
  def grades_reviewer_label(review, questionnaire_display_type, index, assignment, role_name = @current_role_name)
    return "Review #{index + 1}" unless show_grades_reviewer_identity?(assignment, questionnaire_display_type, role_name)

    response_map = Response.find(review.id).response_map
    participant_id = if questionnaire_display_type == 'Author Feedback'
                       response_map.reviewee_id
                     else
                       response_map.reviewer_id
                     end

    user = User.find(Participant.find(participant_id).user_id)
    user.fullname(session[:ip]).to_s
  end

  def type_and_max(row)
    question = Question.find(row.question_id)
    if question.type == 'Checkbox'
      10_003
    elsif question.is_a? ScoredQuestion
      return 9311 + row.question_max_score
    else
      9998
    end
  end

  def underlined?(score)
    'underlined' if score.comment.present?
  end

  def retrieve_questions(questionnaires, assignment_id)
    questions = {}
    questionnaires.each do |questionnaire|
      round = AssignmentQuestionnaire.where(assignment_id: assignment_id, questionnaire_id: questionnaire.id).first.used_in_round
      questionnaire_symbol = if round.nil?
                               questionnaire.symbol
                             else
                               (questionnaire.symbol.to_s + round.to_s).to_sym
                             end
      questions[questionnaire_symbol] = questionnaire.questions
    end
    questions
  end
end
