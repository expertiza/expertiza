module ReviewMappingHelper
  def create_report_table_header(headers = {})
    table_header = "<div class = 'reviewreport'>\
                    <table width='100% cellspacing='0' cellpadding='2' border='0' class='table table-striped'>\
                    <tr bgcolor='#CCCCCC'>"
    headers.each do |header, percentage|
      table_header += if percentage
                        "<th width = #{percentage}>\
                        #{header.humanize}\
                                        </th>"
                      else
                        "<th>\
                        #{header.humanize}\
                                        </th>"
                      end
    end
    table_header += "</tr>"
    table_header.html_safe
  end

  # sending data to be displayed on review report
  def data_for_review_report(reviewed_object_id, reviewer_id, type)
    rspan = 0
    (1..@assignment.num_review_rounds).each {|round| instance_variable_set("@review_in_round_" + round.to_s, 0) }

    response_maps = ResponseMap.where(["reviewed_object_id = ? AND reviewer_id = ? AND type = ?", reviewed_object_id, reviewer_id, type])
    response_maps.each do |ri|
      rspan += 1 if Team.exists?(id: ri.reviewee_id)
      responses = ri.response
      (1..@assignment.num_review_rounds).each do |round|
        instance_variable_set("@review_in_round_#{round}", instance_variable_get("@review_in_round_" + round.to_s) + 1) if responses.exists?(round: round)
      end
    end
    [response_maps, rspan]
  end

  # gets color according to review and assignment submission status
  # brown: the review grade has been assigned
  # blue: review is completed in every round and the review grade is not assigned
  # purple: there is no review for a submitted work within the round
  # green: there is no submitted work to review within the round
  # red: review is not completed in any rounds
  def color_legend_for_review_status(response_map)
    assignment_created = @assignment.created_at
    assignment_due_dates = DueDate.where(parent_id: response_map.reviewed_object_id)
    if Response.exists?(map_id: response_map.id)
      if !response_map.try(:reviewer).try(:review_grade).nil?
        'brown'
      elsif response_for_each_round?(response_map)
        'blue'
      else
        color = []
        (1..@assignment.num_review_rounds).each do |round|
          if submitted_within_round?(round, response_map, assignment_created, assignment_due_dates)
            color.push 'purple'
          else
            link = submitted_hyperlink(round, response_map, assignment_created, assignment_due_dates)
            if link.nil? or (link !~ %r{https*:\/\/wiki(.*)}) # can be extended for github links in future
              color.push 'green'
            else
              link_updated_at = link_updated_at(link)
              color.push link_updated_since_last?(round, assignment_due_dates, link_updated_at) ? 'purple' : 'green'
            end
          end
        end
        color[-1]
      end
    else
      'red'
    end
  end

  # checks if a review was submitted in every round
  def response_for_each_round?(response_map)
    num_responses = 0
    total_num_rounds = @assignment.num_review_rounds
    (1..total_num_rounds).each do |round|
      num_responses += 1 if Response.exists?(map_id: response_map.id, round: round)
    end
    num_responses == total_num_rounds
  end

  # checks if an assignment was submitted within the due date
  def submitted_within_round?(round, response_map, assignment_created, assignment_due_dates)
    submission_due_date = assignment_due_dates.where(round: round, deadline_type_id: 1).try(:first).try(:due_at)
    submission = SubmissionRecord.where(team_id: response_map.reviewee_id, operation: ['Submit File', 'Submit Hyperlink'])
    subm_created_at = submission.where(created_at: assignment_created..submission_due_date)
    if round > 1
      submission_due_last_round = assignment_due_dates.where(round: round - 1, deadline_type_id: 1).try(:first).try(:due_at)
      subm_created_at = submission.where(created_at: submission_due_last_round..submission_due_date)
    end
    !subm_created_at.try(:first).try(:created_at).nil?
  end

  # returns submitted hyperlink
  def submitted_hyperlink(round, response_map, assignment_created, assignment_due_dates)
    submission_due_date = assignment_due_dates.where(round: round, deadline_type_id: 1).try(:first).try(:due_at)
    subm_hyperlink = SubmissionRecord.where(team_id: response_map.reviewee_id, operation: 'Submit Hyperlink')
    submitted_h = subm_hyperlink.where(created_at: assignment_created..submission_due_date)
    submitted_h.try(:last).try(:content)
  end

  # returns last modified header date
  # only checks certain links (wiki)
  def link_updated_at(link)
    uri = URI(link)
    res = Net::HTTP.get_response(uri)['last-modified']
    res.to_time
  end

  # checks if a link was updated since last round submission
  def link_updated_since_last?(round, due_dates, link_updated_at)
    submission_due_date = due_dates.where(round: round, deadline_type_id: 1).try(:first).try(:due_at)
    submission_due_last_round = due_dates.where(round: round - 1, deadline_type_id: 1).try(:first).try(:due_at)
    (link_updated_at < submission_due_date) && (link_updated_at > submission_due_last_round)
  end

  # returns team name if there is more than one person in the team else returns the student's name
  def team_reviewed_link_name(max_team_size, response, reviewee_id)
    team_reviewed_link_name = if max_team_size == 1
                                TeamsUser.where(team_id: reviewee_id).first.user.fullname
                              else
                                Team.find(reviewee_id).name
                              end
    team_reviewed_link_name = "(#{team_reviewed_link_name})" if !response.empty? and !response.last.is_submitted?
    team_reviewed_link_name
  end

  # varying rubric by round
  def each_round_score_for_review_report(reviewer_id, team_id)
    (1..@assignment.num_review_rounds).each {|round| instance_variable_set("@score_awarded_round_#{round}", '-----') }
    (1..@assignment.num_review_rounds).each do |round|
      if @review_scores[reviewer_id] && @review_scores[reviewer_id][round] && @review_scores[reviewer_id][round][team_id] && @review_scores[reviewer_id][round][team_id] != -1.0
        instance_variable_set("@score_awarded_round_#{round}", @review_scores[reviewer_id][round][team_id].inspect + '%')
      end
    end
  end

  # get minimum, maximum and average value for review report
  def value_for_review_report(round, team_id)
    %i[max min avg].each {|metric| instance_variable_set("@#{metric}", "-----") }
    if @avg_and_ranges[team_id] && @avg_and_ranges[team_id][round] && %i[max min avg].all? {|k| @avg_and_ranges[team_id][round].key? k }
      %i[max min avg].each do |metric|
        metric_value = @avg_and_ranges[team_id][round][metric].nil? ? '-----' : @avg_and_ranges[team_id][round][metric].round(0).to_s + '%'
        instance_variable_set("@#{metric}", metric_value)
      end
    end
  end

  # sorts by volume in descending order
  def sort_reviewer_by_review_volume_desc
    @reviewers.each do |r|
      r.overall_avg_vol,
          r.avg_vol_in_round_1,
          r.avg_vol_in_round_2,
          r.avg_vol_in_round_3 = Response.get_volume_of_review_comments(@assignment.id, r.id)
    end
    @all_reviewers_overall_avg_vol = @reviewers.inject(0) {|sum, r| sum += r.overall_avg_vol } / (@reviewers.blank? ? 1 : @reviewers.length)

    (1..@assignment.num_review_rounds).each do |round_num|
      instance_variable_set("@all_reviewers_avg_vol_in_round_#{round_num}", @reviewers.inject(0) {|sum, r| sum += eval("r.avg_vol_in_round_#{round_num}") } / (@reviewers.blank? ? 1 : @reviewers.length))
    end
    @reviewers.sort! {|r1, r2| r2.overall_avg_vol <=> r1.overall_avg_vol }
  end

  # assigns values to elements that are used to construct the bar graph in display_metric_chart function
  def initialize_chart_elements(reviewer)
    #round = 0
    labels = []
    reviewer_data = []
    all_reviewers_data = []

    (1..@assignment.num_review_rounds).each do |round_num|
      #round += 1
      labels.push round_num.to_s
      reviewer_data.push eval("reviewer.avg_vol_in_round_#{round_num}")
      all_reviewers_data.push instance_variable_get("@all_reviewers_avg_vol_in_round_#{round_num}")
    end

    labels.push 'Total'
    reviewer_data.push reviewer.overall_avg_vol
    all_reviewers_data.push @all_reviewers_overall_avg_vol
    [labels, reviewer_data, all_reviewers_data]
  end

  # Constructs the bar graph for metrics column
  def display_metric_chart(reviewer)
    labels, reviewer_data, all_reviewers_data = initialize_chart_elements(reviewer)
    data = {
        labels: labels,
        datasets: [
            {
                backgroundColor: "rgba(255,99,132,0.4)",
                data: reviewer_data,
                borderWidth: 1
            },
            {
                backgroundColor: "rgba(139,0,0 ,1 )",
                data: all_reviewers_data,
                borderWidth: 1
            }
        ]
    }
    options = {
        legend: {
            display: false
        },
        width: "200",
        height: "125",
        scales: {
            yAxes: [{
                        stacked: false,
                        barThickness: 10
                    }],
            xAxes: [{
                        stacked: false,
                        ticks: {
                            beginAtZero: true,
                            stepSize: 100,
                            max: 500
                        }
                    }]
        }
    }
    horizontal_bar_chart data, options
  end

  def list_review_submissions(participant_id, reviewee_team_id, response_map_id)
    participant = Participant.find(participant_id)
    team = AssignmentTeam.find(reviewee_team_id)
    html = ''
    if !team.nil? and !participant.nil?
      review_submissions_path = "#{team.path}_review/#{response_map_id}"
      files = team.submitted_files(review_submissions_path)
      html += display_review_files_directory_tree(participant, files) if files.present?
    end
    html.html_safe
  end

  # Zhewei - 2017-02-27
  # This is for all Dr.Kidd's courses
  def calcutate_average_author_feedback_score(assignment_id, max_team_size, response_map_id, reviewee_id)
    review_response = ResponseMap.where(id: response_map_id).try(:first).try(:response).try(:last)
    author_feedback_avg_score = "-- / --"
    unless review_response.nil?
      user = TeamsUser.where(team_id: reviewee_id).try(:first).try(:user) if max_team_size == 1
      author = Participant.where(parent_id: assignment_id, user_id: user.id).try(:first) unless user.nil?
      feedback_response = ResponseMap.where(reviewed_object_id: review_response.id, reviewer_id: author.id).try(:first).try(:response).try(:last) unless author.nil?
      author_feedback_avg_score = feedback_response.nil? ? "-- / --" : "#{feedback_response.total_score} / #{feedback_response.maximum_score}"
    end
    author_feedback_avg_score
  end

  # Zhewei - 2016-10-20
  # This is for Dr.Kidd's assignment (806)
  # She wanted to quickly see if students pasted in a link (in the text field at the end of the rubric) without opening each review
  # Since we do not have hyperlink question type, we hacked this requirement
  # Maybe later we can create a hyperlink question type to deal with this situation.
  def list_hyperlink_submission(response_map_id, question_id)
    assignment = Assignment.find(@id)
    curr_round = assignment.try(:num_review_rounds)
    curr_response = Response.where(map_id: response_map_id, round: curr_round).first
    answer_with_link = Answer.where(response_id: curr_response.id, question_id: question_id).first if curr_response
    comments = answer_with_link.try(:comments)
    html = ''
    html += display_hyperlink_in_peer_review_question(comments) if comments.present? and comments.start_with?('http')
    html.html_safe
  end

  #
  # for author feedback report
  #
  #
  # varying rubric by round
  def each_round_review_and_feedback_response_map_for_feedback_report(author)
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

  def certain_round_review_and_feedback_response_map_for_feedback_report(author)
    @feedback_response_maps = FeedbackResponseMap.where(["reviewed_object_id IN (?) and reviewer_id = ?", @all_review_response_ids, author.id])
    @team_id = TeamsUser.team_id(@id.to_i, author.user_id)
    @review_response_map_ids = ReviewResponseMap.where(["reviewed_object_id = ? and reviewee_id = ?", @id, @team_id]).pluck("id")
    @review_responses = Response.where(["map_id IN (?)", @review_response_map_ids])
    @rspan = @review_responses.length
  end

  #
  # for calibration report
  #
  def css_style_for_calibration_report(diff)
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

  class ReviewStrategy
    attr_accessor :participants, :teams

    def initialize(participants, teams, review_num)
      @participants = participants
      @teams = teams
      @review_num = review_num
    end
  end

  class StudentReviewStrategy < ReviewStrategy
    def reviews_per_team
      (@participants.size * @review_num * 1.0 / @teams.size).round
    end

    def reviews_needed
      @participants.size * @review_num
    end

    def reviews_per_student
      @review_num
    end
  end

  class TeamReviewStrategy < ReviewStrategy
    def reviews_per_team
      @review_num
    end

    def reviews_needed
      @teams.size * @review_num
    end

    def reviews_per_student
      (@teams.size * @review_num * 1.0 / @participants.size).round
    end
  end
end

