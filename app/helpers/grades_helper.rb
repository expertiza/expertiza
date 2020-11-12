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

 ######################################## E2078 ########################################

 ## calc_final_score_Vossen_formula(avg_peer_review_score, self_review_score, w, l)
 # Called from grades_controller.rb
 # Inputs: 
        # avg_peer_review_score and avg_self_review_score, both calculated in response.rb and called in grades_controller.rb
        # w - chosen from the UI when Vossen formula is chosen and so hard-coded in the controller, the weight for peer reviews in final grade (inverse, 1-w, is weight for self/peer review deviation)
        # l - a parameter in the Vossen formula, to determine to what extent peer reviews can differ from self reviews before impacting grade
          # this is also hard-coded because it depends on the assignment grading scale, usually we scale out of 5, so l = 0.25 because the minimum deviation is 1 / (max score -1) and max score is 5
          # if we have an peer review where we review out of 100 instead of 5, consider decreasing for refinement. Again: hard-code in controller
 # Outputs: the final grade for the assignment using the formula
 def calc_final_score_Vossen_formula(avg_peer_review_score, avg_self_review_score, w, l)
  self_score = 0;
  if (avg_peer_review_score - avg_self_review_score).abs() / avg_peer_review_score <= l
    self_score = (avg_peer_review_score.to_f * (1 + ((avg_peer_review_score.to_f - avg_self_review_score.to_f).abs() / avg_peer_review_score.to_f)))
  else
    self_score = (avg_peer_review_score.to_f * (1 - ((avg_peer_review_score.to_f - avg_self_review_score.to_f).abs() / avg_peer_review_score.to_f)))
  end
  grade = w * (avg_peer_review_score) + (1 - w) * self_score
  return grade.round(2)
end

## derive_final_score(formula_choice)
# Called from grades_controller.rb
# Derives a final score for an assignment based on 1) avg peer review score 2) average self review score 3) formula choice on how to combine 1) and 2)
# Inputs: formula_choice (passed from _review_strategy  partial - the review strategy tab on the edit assignment page)
# Outputs: new_derived_score  - the final grade for the assignment
def peer_self_review_score(formula_choice)
  # E2078 start
  if @assignment.is_selfreview_enabled?
    @self_review_scores = @participant.scores(@questions, true)

    # calculate avg_self_review_score as an average of ratings given to self
    @avg_self_review_score = Rscore.new(@self_review_scores, :review).my_avg || 0

    # calculate actual_score as an average of ratings given by peers
    avg_peer_review_score = Rscore.new(@pscore, :review).my_avg || 0

    # formula_choice is passed from _review_strategy  partial - the review strategy tab on the edit assignment page
    if formula_choice == "None"
      peer_self_review_score = calc_final_score_Vossen_formula(avg_peer_review_score, @avg_self_review_score, 1, 0.25).to_s
    elsif formula_choice == "Vossen Formula, w = 5%"
      peer_self_review_score = calc_final_score_Vossen_formula(avg_peer_review_score, @avg_self_review_score, 0.95, 0.25).to_s
    elsif formula_choice == "Vossen Formula, w = 10%"
      peer_self_review_score = calc_final_score_Vossen_formula(avg_peer_review_score, @avg_self_review_score, 0.90, 0.25).to_s
    elsif formula_choice == "Vossen Formula, w = 15%"
      peer_self_review_score = calc_final_score_Vossen_formula(avg_peer_review_score, @avg_self_review_score, 0.85, 0.25).to_s
    elsif formula_choice == "Vossen Formula, w = 20%"
      peer_self_review_score = calc_final_score_Vossen_formula(avg_peer_review_score, @avg_self_review_score, 0.80, 0.25).to_s
    end
  end
  return peer_self_review_score
  # E2078 end
end
######################################## E2078 ########################################

end
