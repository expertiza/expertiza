class PopupController < ApplicationController
  include StringOperationHelper
  include AuthorizationHelper
  ASSIGNMENT_NAME_SIMILARITY_THRESHOLD = 0.50

  def action_allowed?
    current_user_has_ta_privileges?
  end

  # this can be called from "response_report" by clicking student names from instructor end.
  def author_feedback_popup
    @response_id = params[:response_id]
    @reviewee_id = params[:reviewee_id]
    first_question_in_questionnaire = Answer.where(response_id: @response_id).first
    unless @response_id.nil? || first_question_in_questionnaire.nil?
      questionnaire_id = Question.find(first_question_in_questionnaire.question_id).questionnaire_id
      questionnaire = Questionnaire.find(questionnaire_id)
      @maxscore = questionnaire.max_question_score
      @scores = Answer.where(response_id: @response_id)
      @response = Response.find(@response_id)
      @total_percentage = @response.average_score
      @sum = @response.aggregate_questionnaire_score
      @total_possible = @response.maximum_score
    end

    @maxscore = 5 if @maxscore.nil?

    unless @response_id.nil?
      participant = Participant.find(@reviewee_id)
      @user = User.find(participant.user_id)
    end
  end

  # this can be called from "response_report" by clicking team names from instructor end.
  def team_users_popup
    @ip = session[:ip]
    @sum = 0
    @team = Team.find(params[:id])
    @assignment = Assignment.find(@team.parent_id)
    @team_users = TeamsUser.where(team_id: params[:id])

    # id2 is a response_map id
    unless params[:id2].nil?
      # E1973 - we set the reviewer id either to the student's user id or the current reviewer id
      # This results from reviewers being either assignment participants or assignment teams.
      # If the reviewer is a participant, the id is currently the id of the assignment participant.
      # However, we want their user_id. This is not possible for teams, so we just return the current id
      reviewer_id = ResponseMap.find(params[:id2]).reviewer_id
      # E2060 - we had to change this if/else clause in order to properly view reports page
      @reviewer_id = if @assignment.team_reviewing_enabled
                       reviewer_id
                     else
                       Participant.find(reviewer_id).user_id
                     end
      # get the last response in each round from response_map id
      (1..@assignment.num_review_rounds).each do |round|
        response = Response.where(map_id: params[:id2], round: round).last
        instance_variable_set('@response_round_' + round.to_s, response)
        next if response.nil?

        instance_variable_set('@response_id_round_' + round.to_s, response.id)
        instance_variable_set('@scores_round_' + round.to_s, Answer.where(response_id: response.id))
        questionnaire = Response.find(response.id).questionnaire_by_answer(instance_variable_get('@scores_round_' + round.to_s).first)
        instance_variable_set('@max_score_round_' + round.to_s, questionnaire.max_question_score ||= 5)
        total_percentage = response.average_score
        total_percentage += '%' if total_percentage.is_a? Float
        instance_variable_set('@total_percentage_round_' + round.to_s, total_percentage)
        instance_variable_set('@sum_round_' + round.to_s, response.aggregate_questionnaire_score)
        instance_variable_set('@total_possible_round_' + round.to_s, response.maximum_score)
      end
    end

    all_assignments = Assignment.where(instructor_id: session[:user].id)
    @similar_assignments = []
    all_assignments.each do |assignment|
      if string_similarity(@assignment.name, assignment.name) > ASSIGNMENT_NAME_SIMILARITY_THRESHOLD
        @similar_assignments << assignment
      end
    end
    @similar_assignments = @similar_assignments.sort_by { |sim_assignment| -sim_assignment.id }
  end

  # Views tone analysis report and heatmap
  def view_review_scores_popup
    @ip = session[:ip]
    @reviewer_id = params[:reviewer_id]
    @assignment_id = params[:assignment_id]
    @review_final_versions = ReviewResponseMap.final_versions_from_reviewer(@assignment_id, @reviewer_id)
    @reviews = []
  end

  # this can be called from "response_report" by clicking reviewer names from instructor end.
  def reviewer_details_popup
    @userid = Participant.find(params[:id]).user_id
    @user = User.find(@userid)
    @id = params[:assignment_id]
  end

  # this can be called from "response_report" by clicking reviewer names from instructor end.
  def self_review_popup
    @response_id = params[:response_id]
    @user_name = params[:user_name]
    unless @response_id.nil?
      first_question_in_questionnaire = Answer.where(response_id: @response_id).first.question_id
      questionnaire_id = Question.find(first_question_in_questionnaire).questionnaire_id
      questionnaire = Questionnaire.find(questionnaire_id)
      @maxscore = questionnaire.max_question_score
      @scores = Answer.where(response_id: @response_id)
      @response = Response.find(@response_id)
      @total_percentage = @response.average_score
      @sum = @response.aggregate_questionnaire_score
      @total_possible = @response.maximum_score
    end
    @maxscore = 5 if @maxscore.nil?
  end
end
