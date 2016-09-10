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
        response_maps = ResponseMap.where(["reviewed_object_id = ? AND reviewer_id = ? AND type = ?", reviewed_object_id, reviewer_id, type]) 
        this_reviewer = reviewer_id 
        count, rspan = 0, 0 
        line_num = line_num + 1 
        (line_num % 2 == 0) ? bgcolor = "#ffffff" : bgcolor = "#DDDDBB" 

         response_maps.each do |ri| 
           count = count + 1 if !ri.response.empty? 
           rspan = rspan + 1 if (Team.where(["id = ?", ri.reviewee_id ]).length > 0) 
        end
        [response_maps, bgcolor, count, rspan, line_num] 
    end

    def get_team_reviewed_link_name(max_team_size, response, reviewee_id)
        if max_team_size == 1 
            team_reviewed_link_name = TeamsUser.where(team_id: reviewee_id).first.user.fullname 
        else 
            team_reviewed_link_name = Team.find(reviewee_id).name 
        end
        team_reviewed_link_name = "("+team_reviewed_link_name+")" if !response.empty? and !response.last.is_submitted?
        team_reviewed_link_name
    end

    def get_current_round_for_review_report(reviewer_id)
        user_id = Participant.find(reviewer_id).user.id 
        topic_id = SignedUpTeam.topic_id(@assignment.id, user_id) 
        current_round = @assignment.number_of_current_round(topic_id)
        current_round = @assignment.num_review_rounds if @assignment.get_current_stage(topic_id)=="Finished" || @assignment.get_current_stage(topic_id)=="metareview" 
    end
    
    def get_vary_rubric_by_rounds_score_awarded_for_review_report(current_round, reviewer_id, team_id)
        has_value = false 
        color = ''
        score_awarded = '--'
        [current_round, current_round - 1].each_with_index do |round, index| 
            color = 'gray' if index == 1
            if @review_scores[reviewer_id] && @review_scores[reviewer_id][round] && @review_scores[reviewer_id][round][team_id] && @review_scores[reviewer_id][round][team_id] != -1.0 
                score_awarded = @review_scores[reviewer_id][round][team_id].inspect + '%'
                has_value = true 
                break 
            end 
        end 
        [color, score_awarded]
    end

    #
    # for calibration report
    #
    def get_css_style_for_calibration_report(diff) 
        # diff - difference between stu's answer and instructor's answer
        case diff.abs
        when 0
            css_class = 'c5'
        when 1
            css_class = 'c4'
        when 2
            css_class = 'c3'
        when 3
            css_class = 'c2'
        else
            css_class = 'c1'
        end
        css_class
    end
end
