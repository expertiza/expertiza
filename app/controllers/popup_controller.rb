class PopupController < ApplicationController
  def action_allowed?
    ['Super-Administrator',
     'Administrator',
     'Instructor',
     'Teaching Assistant','Student'].include? current_role_name
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

  # this can be called from "response_report" by clicking on the View Metrics.
  def view_review_metrics_popup
    @reviewerid = params[:reviewer_id]
    @assignment_id = params[:assignment_id]
    @metrics = calculate_metrics_for_instructor(@assignment_id, @reviewerid)
    @average_volume_per_round = {}
    @average_suggestion_per_round = {}
    @average_problem_per_round = {}
    @average_offensive_per_round = {}
    @metrics.each do |key, values|
      volume = 0
      count = 0
      s = 0
      pr = 0
      o = 0
      values.each do |v|
        volume += v[2]
        if v[3]
          s += 1
        end
        if v[4]
          pr += 1
        end
        if v[5]
          o += 1
        end
        count += 1
      end
      @average_volume_per_round[key] = (volume.fdiv(count)).round(2)
      @average_suggestion_per_round[key] = (s.fdiv(count)).round(2) * 100
      @average_problem_per_round[key] = (pr.fdiv(count)).round(2) * 100
      @average_offensive_per_round[key] = (o.fdiv(count)).round(2) * 100
    end
  # puts @average_volume_per_round
  end

  def view_student_review_metrics_popup
    @response_id = params[:response_id]
    @answers = ReviewMetric.calculate_metrics_for_student(@response_id)
  end

  def calculate_metrics_for_instructor(assignment_id, reviewer_id)
    type = "ReviewResponseMap"
    answers = Answer.joins("join responses on responses.id = answers.response_id")
                  .joins("join response_maps on responses.map_id = response_maps.id")
                  .where("response_maps.reviewed_object_id = ? and response_maps.reviewer_id = ? and response_maps.type = ? and responses.is_submitted = 1",assignment_id, reviewer_id,type)
                  .select("answers.comments, answers.response_id, responses.round, response_maps.reviewee_id, responses.is_submitted").order("answers.response_id")
    suggestive_words = TEXT_METRICS_KEYWORDS['suggestive']
    offensive_words = TEXT_METRICS_KEYWORDS['offensive']
    problem_words = TEXT_METRICS_KEYWORDS['problem']
    current_response_id = nil
    response_level_comments = {}
    metrics = {}
    metrics_per_reviewee = {}
    response_reviewee_map = {}
    diff_word_count = {}
    complete_sentences = Hash.new(0)
    answers.each do |ans|
      # puts ans.comments
      comment = ans.comments
      response_reviewee_map[ans.response_id] = ans.reviewee_id
      if current_response_id.nil? or current_response_id != ans.response_id
        current_response_id = ans.response_id
        response_level_comments[current_response_id] = comment
      else
        response_level_comments[current_response_id] = response_level_comments[current_response_id] + comment
      end
    end
    denom = response_level_comments.length
    response_level_comments.each_pair do |key, value|
      word_counter = 0
      offensive_metric = 0
      suggestive_metric = 0
      problem_metric = 0
      is_offensive_term = false
      is_suggestion = false
      is_problem = false
      value.scan(/[\w']+/).each do |word|
        word_counter = word_counter + 1
        if offensive_words.include? word
          is_offensive_term = true
        end
        if suggestive_words.include? word
          is_suggestion = true
        end
        if problem_words.include? word
          is_problem = true
        end
      end

      # diff_word_count = response_level_comments[current_response_id].scan(/[\w']+/).uniq.count
      if ReviewMetric.exists?(response_id: key)
        obj = ReviewMetric.find_by(response_id: key)
      else
        obj = ReviewMetric.new
        obj.response_id = key
      end
      # puts "Suggestion: #{is_suggestion}, Offensive: #{is_offensive_term}, Problem: #{is_problem}"
      obj.update_attribute(:volume, word_counter)
      obj.update_attribute(:suggestion, is_suggestion)
      obj.update_attribute(:offensive_term, is_offensive_term)
      obj.update_attribute(:problem, is_problem)
      obj.save!
      # puts "Object-Suggestion: #{obj.suggestion}, Object-Offensive: #{obj.offensive_term}, Object-Problem: #{obj.problem}"
      answers.each do |ans|
        diff_word_count[ans.response_id] = response_level_comments[ans.response_id].scan(/[\w']+/).uniq.count
      end
      metrics[key] = [key, response_reviewee_map[key] , word_counter, is_suggestion, is_problem, is_offensive_term,diff_word_count[key]]
    end
    metrics_per_round = {}
    temp_dict = {}
    answers.each do |ans|

      puts "Reviewee Id: #{ans.reviewee_id} ---> Response Id: #{ans.response_id} --> Round: #{ans.round} --> Is Submitted: #{ans.is_submitted}"
      if !temp_dict.has_key?(ans.response_id)
        temp_dict[ans.response_id] = metrics[ans.response_id]
        metrics_per_round[ans.round] = metrics_per_round.fetch(ans.round, []) + [temp_dict[ans.response_id]]
      end
    end
    # puts metrics_per_reviewee
    # puts metrics_per_round
    metrics_per_round
  end

  def calculate_metrics_for_student(response_id)
    type = "ReviewResponseMap"
    concatenated_comment = ''
    answers = Answer.where("answers.response_id = ? ", response_id).select("answers.comments")
    suggestive_words = TEXT_METRICS_KEYWORDS['suggestive']
    offensive_words = TEXT_METRICS_KEYWORDS['offensive']
    problem_words = TEXT_METRICS_KEYWORDS['problem']
    current_response_id = nil
    is_offensive_term = false
    is_suggestion = false
    is_problem = false
    volume = 0
    complete_sentences = 0
    diff_word_count = 0
    answers.each do |ans|
      ans_word_count = 0
      comments = ans.comments
      comments.scan(/[\w']+/).each do |word|
        ans_word_count = ans_word_count + 1;
      end # end for comments.scan
      concatenated_comment = concatenated_comment + comments
      if (ans_word_count > 7)
        complete_sentences = complete_sentences + 1
      end # end for if(ans_word_count > 7)
    end # end for answers.each

    concatenated_comment.scan(/[\w']+/).each do |word|
      volume = volume + 1

      if offensive_words.include? word
        is_offensive_term = true
      end
      if suggestive_words.include? word
        is_suggestion = true
      end
      if problem_words.include? word
        is_problem = true
      end

    end # end of concatenate_comment

    diff_word_count = concatenated_comment.scan(/[\w']+/).uniq.count

    [volume,is_offensive_term,is_suggestion,is_problem, complete_sentences,diff_word_count]

  end
end
