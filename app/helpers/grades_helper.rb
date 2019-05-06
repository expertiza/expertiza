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
      @round = if @assignment.varying_rubrics_by_round? && questionnaire.type == "ReviewQuestionnaire"
                 AssignmentQuestionnaire.find_by(assignment_id: @assignment.id, questionnaire_id: questionnaire.id).used_in_round
               else
                 nil
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
end
