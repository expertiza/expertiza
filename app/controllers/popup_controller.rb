class PopupController < ApplicationController
  def action_allowed?
    ['Super-Administrator',
     'Administrator',
     'Instructor',
     'Teaching Assistant'].include? current_role_name
  end

  # this can be called from "response_report" by clicking on the View Metrics.
  def view_review_metrics_popup
    @reviewer_id = params[:reviewer_id]
    @assignment_id = params[:assignment_id]
    #@metrics = ReviewMetric.calculate_metrics_for_instructor(@assignment_id, @reviewerid)

    # These variables are used by the flash message to display statistics to users
    @responses = ResponseMap.where(reviewed_object_id: @assignment_id, reviewer_id: @reviewer_id)

    @responses.each do |my_response|
      @res = Response.where(map_id: my_response.id)
      if @res != nil
        @record = Response.where(map_id: my_response.id)
        @my_map = my_response.id
      end
    end
    @all_records = Response.all
    @map = ResponseMap.all
    @review_record = ReviewMetricMapping.all
    @review_metrics = ReviewMetric.all
    @my_reviewer_id = params[@reviewer_id]

    @percentages = calculate_percentages(@assignment_id)

    render 'popup/review_metric_popup'
  end

  # this can be called from "response_report" by clicking student names from instructor end.
  def author_feedback_popup
    @response_id = params[:response_id]
    @reviewee_id = params[:reviewee_id]
    unless @response_id.nil?
      first_question_in_questionnaire = Answer.where(response_id: @response_id).first.question_id
      questionnaire_id = Question.find(first_question_in_questionnaire).questionnaire_id
      questionnaire = Questionnaire.find(questionnaire_id)
      @maxscore = questionnaire.max_question_score
      @scores = Answer.where(response_id: @response_id)
      @response = Response.find(@response_id)
      @total_percentage = @response.get_average_score
      @sum = @response.get_total_score
      @total_possible = @response.get_maximum_score
    end

    @maxscore = 5 if @maxscore.nil?

    unless @response_id.nil?
      participant = Participant.find(@reviewee_id)
      @user = User.find(participant.user_id)
    end
  end

  # this can be called from "response_report" by clicking team names from instructor end.
  def team_users_popup
    @sum = 0
    @team = Team.find(params[:id])
    @assignment = Assignment.find(@team.parent_id)
    @team_users = TeamsUser.where(team_id: params[:id])

    # id2 is a response_map id
    unless params[:id2].nil?
      participant_id = ResponseMap.find(params[:id2]).reviewer_id
      @reviewer_id = Participant.find(participant_id).user_id
      # get the last response in each round from response_map id
      (1..@assignment.num_review_rounds).each do |round|
        response = Response.where(map_id: params[:id2], round: round).last
        instance_variable_set('@response_round_' + round.to_s, response)
        next if response.nil?
        instance_variable_set('@response_id_round_' + round.to_s, response.id)
        instance_variable_set('@scores_round_' + round.to_s, Answer.where(response_id: response.id))
        questionnaire = Response.find(response.id).questionnaire_by_answer(instance_variable_get('@scores_round_' + round.to_s).first)
        instance_variable_set('@max_score_round_' + round.to_s, questionnaire.max_question_score ||= 5)
        total_percentage = response.get_average_score
        total_percentage += '%' if total_percentage.is_a? Float
        instance_variable_set('@total_percentage_round_' + round.to_s, total_percentage)
        instance_variable_set('@sum_round_' + round.to_s, response.get_total_score)
        instance_variable_set('@total_possible_round_' + round.to_s, response.get_maximum_score)
      end
    end
  end

  def participants_popup
    @sum = 0
    @count = 0
    @participantid = params[:id]
    @uid = Participant.find(params[:id]).user_id
    @assignment_id = Participant.find(params[:id]).parent_id
    @user = User.find(@uid)
    @myuser = @user.id
    @temp = 0
    @maxscore = 0

    if params[:id2].nil?
      @scores = nil
    else
      @reviewid = Response.find_by_map_id(params[:id2]).id
      @pid = ResponseMap.find(params[:id2]).reviewer_id
      @reviewer_id = Participant.find(@pid).user_id
      # @reviewer_id = ReviewMapping.find(params[:id2]).reviewer_id
      @assignment_id = ResponseMap.find(params[:id2]).reviewed_object_id
      @assignment = Assignment.find(@assignment_id)
      @participant = Participant.where(["id = ? and parent_id = ? ", params[:id], @assignment_id])

      # #3
      @revqids = AssignmentQuestionnaire.where(["assignment_id = ?", @assignment.id])
      @revqids.each do |rqid|
        rtype = Questionnaire.find(rqid.questionnaire_id).type
        if rtype == 'ReviewQuestionnaire'
          @review_questionnaire_id = rqid.questionnaire_id
        end
      end
      if @review_questionnaire_id
        @review_questionnaire = Questionnaire.find(@review_questionnaire_id)
        @maxscore = @review_questionnaire.max_question_score
        @review_questions = @review_questionnaire.questions
      end

      @scores = Answer.where(response_id: @reviewid)
      @scores.each do |s|
        @sum += s.answer
        @temp += s.answer
        @count += 1
      end

      @sum1 = (100 * @sum.to_f) / (@maxscore.to_f * @count.to_f)

    end
  end

  def view_review_scores_popup
    @reviewer_id = params[:reviewer_id]
    @assignment_id = params[:assignment_id]
    @review_final_versions = ReviewResponseMap.final_versions_from_reviewer(@reviewer_id)
  end

  # this can be called from "response_report" by clicking reviewer names from instructor end.
  def reviewer_details_popup
    @userid = Participant.find(params[:id]).user_id
    @user = User.find(@userid)
    @id = params[:assignment_id]
  end

  def calculate_percentages(assign_id)
    #single_response = Response.where(id: record_id)
    #mapped_response = ResponseMap.where(id: single_response[0].map_id)
    review_maps = ResponseMap.where(reviewed_object_id: assign_id)
    keys = [[0.00, 0.00, 0.00, 0.00], [0.00, 0.00, 0.00, 0.00], [0.00, 0.00, 0.00, 0.00], [0.00, 0.00, 0.00, 0.00]]
    response_count = [0.00, 0.00, 0.00, 0.00, 0.00, 0.00]
    word_counter = [0, 0, 0, 0, 0, 0]
    suggestive_count = [0, 0, 0, 0, 0, 0]
    problem_count = [0, 0, 0, 0, 0, 0]
    offensive_count = [0, 0, 0, 0, 0, 0]

    review_maps.each do |my_assignment|
      my_responses = Response.where(map_id: my_assignment.id)
      my_responses.each do |each_response|
        response_count[each_response.round - 1] += 1
        my_review_metric = ReviewMetricMapping.where(responses_id: each_response.id)
        my_review_metric.each do |my_metric|
          word_counter[each_response.round - 1] += my_metric.value if my_metric.review_metrics_id == 1 && my_metric.value > 0
          suggestive_count[each_response.round - 1] += 1 if my_metric.review_metrics_id == 2 && my_metric.value > 0
          problem_count[each_response.round - 1] += 1 if my_metric.review_metrics_id == 3 && my_metric.value > 0
          offensive_count[each_response.round - 1] += 1 if my_metric.review_metrics_id == 4 && my_metric.value > 0
        end
      end
    end

    (0..5).each do |i|
      unless response_count[i] == 0
        keys[i][0] = word_counter[i] / response_count[i]
        keys[i][1] = (suggestive_count[i] / response_count[i]) * 100
        keys[i][2] = (problem_count[i] / response_count[i]) * 100
        keys[i][3] = (offensive_count[i] / response_count[i]) * 100
      end
    end

    return keys
  end
end
