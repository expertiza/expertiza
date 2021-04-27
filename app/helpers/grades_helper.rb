module GradesHelper
  # Render the title
  def get_accordion_title(last_topic, new_topic)
    if last_topic.eql? nil
      # this is the first accordion
      render partial: "response/accordion", locals: {title: new_topic, is_first: true}
    elsif !new_topic.eql? last_topic
      # render new accordion
      render partial: "response/accordion", locals: {title: new_topic, is_first: false}
    end
  end

  def score_vector(reviews, symbol)
    scores = []
    reviews.each do |review|
      scores << Answer.get_total_score(response: [review], questions: @questions[symbol.to_sym], q_types: [])
    end
    scores
  end

  # This function removes negative scores and build charts
  def charts(symbol)
    if @participant_score and @participant_score[symbol]
      scores = score_vector @participant_score[symbol][:assessments], symbol.to_s
      scores.select! { |score| score > 0 }
      @grades_bar_charts[symbol] = GradesController.bar_chart(scores)
    end
  end

  # Filters all non nil values and converts them to integer
  # Returns a vector
  def vector(scores)
    scores[:teams].reject! {|_k, v| v[:scores][:avg].nil? }
    scores[:teams].map {|_k, v| v[:scores][:avg].to_i }
  end

  # This function returns the average
  def mean(array)
    array.inject(0) {|sum, x| sum + x } / array.size.to_f
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
    if params[:action] == "view"
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
    {has_team: has_team, has_metareview: has_metareview, true_num: true_num}
  end

  def get_css_style_for_hamer_reputation(reputation_value)
    css_class = if reputation_value < 0.5
                  'c1'
                elsif reputation_value >= 0.5 and reputation_value <= 1
                  'c2'
                elsif  reputation_value > 1 and reputation_value <= 1.5
                  'c3'
                elsif  reputation_value > 1.5 and reputation_value <= 2
                  'c4'
                else
                  'c5'
                end
    css_class
  end

  def get_css_style_for_lauw_reputation(reputation_value)
    css_class = if reputation_value < 0.2
                  'c1'
                elsif reputation_value >= 0.2 and reputation_value <= 0.4
                  'c2'
                elsif  reputation_value > 0.4 and reputation_value <= 0.6
                  'c3'
                elsif  reputation_value > 0.6 and reputation_value <= 0.8
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
      @round = if @assignment.vary_by_round && questionnaire.type == "ReviewQuestionnaire"
                 AssignmentQuestionnaire.find_by(assignment_id: @assignment.id, questionnaire_id: questionnaire.id).used_in_round
               else
                 nil
               end
      next unless questionnaire.type == type
      vm = VmQuestionResponse.new(questionnaire, @assignment, @round)
      questions = questionnaire.questions
      vm.add_questions(questions)
      vm.add_team_members(@team)
      vm.add_reviews(@participant, @team, @assignment.vary_by_round)
      vm.number_of_comments_greater_than_10_words
      @vmlist << vm
    end
    # @current_role_name = current_role_name/
    render "grades/view_heatgrid.html.erb"
  end

  def type_and_max(row)
    question = Question.find(row.question_id)
    if question.type == "Checkbox"
      return 10_003
    elsif question.is_a? ScoredQuestion
      return 9311 + row.question_max_score
    else
      return 9998
    end
  end

  def underlined?(score)
    return "underlined" if score.comment.present?
  end

  def retrieve_questions(questionnaires, assignment_id)
    questions = {}
    questionnaires.each do |questionnaire|
      round = AssignmentQuestionnaire.where(assignment_id: assignment_id, questionnaire_id: questionnaire.id).first.used_in_round
      questionnaire_symbol = if !round.nil?
                               (questionnaire.symbol.to_s + round.to_s).to_sym
                             else
                               questionnaire.symbol
                             end
      questions[questionnaire_symbol] = questionnaire.questions
    end
    questions
  end

  def metrics_table(team)
    metrics = Metric.where("team_id = ?", team)

    unless metrics.nil?
      data_array = {}
      metrics.each do |metric|
        unless metric.participant_id.nil?
          #Lookup user if ID was stored at query time
          user = User.find(metric.participant_id)
        else
          # If not, try to find user by recently-entered github ID
          user = User.find_by_github_id(metric.github_id)
          # If still not, try to find user by their NCSU email if it's the same as github.com
          user = User.find_by_email(metric.github_id) if user.nil?
        end

        #Finally, if user was not found, handle by using github email in the
        # Student Name field, or Student Fullname if found.
        user_fullname = user.nil? ? "Github Email: " + metric.github_id : user.fullname
        if data_array[user_fullname]
          data_array[user_fullname][:commits] += metric.total_commits
        else
          data_array[user_fullname] = {}
          data_array[user_fullname][:commits] = metric.total_commits
        end
      end
      map = data_array.map {|k,v| v[:commits]}
      max = map.max
      min = map.min
      mean = map.sum / map.size
      data_array.each do |key, element|
        case element[:commits]
        when min
          element[:color] = "c1"
        when max
          element[:color] = "c5"
        when mean
          element[:color] = "c3"
        when min..mean
          element[:color] = "c2"
        when mean .. max
          element[:color] = "c4"
        else
          element[:color] = "c3"
        end
      end
      data_array
    else
      nil
    end
  end
end
