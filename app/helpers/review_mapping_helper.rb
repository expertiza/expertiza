module ReviewMappingHelper
  def create_report_table_header(headers = {})
    table_header = "<div class = 'reviewreport'>\
                    <table width='100% cellspacing='0' cellpadding='2' border='0'>\
                    <tr bgcolor='#CCCCCC'>"
    headers.each do |header, percentage|
      table_header += "<th width = #{percentage}>\
                      #{header.humanize}\
                      </th>"
    end
    table_header += "</tr>"
    table_header.html_safe
  end

  #
  # for review report
  #
  def get_data_for_review_report(reviewed_object_id, reviewer_id, type, line_num)
    rspan = 0
    line_num += 1
    bgcolor = line_num.even? ? "#ffffff" : "#DDDDBB"
    (1..@assignment.num_review_rounds).each {|round| instance_variable_set("@review_in_round_" + round.to_s, 0) }

    response_maps = ResponseMap.where(["reviewed_object_id = ? AND reviewer_id = ? AND type = ?", reviewed_object_id, reviewer_id, type])
    response_maps.each do |ri|
      rspan += 1 if Team.exists?(id: ri.reviewee_id)
      responses = ri.response
      (1..@assignment.num_review_rounds).each do |round|
        instance_variable_set("@review_in_round_" + round.to_s, instance_variable_get("@review_in_round_" + round.to_s) + 1) if responses.exists?(round: round)
      end
    end
    [response_maps, bgcolor, rspan, line_num]
  end

  def get_team_reviewed_link_name(max_team_size, response, reviewee_id)
    team_reviewed_link_name = if max_team_size == 1
                                TeamsUser.where(team_id: reviewee_id).first.user.fullname
                              else
                                Team.find(reviewee_id).name
                              end
    team_reviewed_link_name = "(" + team_reviewed_link_name + ")" if !response.empty? and !response.last.is_submitted?
    team_reviewed_link_name
  end

  def get_current_round_for_review_report(reviewer_id)
    user_id = Participant.find(reviewer_id).user.id
    topic_id = SignedUpTeam.topic_id(@assignment.id, user_id)
    @assignment.number_of_current_round(topic_id)
    @assignment.num_review_rounds if @assignment.get_current_stage(topic_id) == "Finished" || @assignment.get_current_stage(topic_id) == "metareview"
  end

  # varying rubric by round
  def get_each_round_score_awarded_for_review_report(reviewer_id, team_id)
    (1..@assignment.num_review_rounds).each {|round| instance_variable_set("@score_awarded_round_" + round.to_s, '-----') }
    (1..@assignment.num_review_rounds).each do |round|
      if @review_scores[reviewer_id] && @review_scores[reviewer_id][round] && @review_scores[reviewer_id][round][team_id] && @review_scores[reviewer_id][round][team_id] != -1.0
        instance_variable_set("@score_awarded_round_" + round.to_s, @review_scores[reviewer_id][round][team_id].inspect + '%')
      end
    end
  end

  def get_min_max_avg_value_for_review_report(round, team_id)
    [:max, :min, :avg].each {|metric| instance_variable_set('@' + metric.to_s, '-----') }
    if @avg_and_ranges[team_id] && @avg_and_ranges[team_id][round] && [:max, :min, :avg].all? {|k| @avg_and_ranges[team_id][round].key? k }
      [:max, :min, :avg].each do |metric|
        metric_value = @avg_and_ranges[team_id][round][metric].nil? ? '-----' : @avg_and_ranges[team_id][round][metric].round(0).to_s + '%'
        instance_variable_set('@' + metric.to_s, metric_value)
      end
    end
  end

  def sort_reviewer_by_review_volume_desc
    @reviewers.each do |r| 
      r.overall_avg_vol,
      r.avg_vol_in_round_1,
      r.avg_vol_in_round_2,
      r.avg_vol_in_round_3 = Response.get_volume_of_review_comments(@assignment.id, r.id)
    end
    @reviewers.sort! {|r1, r2| r2.overall_avg_vol <=> r1.overall_avg_vol }
  end

  def display_volume_metric(overall_avg_vol, avg_vol_in_round_1, avg_vol_in_round_2, avg_vol_in_round_3)
    metric = "Avg. Volume: #{overall_avg_vol.to_s} <br/> ("
    metric += "1st: " + avg_vol_in_round_1.to_s if avg_vol_in_round_1 > 0
    metric += ", 2nd: " + avg_vol_in_round_2.to_s if avg_vol_in_round_2 > 0
    metric += ", 3rd: " + avg_vol_in_round_3.to_s if avg_vol_in_round_3 > 0
    metric += ")"
    metric.html_safe
  end

  def list_review_submissions(participant_id, reviewee_team_id, response_map_id)
    participant = Participant.find(participant_id)
    team = AssignmentTeam.find(reviewee_team_id)
    html = ''
    if !team.nil? and !participant.nil?
      review_submissions_path = team.path + "_review" + "/" + response_map_id.to_s
      files = team.submitted_files(review_submissions_path)
      if files and files.length > 0 
        html += display_review_files_directory_tree(participant, files) 
      end 
    end 
    html.html_safe
  end
  #
  # for author feedback report
  #
  #
  # varying rubric by round
  def get_each_round_review_and_feedback_response_map_for_feedback_report(author)
    @team_id = TeamsUser.team_id(@id.to_i, author.user_id)
    # Calculate how many responses one team received from each round
    # It is the feedback number each team member should make
    @review_response_map_ids = ReviewResponseMap.where(["reviewed_object_id = ? and reviewee_id = ?", @id, @team_id]).pluck("id")
    {1 => 'one', 2 => 'two', 3 => 'three'}.each do |key, round_num|
      instance_variable_set('@review_responses_round_' + round_num,
                            Response.where(["map_id IN (?) and round = ?", @review_response_map_ids, key]))
      # Calculate feedback response map records
      instance_variable_set('@feedback_response_maps_round_' + round_num,
                            FeedbackResponseMap.where(["reviewed_object_id IN (?) and reviewer_id = ?",
                                                       instance_variable_get('@all_review_response_ids_round_' + round_num), author.id]))
    end
    # rspan means the all peer reviews one student received, including unfinished one
    @rspan_round_one = @review_responses_round_one.length
    @rspan_round_two = @review_responses_round_two.length
    @rspan_round_three = @review_responses_round_three.nil? ? 0 : @review_responses_round_three.length
  end

  def get_certain_round_review_and_feedback_response_map_for_feedback_report(author)
    @feedback_response_maps = FeedbackResponseMap.where(["reviewed_object_id IN (?) and reviewer_id = ?", @all_review_response_ids, author.id])
    @team_id = TeamsUser.team_id(@id.to_i, author.user_id)
    @review_response_map_ids = ReviewResponseMap.where(["reviewed_object_id = ? and reviewee_id = ?", @id, @team_id]).pluck("id")
    @review_responses = Response.where(["map_id IN (?)", @review_response_map_ids])
    @rspan = @review_responses.length
  end

  #
  # for calibration report
  #
  def get_css_style_for_calibration_report(diff)
    # diff - difference between stu's answer and instructor's answer
    css_class = case diff.abs
                when 0
                  'c5'
                when 1
                  'c4'
                when 2
                  'c3'
                when 3
                  'c2'
                else
                  'c1'
                end
    css_class
  end
end
