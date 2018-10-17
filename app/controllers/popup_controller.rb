class PopupController < ApplicationController
  def action_allowed?
    ['Super-Administrator',
     'Administrator',
     'Instructor',
     'Teaching Assistant'].include? current_role_name
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
      @total_percentage = @response.average_score
      @sum = @response.total_score
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
        total_percentage = response.average_score
        total_percentage += '%' if total_percentage.is_a? Float
        instance_variable_set('@total_percentage_round_' + round.to_s, total_percentage)
        instance_variable_set('@sum_round_' + round.to_s, response.total_score)
        instance_variable_set('@total_possible_round_' + round.to_s, response.maximum_score)
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
      @reviewid = Response.find_by(map_id: params[:id2]).id
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
        @review_questionnaire_id = rqid.questionnaire_id if rtype == 'ReviewQuestionnaire'
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

  def tone_analysis_chart_popup
    @reviewer_id = params[:reviewer_id]
    @assignment_id = params[:assignment_id]
    @review_final_versions = ReviewResponseMap.final_versions_from_reviewer(@reviewer_id)

    # Builds tone analysis report and heatmap when instructor/admin/superadmin clicks on the "Tone analysis chart button" link for an assignment.
    build_tone_analysis_report
    build_tone_analysis_heatmap
  end

  def view_review_scores_popup
    @reviewer_id = params[:reviewer_id]
    @assignment_id = params[:assignment_id]
    @review_final_versions = ReviewResponseMap.final_versions_from_reviewer(@reviewer_id)
    @reviews = []

    # Builds tone analysis report and heatmap when instructor/admin/superadmin clicks on the "View Review Report" Icon for an assignment.
    build_tone_analysis_report
    build_tone_analysis_heatmap
  end

  def build_tone_analysis_report
    uri =  WEBSERVICE_CONFIG['sentiment_webservice_url'] + "analyze_reviews_bulk"
    index = 0
    @sentiment_summary = []
    keys = @review_final_versions.keys
    reviews = []
    round = 0

    # Loops by each review round
    keys.each do |key|
      questionnaire = Questionnaire.find(@review_final_versions[key][:questionnaire_id])
      questions = Question.where(questionnaire_id: questionnaire.id)

      # Loops by each question per review round
      questions.each do |question|
        # Loops an array of reviewee ids by review round
        @review_final_versions[key][:response_ids].each do |responseid|
          # If an answer to a question is not provided by a reviewer, add a default comment so that the tone analysis chart can
          # color the comment grey in the heatmap.  Otherwise, add their comment to the list of reviews.
          if Answer.where(response_id: responseid, question_id: question.id) == []
            comment = "N/A"
            param = {
              id: index,
              text: comment
            }
            reviews[index] = param
            index += 1
          else
            Answer.where(response_id: responseid, question_id: question.id).each do |review|
              comment = review.comments
              comment = "N/A" if review.comments.nil?
              param = {
                id: index,
                text: comment
              }
              reviews[index] = param
              index += 1
            end
          end
        end
      end

      if !reviews.empty?
        index = 0
        revs = {
          reviews: reviews
        }

        # calls web service
        sum_json = RestClient.post uri, revs.to_json, content_type: 'application/json; charset=UTF-8', accept: :json
        # store each summary in a hashmap and use the question as the key
        @sentiment_summary[round] = JSON.parse(sum_json)
      end
      round += 1
    end
  rescue StandardError => err
    logger.error err.message
  end

  def build_tone_analysis_heatmap

    @heatmap_urls = []
    keys = @review_final_versions.keys

    # Loops by each review round
    keys.each_with_index do |key, round|
      next if @sentiment_summary[round].nil?
      content = []
      v_label = []
      h_label = []
      questionnaire_id = Questionnaire.find(@review_final_versions[key][:questionnaire_id])
      questions = Question.where(questionnaire_id: questionnaire_id)

      # Loops by each question to obtain dynamic number of questions for a review round
      questions.each_index {|index| h_label.push("Q" + (index + 1).to_s) }

      # Loops by each reviewee to obtain dynamic number of reviewees for a review round
      @review_final_versions[key][:response_ids].each_index {|index| v_label.push("Reviewee " + (index + 1).to_s) }

      # Loops through each sentiment generated from the previous method above and stores the sentiment value and comment per review round.
      # If the sentiment_text contains "N/A", the the sentiment_value defaults to a score of 100.
      temp = []
      @sentiment_summary[round]['sentiments'].each do |index|
        sentiment_value = index['sentiment'].to_f
        sentiment_text = index['text']
        case sentiment_value
        when -1.0..-0.5
          sentiment_value = -0.75
        when -0.5..-0.25
          sentiment_value = -0.375
        when -0.25..0.25
          sentiment_value = 0
        when 0.25..0.5
          sentiment_value = 0.375
        when 0.5..1.0
          sentiment_value = 0.75
        end
        sentiment_value = 100 if sentiment_text == "N/A"
        param = {
          value: sentiment_value,
          text: sentiment_text
        }

        temp.push(param)
        next unless temp.size >= h_label.size
        content.push(temp)
        temp = []
      end

      contents = {
        v_labels: v_label,
        h_labels: h_label,
        font_face: "Arial",
        showTextInsideBoxes: true,
        showCustomColorScheme: false,
        tooltipColorScheme: "black",
        custom_color_scheme: {
          minimum_value: -1,
          maximum_value: 1,
          minimum_color: "#FFFFFF",
          maximum_color: "#FF0000",
          total_intervals: 7
        },
        color_scheme: {
          ranges: [{
            minimum: -1,
            maximum: -0.5,
            color: "red"
          }, {
            minimum: -0.5,
            maximum: -0.25,
            color: "#DC7633"
          }, {
            minimum: -0.25,
            maximum: 0.25,
            color: "yellow"
          }, {
            minimum: 0.25,
            maximum: 0.5,
            color: "#ABEBC6"
          }, {
            minimum: 0.5,
            maximum: 1,
            color: "green"
          }, {
            minimum: 100,
            maximum: 100,
            color: "#808080"
          }]
        },
        content: content
      }

      # calls web service
      heatmap_json = RestClient.post WEBSERVICE_CONFIG['heatmap_webservice_url'], contents.to_json, content_type: 'application/json; charset=UTF-8', accept: :json

      # store each URL into an array of URLS where the index is by review round
      @heatmap_urls[round] = JSON.parse(heatmap_json)
    end
  rescue StandardError => err
    logger.error err.message
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
    @user_fullname = params[:user_fullname]
    unless @response_id.nil?
      first_question_in_questionnaire = Answer.where(response_id: @response_id).first.question_id
      questionnaire_id = Question.find(first_question_in_questionnaire).questionnaire_id
      questionnaire = Questionnaire.find(questionnaire_id)
      @maxscore = questionnaire.max_question_score
      @scores = Answer.where(response_id: @response_id)
      @response = Response.find(@response_id)
      @total_percentage = @response.average_score
      @sum = @response.total_score
      @total_possible = @response.maximum_score
    end
    @maxscore = 5 if @maxscore.nil?
  end
end
