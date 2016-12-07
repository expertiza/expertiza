module ReviewMappingHelper
  def create_report_table_header(headers = {})
    table_header = "<div class = 'reviewreport'>\
                    <table width='100% cellspacing='0' cellpadding='2' border='0'>\
                    <tr bgcolor='#CCCCCC'>"
    headers.each do |header, percentage|
      if percentage
        table_header += "<th width = #{percentage}>\
                        #{header.humanize}\
                        </th>"
      else
        table_header += "<th>\
                        #{header.humanize}\
                        </th>"
      end
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
    metric = "Avg. Length of Review (in chars): #{overall_avg_vol.to_s} <br/>"
    metric += "1st: " + avg_vol_in_round_1.to_s if avg_vol_in_round_1 > 0
    metric += "</br>2nd: " + avg_vol_in_round_2.to_s if avg_vol_in_round_2 > 0
    metric += "</br>3rd: " + avg_vol_in_round_3.to_s if avg_vol_in_round_3 > 0
    metric.html_safe
  end

  def display_avg_author_feedback_score(reviewer_id)
    score = 'Avg. Author Feedback Score:</br>'
    no_feedback = true

    if  !@author_feedback_score[reviewer_id][1].nil?
       score += '1st: '+ sprintf('%.2f', @author_feedback_score[reviewer_id][1]).remove('.00')+'/'+
           @author_feedback_score[:max_score_round_1].to_s+' from '+@author_feedback_score[:no_of_feedbacks_round_1].to_s+' feedback/s'

       no_feedback = false
    end

     if  !@author_feedback_score[reviewer_id][2].nil?
       score += '</br>2nd: '+ sprintf('%.2f', @author_feedback_score[reviewer_id][2].to_s).remove('.00')+'/'+
           @author_feedback_score[:max_score_round_2].to_s+'/'+' from '+@author_feedback_score[:no_of_feedbacks_round_2].to_s+' feedback/s'

       no_feedback = false
     end

      if  !@author_feedback_score[reviewer_id][3].nil?
        score += '</br>3rd: '+ sprintf('%.2f', @author_feedback_score[reviewer_id][3].to_s).remove('.00')+'/'+
           @author_feedback_score[:max_score_round_3].to_s+' from '+@author_feedback_score[:no_of_feedbacks_round_3].to_s+' feedback/s'

        no_feedback = false
      end

    if no_feedback
      score += "No feedbacks available"
    end

    score.html_safe
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

  # Zhewei - 2016-10-20
  # This is for Dr.Kidd's assignment (806)
  # She wanted to quickly see if students pasted in a link (in the text field at the end of the rubric) without opening each review
  # Since we do not have hyperlink question type, we hacked this requirement
  # Maybe later we can create a hyperlink question type to deal with this situation.
  def list_hyperlink_submission(participant_id, response_map_id, question_id)
    assignment = Assignment.find(@id)
    curr_round = assignment.try(:num_review_rounds)
    curr_response = Response.where(map_id: response_map_id, round: curr_round).first
    answer_with_link = Answer.where(response_id: curr_response.id, question_id: question_id).first if curr_response
    comments = answer_with_link.try(:comments)
    html = ''
    if comments and !comments.empty? and comments.start_with?('http')
      html += display_hyperlink_in_peer_review_question(comments) 
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
  #This method will compute author feedbacks for given list of reviewers
  #It will return a hash with key as reviewer id and round number and value will consist of average author feedback for
  #particular round
  #We will also return number of feedbacks for each round.
  def get_author_feedback_score_hash(assignment, reviewers)

    review_mapping_type = 'FeedbackResponseMap'

    does_assignment_have_varying_rubrics = false

    if assignment.varying_rubrics_by_round?

      does_assignment_have_varying_rubrics = true

      #We will store all the review response ids for the particular round.
      authors, all_review_response_ids_round_one, all_review_response_ids_round_two, all_review_response_ids_round_three = FeedbackResponseMap.feedback_response_report(assignment.id, review_mapping_type)

    else

      authors, all_review_response_ids = FeedbackResponseMap.feedback_response_report(assignment.id, review_mapping_type)

    end

    reviewer_ids = []

    author_feedback_score = {}

    author_feedback_score[:max_score_round_1] = {}
    author_feedback_score[:max_score_round_2] = {}
    author_feedback_score[:max_score_round_3] = {}

    author_feedback_score[:no_of_feedbacks_round_1] = {}
    author_feedback_score[:no_of_feedbacks_round_2] = {}
    author_feedback_score[:no_of_feedbacks_round_3] = {}

    if(!reviewers.nil?)

      reviewers.each do |r|

        author_feedback_score[r.id] = {} if author_feedback_score[r.id].nil?

        next if reviewer_ids.include? r.id

        reviewer_ids << r.id

        #Retrieving all the response map of feedback for this reviewer
        review_mappings = FeedbackResponseMap.where(:reviewee_id => r.id, :type => review_mapping_type)

        if(!review_mappings.nil? && review_mappings.size > 0)

          if does_assignment_have_varying_rubrics

            total_score = {:round_1 => 0, :round_2 => 0, :round_3 => 0}

            total_feedback = {:round_1 => 0, :round_2 => 0, :round_3 => 0}

            review_mappings.each do |m|

              response = Response.where(:map_id => m.id).first

              next if response.nil?

              #The following code will compute the total feedback score for each round. It will later find average of that score
              #and store it in hash author_feedback_score
              if all_review_response_ids_round_one.include? m.reviewed_object_id

                compute_feedback_score_per_round total_score, response, total_feedback, author_feedback_score, :max_score_round_1,:round_1

              elsif all_review_response_ids_round_two.include? m.reviewed_object_id

                compute_feedback_score_per_round total_score, response, total_feedback, author_feedback_score, :max_score_round_2, :round_2

              else

                compute_feedback_score_per_round total_score, response, total_feedback, author_feedback_score, :max_score_round_3, :round_3

              end
            end

            if total_feedback[:round_1] > 0

              update_author_feedback_hash author_feedback_score, r.id, 1, :no_of_feedbacks_round_1, total_score[:round_1], total_feedback[:round_1]

            end

            if total_feedback[:round_2] > 0

              update_author_feedback_hash author_feedback_score, r.id, 2, :no_of_feedbacks_round_2, total_score[:round_2], total_feedback[:round_2]

            end

            if total_feedback[:round_3] > 0

              update_author_feedback_hash author_feedback_score, r.id, 3, :no_of_feedbacks_round_3, total_score[:round_3], total_feedback[:round_3]

            end

          else

            total_score = {:round_1 => 0}

            total_feedback = {:round_1 => 0}

            review_mappings.each do |m|

              response = Response.where(:map_id => m.id).first;

              next if response.nil?

              compute_feedback_score_per_round total_score, response, total_feedback, author_feedback_score, :max_score_round_1, :round_1

            end

            update_author_feedback_hash author_feedback_score, r.id, 1, :no_of_feedbacks_round_1, total_score[:round_1], total_feedback[:round_1]

          end
        end
      end
    end

    author_feedback_score
  end

  private

  def update_author_feedback_hash(author_feedback_score, reviewer_id, round_no, number_of_feedback_key, total_score, number_of_feedbacks)
    author_feedback_score[reviewer_id][round_no] = {} if author_feedback_score[reviewer_id][round_no].nil?
    author_feedback_score[reviewer_id][round_no] = total_score.to_f / number_of_feedbacks
    author_feedback_score[number_of_feedback_key] = number_of_feedbacks
  end

  def compute_feedback_score_per_round(total_score, response, total_feedback,author_feedback_score, max_feedback_score_key, round_no_key)

    total_score[round_no_key] +=  response.get_total_score
    total_feedback[round_no_key] += 1
    author_feedback_score[max_feedback_score_key] = response.get_maximum_score if author_feedback_score[max_feedback_score_key].blank?

  end

end


