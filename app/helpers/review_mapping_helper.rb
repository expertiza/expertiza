module ReviewMappingHelper
  def create_report_table_header(headers = {})
    render partial: 'report_table_header', locals: { headers: headers }
  end

  def get_data_for_review_report(reviewed_object_id, reviewer_id, type, assignment)
    ReviewReportService.new(assignment).get_data_for_review_report(reviewed_object_id, reviewer_id, type, assignment)
  end

  def get_team_color(response_map)
    assignment_created = @assignment.created_at
    assignment_due_dates = DueDate.where(parent_id: response_map.reviewed_object_id)
    if Response.exists?(map_id: response_map.id)
      if !response_map.try(:reviewer).try(:review_grade).nil?
        'brown'
      elsif response_for_each_round?(response_map)
        'blue'
      else
        get_team_color(response_map, assignment_created, assignment_due_dates)
      end
    else
      'red'
    end
  end

  def get_team_color(response_map, assignment_created, assignment_due_dates)
    color = []
    (1..@assignment.num_review_rounds).each do |round|
      check_submission_state(response_map, assignment_created, assignment_due_dates, round, color)
    end
    color[-1]
  end

  def check_submission_state(response_map, assignment_created, assignment_due_dates, round, color)
    if submitted_within_round?(round, response_map, assignment_created, assignment_due_dates)
      color.push 'purple'
    else
      link = submitted_hyperlink(round, response_map, assignment_created, assignment_due_dates)
      if link.nil? || (link !~ %r{https*:\/\/wiki(.*)})
        color.push 'green'
      else
        link_updated_at = get_link_updated_at(link)
        color.push link_updated_since_last?(round, assignment_due_dates, link_updated_at) ? 'purple' : 'green'
      end
    end
  end

  def response_for_each_round?(response_map)
    num_responses = 0
    total_num_rounds = @assignment.num_review_rounds
    (1..total_num_rounds).each do |round|
      num_responses += 1 if Response.exists?(map_id: response_map.id, round: round)
    end
    num_responses == total_num_rounds
  end

  def submitted_within_round?(round, response_map, assignment_created, assignment_due_dates)
    submission_due_date = assignment_due_dates.where(round: round, deadline_type_id: 1).try(:first).try(:due_at)
    
    return false unless submission_due_date
    
    submission = SubmissionRecord.where(team_id: response_map.reviewee_id, operation: ['Submit File', 'Submit Hyperlink'])
    
    subm_created_at = submission.where(created_at: assignment_created..submission_due_date)
    
    if round > 1
      submission_due_last_round = assignment_due_dates.where(round: round - 1, deadline_type_id: 1).try(:first).try(:due_at)
      
      if submission_due_last_round
        subm_created_at = submission.where(created_at: submission_due_last_round..submission_due_date)
      end
    end
    
    !subm_created_at.try(:first).try(:created_at).nil?
  end

  def submitted_hyperlink(round, response_map, assignment_created, assignment_due_dates)
    submission_due_date = assignment_due_dates.where(round: round, deadline_type_id: 1).try(:first).try(:due_at)
    subm_hyperlink = SubmissionRecord.where(team_id: response_map.reviewee_id, operation: 'Submit Hyperlink')
    submitted_h = subm_hyperlink.where(created_at: assignment_created..submission_due_date)
    submitted_h.try(:last).try(:content)
  end

  def get_link_updated_at(link)
    uri = URI(link)
    res = Net::HTTP.get_response(uri)['last-modified']
    res.to_time
  end

  def link_updated_since_last?(round, due_dates, link_updated_at)
    submission_due_date = due_dates.where(round: round, deadline_type_id: 1).try(:first).try(:due_at)
    submission_due_last_round = due_dates.where(round: round - 1, deadline_type_id: 1).try(:first).try(:due_at)
    (link_updated_at < submission_due_date) && (link_updated_at > submission_due_last_round)
  end

  def get_team_reviewed_link_name(max_team_size, _response, reviewee_id, ip_address)
    team_reviewed_link_name = if max_team_size == 1
                                TeamsUser.where(team_id: reviewee_id).first.user.fullname(ip_address)
                              else
                                Team.find(reviewee_id).name
                              end
    team_reviewed_link_name = '(' + team_reviewed_link_name + ')'
    team_reviewed_link_name
  end

  def get_awarded_review_score(reviewer_id, team_id)
    num_rounds = @assignment.num_review_rounds
    (1..num_rounds).each { |round| instance_variable_set('@score_awarded_round_' + round.to_s, '-----') }
    (1..num_rounds).each do |round|
      if @review_scores[reviewer_id] && @review_scores[reviewer_id][round] && @review_scores[reviewer_id][round][team_id] && @review_scores[reviewer_id][round][team_id] != -1.0
        instance_variable_set('@score_awarded_round_' + round.to_s, @review_scores[reviewer_id][round][team_id].to_s + '%')
      end
    end
  end

  def review_metrics(round, team_id)
    %i[max min avg].each { |metric| instance_variable_set('@' + metric.to_s, '-----') }
    if @avg_and_ranges[team_id] && @avg_and_ranges[team_id][round] && %i[max min avg].all? { |k| @avg_and_ranges[team_id][round].key? k }
      %i[max min avg].each do |metric|
        metric_value = @avg_and_ranges[team_id][round][metric].nil? ? '-----' : @avg_and_ranges[team_id][round][metric].round(0).to_s + '%'
        instance_variable_set('@' + metric.to_s, metric_value)
      end
    end
  end

  def sort_reviewer_by_review_volume_desc
    @reviewers.each do |r|
      review_volumes = Response.volume_of_review_comments(@assignment.id, r.id)
      r.avg_vol_per_round = []
      review_volumes.each_index do |i|
        if i.zero?
          r.overall_avg_vol = review_volumes[0]
        else
          r.avg_vol_per_round.push(review_volumes[i])
        end
      end
    end
    @num_rounds = @assignment.num_review_rounds.to_f.to_i
    @all_reviewers_avg_vol_per_round = []
    @all_reviewers_overall_avg_vol = @reviewers.inject(0) { |sum, r| sum + r.overall_avg_vol } / (@reviewers.blank? ? 1 : @reviewers.length)
    @num_rounds.times do |round|
      @all_reviewers_avg_vol_per_round.push(@reviewers.inject(0) { |sum, r| sum + r.avg_vol_per_round[round] } / (@reviewers.blank? ? 1 : @reviewers.length))
    end
    @reviewers.sort! { |r1, r2| r2.overall_avg_vol <=> r1.overall_avg_vol }
  end

  def initialize_chart_elements(reviewer)
    chart_service = ChartInitializationService.new(
      reviewer,
      @num_rounds,
      @all_reviewers_avg_vol_per_round,
      @all_reviewers_overall_avg_vol
    )
    chart_service.initialize_chart_elements
  end

  def display_volume_metric_chart(reviewer)
    chart_service = ChartDataService.new(reviewer, @assignment)
    data = chart_service.volume_metric_chart_data
    options = chart_service.volume_metric_chart_options
    bar_chart data, options
  end
  
  def display_tagging_interval_chart(intervals)
    threshold = 30
    intervals = intervals.select { |v| v < threshold }
    unless intervals.empty?
      interval_mean = intervals.reduce(:+) / intervals.size.to_f
    end
    data = {
      labels: [*1..intervals.length],
      datasets: [
        {
          backgroundColor: 'rgba(255,99,132,0.8)',
          data: intervals,
          label: 'time intervals'
        },
        unless intervals.empty?
          {
            data: Array.new(intervals.length, interval_mean),
            label: 'Mean time spent'
          }
        end
      ]
    }
    options = {
      width: '200',
      height: '125',
      scales: {
        yAxes: [{
          stacked: false,
          ticks: {
            beginAtZero: true
          }
        }],
        xAxes: [{
          stacked: false
        }]
      }
    }
    line_chart data, options
  end

  def calculate_key_chart_information(intervals)
    threshold = 30
    interval_precision = 2 
    intervals = intervals.select { |v| v < threshold }

    unless intervals.empty?
      metrics = {}
      metrics[:mean] = (intervals.reduce(:+) / intervals.size.to_f).round(interval_precision)
      metrics[:min] = intervals.min
      metrics[:max] = intervals.max
      sum = intervals.inject(0) { |accum, i| accum + (i - metrics[:mean])**2 }
      metrics[:variance] = (sum / intervals.size.to_f).round(interval_precision)
      metrics[:stand_dev] = Math.sqrt(metrics[:variance]).round(interval_precision)
      metrics
    end
  end

  def list_review_submissions(participant_id, reviewee_team_id, response_map_id)
    participant = Participant.find(participant_id)
    team = AssignmentTeam.find(reviewee_team_id)
    html = ''
    unless team.nil? || participant.nil?
      review_submissions_path = team.path + '_review' + '/' + response_map_id.to_s
      files = team.submitted_files(review_submissions_path)
      html += display_review_files_directory_tree(participant, files) if files.present?
    end
    html.html_safe
  end

  def list_hyperlink_submission(response_map_id, question_id)
    assignment = Assignment.find(@id)
    curr_round = assignment.try(:num_review_rounds)
    curr_response = Response.where(map_id: response_map_id, round: curr_round).first
    answer_with_link = Answer.where(response_id: curr_response.id, question_id: question_id).first if curr_response
    comments = answer_with_link.try(:comments)
    html = ''
    html += display_hyperlink_in_peer_review_question(comments) if comments.present? && comments.start_with?('http')
    html.html_safe
  end

  
  def get_each_review_and_feedback_response_map(author)
    @team_id = TeamsUser.team_id(@id.to_i, author.user_id)
    @review_response_map_ids = ReviewResponseMap.where(['reviewed_object_id = ? and reviewee_id = ?', @id, @team_id]).pluck('id')
    feedback_response_map_record(author)
    @rspan_round_one = @review_responses_round_one.length
    @rspan_round_two = @review_responses_round_two.length
    @rspan_round_three = @review_responses_round_three.nil? ? 0 : @review_responses_round_three.length
  end

  def feedback_response_map_record(author)
    { 1 => 'one', 2 => 'two', 3 => 'three' }.each do |key, round_num|
      instance_variable_set('@review_responses_round_' + round_num,
                            Response.where(['map_id IN (?) and round = ?', @review_response_map_ids, key]))
      instance_variable_set('@feedback_response_maps_round_' + round_num,
                            FeedbackResponseMap.where(['reviewed_object_id IN (?) and reviewer_id = ?',
                                                       instance_variable_get('@all_review_response_ids_round_' + round_num), author.id]))
    end
  end

  def get_certain_review_and_feedback_response_map(author)
    @feedback_response_maps = FeedbackResponseMap.where(['reviewed_object_id IN (?) and reviewer_id = ?', @all_review_response_ids, author.id])
    @team_id = TeamsUser.team_id(@id.to_i, author.user_id)
    @review_response_map_ids = ReviewResponseMap.where(['reviewed_object_id = ? and reviewee_id = ?', @id, @team_id]).pluck('id')
    @review_responses = Response.where(['map_id IN (?)', @review_response_map_ids])
    @rspan = @review_responses.length
  end

  def get_css_style_for_calibration_report(diff)
    dict = { 0 => 'c5', 1 => 'c4', 2 => 'c3', 3 => 'c2' }
    css_class = if dict.key?(diff.abs)
                  dict[diff.abs]
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