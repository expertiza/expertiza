module GradesHelper
  # Render the title
  def accordion_title(last_topic, new_topic)
    if last_topic.nil?
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
      scores << Response.assessment_score(response: [review], questions: @questions[symbol.to_sym], q_types: [])
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

  # Added by project E2083 in Fall 2020.  Refactored code used to add a response
  # to the view model that generates heat grids for review scores. The view model
  # was implemented by a previous project and can be found in any of the model
  # files that start with "vm_".
  def add_response_to_vmlist(participant, assignment, team, questionnaire, vmlist, round)
    vm = VmQuestionResponse.new(questionnaire, assignment, round)
    vmquestions = questionnaire.questions
    vm.add_questions(vmquestions)
    vm.add_team_members(team)
    vm.add_reviews(participant, team, assignment.vary_by_round)
    vm.number_of_comments_greater_than_10_words
    vmlist << vm
  end

  # Added by project E2083 in Fall 2020.  Adds functionality to check for and
  # add Revision Plan responses to heatgrid view.
  def add_revision_plan_response(participant, assignment, team_id, vmlist, used_in_round, round)
    rp_questionnaire = RevisionPlanTeamMap.find_by(team: Team.find(team_id), used_in_round: used_in_round).try(:questionnaire)
    if rp_questionnaire
      add_response_to_vmlist(participant, assignment, Team.find(team_id), rp_questionnaire, vmlist, round)
    end
  end

  # Added by project E2083 in Fall 2020.  Adds functionality for finding and
  # adding the last Revision Plan when not varying by round.
  def add_last_revision_plan_response(participant, assignment, team_id, vmlist, round)
    if assignment.get_current_stage == "Finished"
      current_round = assignment.rounds_of_reviews
    else
      reviewees_topic = SignedUpTeam.topic_id_by_team_id(participant.id)
      current_round = assignment.number_of_current_round(reviewees_topic)
    end
    add_revision_plan_response(participant, assignment, team_id, vmlist, current_round, round)
  end

  # Added by project E2083 in Fall 2020.  Refactored code used in multiple views
  # and in the grades_controller (specifically view_heatgrid and view_team).
  def generate_heatgrid(participant, assignment, team, team_id, questionnaires, vmlist)
    # loop through each questionnaire, and populate the view model for all data necessary
    # to render the html tables.
    @round = nil
    counter_for_revisions = -1
    counter_for_same_rubric = 0
    questionnaires.each do |questionnaire|
      if assignment.vary_by_round? && questionnaire.type == "ReviewQuestionnaire"
        questionnaires = AssignmentQuestionnaire.where(assignment_id: assignment.id, questionnaire_id: questionnaire.id)
        if questionnaires.count > 1
          @round = questionnaires[counter_for_same_rubric].used_in_round
          counter_for_same_rubric += 1
        else
          @round = questionnaires[0].used_in_round
          counter_for_same_rubric = 0
        end
      end
      add_response_to_vmlist(participant, assignment, team, questionnaire, vmlist, @round)
      # Finds RevisionPlanQuestionnaire, if any
      if assignment.is_revision_planning_enabled? && assignment.vary_by_round?
        add_revision_plan_response(participant, assignment, team_id, vmlist, counter_for_revisions, @round)
        counter_for_revisions += 1
      elsif assignment.is_revision_planning_enabled? && questionnaire == questionnaires.last
        add_last_revision_plan_response(participant, assignment, team_id, vmlist, @round)
      end
    end
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

    generate_heatgrid(@participant, @assignment, @team, @team_id, questionnaires, @vmlist)

    render "grades/view_heatgrid.html.erb"
  end

  def type_and_max(row)
    question = Question.find(row.question_id)
    if question.type == "Checkbox"
      10_003
    elsif question.is_a? ScoredQuestion
      return 9311 + row.question_max_score
    else
      9998
    end
  end

  def underlined?(score)
    "underlined" if score.comment.present?
  end

  def retrieve_questions(questionnaires, assignment_id)
    questions = {}
    counter_for_same_rubric = 0
    assignment = Assignment.find(assignment_id)
    questionnaires.each do |questionnaire|
      if assignment.vary_by_round? && questionnaire.type == "ReviewQuestionnaire"
        questionnaires = AssignmentQuestionnaire.where(assignment_id: assignment_id, questionnaire_id: questionnaire.id)
        if questionnaires.count > 1
          round = questionnaires[counter_for_same_rubric].used_in_round
          counter_for_same_rubric += 1
        else
          round = questionnaires[0].used_in_round
          counter_for_same_rubric = 0
        end
      else
        round = AssignmentQuestionnaire.where(assignment_id: assignment_id, questionnaire_id: questionnaire.id).first.used_in_round
      end
      questionnaire_symbol = if !round.nil?
                               (questionnaire.symbol.to_s + round.to_s).to_sym
                             else
                               questionnaire.symbol
                             end
      questions[questionnaire_symbol] = questionnaire.questions
    end
    questions
  end
end
