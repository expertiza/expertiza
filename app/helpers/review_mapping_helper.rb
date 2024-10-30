module ReviewMappingHelper
  def create_report_table_header(headers = {})
    render partial: 'report_table_header', locals: { headers: headers }
  end

  # gets the response map data such as reviewer id, reviewed object id and type for use in the review report
  def get_data_for_review_report(reviewed_object_id, reviewer_id, type)
    row_number = 0
    (1..@assignment.num_review_rounds).each { |round| instance_variable_set('@review_in_round_' + round.to_s, 0) }

    response_maps = ResponseMap.where(['reviewed_object_id = ? AND reviewer_id = ? AND type = ?', reviewed_object_id, reviewer_id, type])
    response_maps.each do |ri|
      row_number += 1 if Team.exists?(id: ri.reviewee_id)
      responses = ri.response
      (1..@assignment.num_review_rounds).each do |round|
        instance_variable_set('@review_in_round_' + round.to_s, instance_variable_get('@review_in_round_' + round.to_s) + 1) if responses.exists?(round: round)
      end
    end
    [response_maps, row_number]
  end

  # gets the team name's color according to review and assignment submission status
  def get_team_color(response_map)
    assignment_created = @assignment.created_at
    assignment_due_dates = DueDate.where(parent_id: response_map.reviewed_object_id)

    return 'red' unless Response.exists?(map_id: response_map.id)

    determine_color(response_map, assignment_created, assignment_due_dates)
  end

  private def determine_color(response_map, assignment_created, assignment_due_dates)
    if response_map.try(:reviewer).try(:review_grade).nil?
      return 'blue' if response_for_each_round?(response_map)
      get_team_color_from_submission(response_map, assignment_created, assignment_due_dates)
    else
      'brown'
    end
  end

  # loops through the number of assignment review rounds and obtains the team colour
  def get_team_color_from_submission(response_map, assignment_created, assignment_due_dates)
    color = []
    (1..@assignment.num_review_rounds).each do |round|
      get_submission_state(response_map, assignment_created, assignment_due_dates, round, color)
    end
    color[-1]
  end

  # checks the submission state within each round and assigns team colour
  def get_submission_state(response_map, assignment_created, assignment_due_dates, round, color)
    if submitted_within_round?(round, response_map, assignment_created, assignment_due_dates)
      color.push 'purple'
    else
      process_submission_link(response_map, assignment_created, assignment_due_dates, round, color)
    end
  end

  # checks the submission link to determine if it exists and assigns team colour
  private def process_submission_link(response_map, assignment_created, assignment_due_dates, round, color)
    link = submitted_hyperlink(round, response_map, assignment_created, assignment_due_dates)
    if valid_submission_link?(link)
      color.push 'green'
    else
      link_updated_date = get_link_updated_at(link)
      color.push updated_since_last_submission?(round, assignment_due_dates, link_updated_date) ? 'purple' : 'green'
    end
  end

  # checks if the submission list exists or fits with standard url format of http:// or https:// and contains keyword "wiki"
  private def valid_submission_link?(link)
    link.nil? || (link !~ %r{https*:\/\/wiki(.*)}) # can be extended for github links in future
  end

  # checks if a review was submitted in every round
  def response_for_each_round?(response_map)
    response_count = 0
    total_num_rounds = @assignment.num_review_rounds
    (1..total_num_rounds).each do |round|
      response_count += 1 if Response.exists?(map_id: response_map.id, round: round)
    end
    response_count == total_num_rounds
  end

  # checks if a work was submitted within a given round
  def submitted_within_round?(round, response_map, assignment_created, assignment_due_dates)
    submission_due_date = assignment_due_dates.where(round: round, deadline_type_id: 1).try(:first).try(:due_at)
    submission = SubmissionRecord.where(team_id: response_map.reviewee_id, operation: ['Submit File', 'Submit Hyperlink'])
    subm_created_at = submission.where(created_at: assignment_created..submission_due_date)
    if round > 1
      subm_created_at = submitted_within_round_over_one(round, response_map, assignment_created, assignment_due_dates, submission_due_date, submission)
    end
    !subm_created_at.try(:first).try(:created_at).nil?
  end

  # checks the last round submission date if there is more than one round
  private def submitted_within_round_over_one(round, response_map, assignment_created, assignment_due_dates, submission_due_date, submission)
    submission_due_last_round = assignment_due_dates.where(round: round - 1, deadline_type_id: 1).try(:first).try(:due_at)
    submission.where(created_at: submission_due_last_round..submission_due_date)
  end

  # returns hyperlink of the assignment that has been submitted on the due date
  def submitted_hyperlink(round, response_map, assignment_created, assignment_due_dates)
    submission_due_date = assignment_due_dates.where(round: round, deadline_type_id: 1).try(:first).try(:due_at)
    subm_hyperlink = SubmissionRecord.where(team_id: response_map.reviewee_id, operation: 'Submit Hyperlink')
    submitted_h = subm_hyperlink.where(created_at: assignment_created..submission_due_date)
    submitted_h.try(:last).try(:content)
  end

  # returns last modified header date
  # only checks certain links (wiki)
  def get_link_updated_at(link)
    uri = URI(link)
    res = Net::HTTP.get_response(uri)['last-modified']
    res.to_time
  end

  # checks if a link was updated since last round submission
  def updated_since_last_submission?(round, due_dates, link_updated_at)
    submission_due_date = due_dates.where(round: round, deadline_type_id: 1).try(:first).try(:due_at)
    submission_due_last_round = due_dates.where(round: round - 1, deadline_type_id: 1).try(:first).try(:due_at)
    (link_updated_at < submission_due_date) && (link_updated_at > submission_due_last_round)
  end

  # For assignments with 1 team member, the following method returns user's fullname else it returns "team name" that a particular reviewee belongs to.
  def get_team_reviewed_link_name(max_team_size, _response, reviewee_id, ip_address)
    team_reviewed_link_name = if max_team_size == 1
                                TeamsUser.where(team_id: reviewee_id).first.user.fullname(ip_address)
                              else
                                # E1991 : check anonymized view here
                                Team.find(reviewee_id).name
                              end
    team_reviewed_link_name = '(' + team_reviewed_link_name + ')'
    # if !response.empty? and !response.last.is_submitted?
    team_reviewed_link_name
  end

  # get the review score for a specific team and a specific reviewer
  def get_awarded_review_score(reviewer_id, team_id)
    round_count = @assignment.num_review_rounds

    (1..round_count).each { |round| instance_variable_set('@score_awarded_round_' + round.to_s, '-----') }

    (1..round_count).each do |round|
      # Changing values of instance variable based on below condition
      if @review_scores[reviewer_id] && @review_scores[reviewer_id][round] && @review_scores[reviewer_id][round][team_id] && @review_scores[reviewer_id][round][team_id] != -1.0
        instance_variable_set('@score_awarded_round_' + round.to_s, @review_scores[reviewer_id][round][team_id].to_s + '%')
      end
    end
  end

  # Retrieves the minimum, maximum, and average grade values for the reviews in a given round
  def review_metrics(round, team_id)
    # Set default values ('-----') for @max, @min, and @avg instance variables
    %i[max min avg].each { |metric| instance_variable_set("@#{metric}", '-----') }

    # Check if the metrics for the given team and round exist in @avg_and_ranges
    if @avg_and_ranges[team_id] && @avg_and_ranges[team_id][round] && %i[max min avg].all? { |metric| @avg_and_ranges[team_id][round].key?(metric) }

      # Assign the metric values (or '-----' if they are nil) to the corresponding instance variables
      %i[max min avg].each do |metric|
        metric_value = @avg_and_ranges[team_id][round][metric]
        value_to_set = metric_value.nil? ? '-----' : "#{metric_value.round(0)}%"
        instance_variable_set("@#{metric}", value_to_set)
      end
    end
  end

  # Sorts the reviewers by the average volume of reviews in each round, in descending order
  def sort_reviewers_by_review_volume_desc
    get_reviewers_comment_volume
    # get the number of review rounds for the assignment
    @num_review_rounds = @assignment.num_review_rounds.to_f.to_i
    @all_reviewers_avg_volume_per_round = []
    @all_reviewers_overall_avg_volume = @reviewers.inject(0) { |sum, r| sum + r.overall_avg_vol } / (@reviewers.blank? ? 1 : @reviewers.length)
    @num_review_rounds.times do |round|
      @all_reviewers_avg_volume_per_round.push(@reviewers.inject(0) { |sum, r| sum + r.avg_vol_per_round[round] } / (@reviewers.blank? ? 1 : @reviewers.length))
    end
    @reviewers.sort! { |r1, r2| r2.overall_avg_vol <=> r1.overall_avg_vol }
  end

  # Get the volume of the reviewers comments
  def get_reviewers_comment_volume
    @reviewers.each do |reviewer|
      # get the volume of review comments
      review_volumes = Response.volume_of_review_comments(@assignment.id, reviewer.id)
      reviewer.avg_vol_per_round = []
      review_volumes.each_index do |i|
        if i.zero?
          reviewer.overall_avg_vol = review_volumes[0]
        else
          reviewer.avg_vol_per_round.push(review_volumes[i])
        end
      end
    end
  end

  # moves data of reviews in each round from a current round
  def initialize_chart_elements(reviewer)
    round = 0
    labels = []
    reviewer_data = []
    all_reviewers_data = []

    # Iterate through each round and collect data if the volume for all reviewers is greater than 0
    @num_review_rounds.times do |rnd|
      avg_volume_all_reviewers = @all_reviewers_avg_volume_per_round[rnd]
      # Skip rounds with no data for all reviewers
      next unless avg_volume_all_reviewers > 0
      round += 1
      labels.push round
      reviewer_data.push reviewer.avg_vol_per_round[rnd]
      all_reviewers_data.push avg_volume_all_reviewers
    end

    # Add 'Total' label and overall averages at the end
    labels.push 'Total'
    reviewer_data.push reviewer.overall_avg_vol
    all_reviewers_data.push @all_reviewers_overall_avg_volume
    [labels, reviewer_data, all_reviewers_data]
  end

  # Generates the bar chart displaying reviewer volume metrics
  def display_volume_metric_chart(reviewer)
    labels, reviewer_data, all_reviewers_data = initialize_chart_elements(reviewer)
    data = chart_data(labels, reviewer_data, all_reviewers_data)
    options = chart_options
    bar_chart data, options
  end

  # Prepares the chart data, including labels and datasets for reviewer volume metrics
  def chart_data(labels, reviewer_data, all_reviewers_data)
    {
      labels: labels,
      datasets: [
        {
          # Individual reviewer's volume
          label: 'vol.',
          backgroundColor: 'rgba(255,99,132,0.8)',
          borderWidth: 1,
          data: reviewer_data,
          yAxisID: 'bar-y-axis1'
        },
        {
          # Average volume for all reviewers
          label: 'avg. vol.',
          backgroundColor: 'rgba(255,206,86,0.8)',
          borderWidth: 1,
          data: all_reviewers_data,
          yAxisID: 'bar-y-axis2'
        }
      ]
    }
  end

  # Configures chart display options, including axes, legends, and grid lines
  def chart_options
    {
      legend: {
        position: 'top',
        labels: {
          usePointStyle: true
        }
      },
      width: '200',
      height: '225',
      scales: {
        yAxes: [
          {
            stacked: true,
            id: 'bar-y-axis1',
            barThickness: 10
          },
          {
            display: false,
            stacked: true,
            id: 'bar-y-axis2',
            barThickness: 15,
            type: 'category',
            categoryPercentage: 0.8,
            barPercentage: 0.9,
            gridLines: {
              offsetGridLines: true
            }
          }
        ],
        xAxes: [
          {
            stacked: false,
            ticks: {
              beginAtZero: true,
              stepSize: 50,
              max: 400
            }
          }
        ]
      }
    }
  end

  # Generates a line chart displaying time intervals for review tagging
  def display_tagging_interval_chart(intervals)
    intervals = filter_intervals(intervals)
    return if intervals.empty? # Skip chart generation if there are no valid intervals

    interval_mean = calculate_mean(intervals)
    data = chart_data(intervals, interval_mean)
    options = chart_options

    line_chart data, options
  end

  # Filters out intervals exceeding the threshold time
  def filter_intervals(intervals, threshold = 30)
    intervals.select { |interval| interval < threshold }
  end

  # Calculates the mean of the intervals
  def calculate_mean(intervals)
    intervals.reduce(:+) / intervals.size.to_f
  end

  # Prepares the data for the chart, including intervals and mean if applicable
  def chart_data(intervals, interval_mean)
    {
      labels: (1..intervals.length).to_a, # Labels each interval sequentially
      datasets: [
        {
          backgroundColor: 'rgba(255,99,132,0.8)',
          data: intervals,
          label: 'time intervals'
        },
        {
          data: Array.new(intervals.length, interval_mean),
          label: 'Mean time spent'
        }
      ]
    }
  end

  # Configures chart display options, including axis settings
  def chart_options
    {
      width: '200',
      height: '125',
      scales: {
        yAxes: [
          {
            stacked: false,
            ticks: {
              beginAtZero: true
            }
          }
        ],
        xAxes: [
          {
            stacked: false
          }
        ]
      }
    }
  end

  # Calculate mean, min, max, variance, and stand deviation for tagging intervals
  def calculate_key_chart_information(intervals)
    # if someone did not do any tagging in 30 seconds, then ignore this interval
    threshold = 30
    interval_precision = 2 # Round to 2 Decimal Places
    intervals = intervals.select { |v| v < threshold }

    # Get Metrics once tagging intervals are available
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
    # if no Hash object is returned, the UI handles it accordingly
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

  # Lists the hyperlink submission in peer review comments for a specific response and question.
  # This is designed for assignments where instructors want to quickly check if students pasted a link.
  def list_hyperlink_submission(response_map_id, question_id)
    assignment = fetch_assignment
    current_round = fetch_current_round(assignment)

    comments = fetch_hyperlink_comment(response_map_id, question_id, current_round)
    generate_hyperlink_html(comments)
  end

  # Fetches the assignment based on the instance variable @id
  def fetch_assignment
    Assignment.find(@id)
  end

  # Retrieves the current review round number, if available
  def fetch_current_round(assignment)
    assignment.try(:num_review_rounds)
  end

  # Fetches the hyperlink comment from the response and answer records
  def fetch_hyperlink_comment(response_map_id, question_id, current_round)
    response = Response.where(map_id: response_map_id, round: current_round).first
    answer = Answer.where(response_id: response.id, question_id: question_id).first if response
    answer.try(:comments)
  end

  # Generates HTML for displaying the hyperlink if it exists and starts with 'http'
  def generate_hyperlink_html(comments)
    html = ''
    html += display_hyperlink_in_peer_review_question(comments) if comments.present? && comments.start_with?('http')
    html.html_safe
  end

  # gets review and feedback responses for all rounds for the feedback report
  def get_each_review_and_feedback_response_map(author)
    @team_id = TeamsUser.team_id(@id.to_i, author.user_id)
    # Calculate how many responses one team received from each round
    # It is the feedback number each team member should make
    @review_response_map_ids = ReviewResponseMap.where(['reviewed_object_id = ? and reviewee_id = ?', @id, @team_id]).pluck('id')
    feedback_response_map_record(author)
    # rspan means the all peer reviews one student received, including unfinished one
    @rspan_round_one = @review_responses_round_one.length
    @rspan_round_two = @review_responses_round_two.length
    @rspan_round_three = @review_responses_round_three.nil? ? 0 : @review_responses_round_three.length
  end

  # This function sets the values of instance variable
  def feedback_response_map_record(author)
    { 1 => 'one', 2 => 'two', 3 => 'three' }.each do |key, round_num|
      instance_variable_set('@review_responses_round_' + round_num,
                            Response.where(['map_id IN (?) and round = ?', @review_response_map_ids, key]))
      # Calculate feedback response map records
      instance_variable_set('@feedback_response_maps_round_' + round_num,
                            FeedbackResponseMap.where(['reviewed_object_id IN (?) and reviewer_id = ?',
                                                       instance_variable_get('@all_review_response_ids_round_' + round_num), author.id]))
    end
  end

  # gets review and feedback responses for a certain round for the feedback report
  def get_certain_review_and_feedback_response_map(author)
    # Setting values of instance variables
    @feedback_response_maps = FeedbackResponseMap.where(['reviewed_object_id IN (?) and reviewer_id = ?', @all_review_response_ids, author.id])
    @team_id = TeamsUser.team_id(@id.to_i, author.user_id)
    @review_response_map_ids = ReviewResponseMap.where(['reviewed_object_id = ? and reviewee_id = ?', @id, @team_id]).pluck('id')
    @review_responses = Response.where(['map_id IN (?)', @review_response_map_ids])
    @rspan = @review_responses.length
  end

  # Determines the CSS class for a calibration report based on the difference
  # between a student's answer and the instructor's answer.
  # A smaller difference indicates a closer match to the instructor's answer.
  def get_css_style_for_calibration_report(diff)
    # CSS class mapping based on the absolute difference value
    css_class_mapping = { 0 => 'c5', 1 => 'c4', 2 => 'c3', 3 => 'c2' }

    # Return the CSS class based on the difference, defaulting to 'c1' for larger differences
    css_class_mapping.fetch(diff.abs, 'c1')
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
