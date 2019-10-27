module ReviewMappingHelper
  def create_report_table_header(headers = {})
    render partial: 'report_table_header', locals: {headers: headers}
  end

  #
  # gets the response map data such as reviewer id, reviewd object id and type for the review report
  #
  def get_data_for_review_report(reviewed_object_id, reviewer_id, type)
    rspan = 0
    (1..@assignment.num_review_rounds).each {|round| instance_variable_set("@review_in_round_" + round.to_s, 0) }

    response_maps = ResponseMap.where(["reviewed_object_id = ? AND reviewer_id = ? AND type = ?", reviewed_object_id, reviewer_id, type])
    response_maps.each do |ri|
      rspan += 1 if Team.exists?(id: ri.reviewee_id)
      responses = ri.response
      (1..@assignment.num_review_rounds).each do |round|
        instance_variable_set("@review_in_round_" + round.to_s, instance_variable_get("@review_in_round_" + round.to_s) + 1) if responses.exists?(round: round)
      end
    end
    [response_maps, rspan]
  end

  #
  # gets the team name's color according to review and assignment submission status
  #
  def get_team_colour(response_map)
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
              link_updated_at = get_link_updated_at(link)
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

  # checks if a review was submitted in every round and gives the total responses count
  def response_for_each_round?(response_map)
    num_responses = 0
    total_num_rounds = @assignment.num_review_rounds
    (1..total_num_rounds).each do |round|
      num_responses += 1 if Response.exists?(map_id: response_map.id, round: round)
    end
    num_responses == total_num_rounds
  end

  # checks if a work was submitted within a given round
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
  def link_updated_since_last?(round, due_dates, link_updated_at)
    submission_due_date = due_dates.where(round: round, deadline_type_id: 1).try(:first).try(:due_at)
    submission_due_last_round = due_dates.where(round: round - 1, deadline_type_id: 1).try(:first).try(:due_at)
    (link_updated_at < submission_due_date) && (link_updated_at > submission_due_last_round)
  end

  # For assignments with 1 team member, the following method returns user's fullname else it returns "team name" that a particular reviewee belongs to.
  def get_team_reviewed_link_name(max_team_size, response, reviewee_id)
    team_reviewed_link_name = if max_team_size == 1
                                TeamsUser.where(team_id: reviewee_id).first.user.fullname
                              else
                                Team.find(reviewee_id).name
                              end
    team_reviewed_link_name = "(" + team_reviewed_link_name + ")" if !response.empty? and !response.last.is_submitted?
    team_reviewed_link_name
  end

  # if the current stage is "submission" or "review", function returns the current round number otherwise,
  # if the current stage is "Finished" or "metareview", function returns the number of rounds of review completed.
  # def get_current_round(reviewer_id)
  #   user_id = Participant.find(reviewer_id).user.id
  #   topic_id = SignedUpTeam.topic_id(@assignment.id, user_id)
  #   @assignment.number_of_current_round(topic_id)
  #   @assignment.num_review_rounds if @assignment.get_current_stage(topic_id) == "Finished" || @assignment.get_current_stage(topic_id) == "metareview"
  # end

  # gets the review score awarded based on each round of the review
  def get_awarded_review_score(reviewer_id, team_id)
    (1..@assignment.num_review_rounds).each {|round| instance_variable_set("@score_awarded_round_" + round.to_s, '-----') }
    (1..@assignment.num_review_rounds).each do |round|
      if @review_scores[reviewer_id] && @review_scores[reviewer_id][round] && @review_scores[reviewer_id][round][team_id] && @review_scores[reviewer_id][round][team_id] != -1.0
        instance_variable_set("@score_awarded_round_" + round.to_s, @review_scores[reviewer_id][round][team_id].inspect + '%')
      end
    end
  end

  # gets minimum, maximum and average value for all the reviews
  def get_review_metrics(round, team_id)
    %i[max min avg].each {|metric| instance_variable_set('@' + metric.to_s, '-----') }
    if @avg_and_ranges[team_id] && @avg_and_ranges[team_id][round] && %i[max min avg].all? {|k| @avg_and_ranges[team_id][round].key? k }
      %i[max min avg].each do |metric|
        metric_value = @avg_and_ranges[team_id][round][metric].nil? ? '-----' : @avg_and_ranges[team_id][round][metric].round(0).to_s + '%'
        instance_variable_set('@' + metric.to_s, metric_value)
      end
    end
  end

  # sorts the reviewers by the average volume of reviews in each round, in descending order
  def sort_reviewer_by_review_volume_desc
    @reviewers.each do |r|
      r.overall_avg_vol,
          r.avg_vol_in_round_1,
          r.avg_vol_in_round_2,
          r.avg_vol_in_round_3 = Response.get_volume_of_review_comments(@assignment.id, r.id)
    end
    @all_reviewers_overall_avg_vol = @reviewers.inject(0) {|sum, r| sum += r.overall_avg_vol } / (@reviewers.blank? ? 1 : @reviewers.length)
    @all_reviewers_avg_vol_in_round_1 = @reviewers.inject(0) {|sum, r| sum += r.avg_vol_in_round_1 } / (@reviewers.blank? ? 1 : @reviewers.length)
    @all_reviewers_avg_vol_in_round_2 = @reviewers.inject(0) {|sum, r| sum += r.avg_vol_in_round_2 } / (@reviewers.blank? ? 1 : @reviewers.length)
    @all_reviewers_avg_vol_in_round_3 = @reviewers.inject(0) {|sum, r| sum += r.avg_vol_in_round_3 } / (@reviewers.blank? ? 1 : @reviewers.length)
    @reviewers.sort! {|r1, r2| r2.overall_avg_vol <=> r1.overall_avg_vol }
  end

  # displays the average scores in round 1, 2 and 3
  def display_volume_metric(overall_avg_vol, avg_vol_in_round_1, avg_vol_in_round_2, avg_vol_in_round_3)
    metric = "Avg. Volume: #{overall_avg_vol} <br/> ("
    metric += "1st: " + avg_vol_in_round_1.to_s if avg_vol_in_round_1 > 0
    metric += ", 2nd: " + avg_vol_in_round_2.to_s if avg_vol_in_round_2 > 0
    metric += ", 3rd: " + avg_vol_in_round_3.to_s if avg_vol_in_round_3 > 0
    metric += ")"
    metric.html_safe
  end

  # moves data of reviews in each round from a current round
  def initialize_chart_elements(reviewer)
    round = 0
    labels = []
    reviewer_data = []
    all_reviewers_data = []
    if @all_reviewers_avg_vol_in_round_1 > 0
      round += 1
      labels.push '1st'
      reviewer_data.push reviewer.avg_vol_in_round_1
      all_reviewers_data.push @all_reviewers_avg_vol_in_round_1
    end
    if @all_reviewers_avg_vol_in_round_2 > 0
      round += 1
      labels.push '2nd'
      reviewer_data.push reviewer.avg_vol_in_round_2
      all_reviewers_data.push @all_reviewers_avg_vol_in_round_2
    end
    if @all_reviewers_avg_vol_in_round_3 > 0
      round += 1
      labels.push '3rd'
      reviewer_data.push reviewer.avg_vol_in_round_3
      all_reviewers_data.push @all_reviewers_avg_vol_in_round_3
    end
    labels.push 'Total'
    reviewer_data.push reviewer.overall_avg_vol
    all_reviewers_data.push @all_reviewers_overall_avg_vol
    [labels, reviewer_data, all_reviewers_data]
  end

  # The data of all the reviews is displayed in the form of a bar chart
  def display_volume_metric_chart(reviewer)
    labels, reviewer_data, all_reviewers_data = initialize_chart_elements(reviewer)
    data = {
      labels: labels,
      datasets: [
        {
          label: 'vol.',
          backgroundColor: "rgba(255,99,132,0.8)",
          borderWidth: 1,
          data: reviewer_data,
          yAxisID: "bar-y-axis1"
        },
        {
          label: 'avg. vol.',
          backgroundColor: "rgba(255,206,86,0.8)",
          borderWidth: 1,
          data: all_reviewers_data,
          yAxisID: "bar-y-axis2"
        }
      ]
    }
    options = {
      legend: {
        position: 'top',
        labels: {
          usePointStyle: true
        }
      },
      width: "200",
      height: "125",
      scales: {
        yAxes: [{
          stacked: true,
          id: "bar-y-axis1",
          barThickness: 10
        }, {
          display: false,
          stacked: true,
          id: "bar-y-axis2",
          barThickness: 15,
          type: 'category',
          categoryPercentage: 0.8,
          barPercentage: 0.9,
          gridLines: {
            offsetGridLines: true
          }
        }],
        xAxes: [{
          stacked: false,
          ticks: {
            beginAtZero: true,
            stepSize: 50,
            max: 400
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
      review_submissions_path = team.path + "_review" + "/" + response_map_id.to_s
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

  # gets review and feedback responses for all rounds for the feedback report
  def get_each_review_and_feedback_response_map(author)
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

  # gets review and feedback responses for a certain round for the feedback report
  def get_certain_review_and_feedback_response_map(author)
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
    dict = {0 => 'c5',1 => 'c4',2 => 'c3',3 => 'c2'}
    if dict.key?(diff.abs)
      css_class = dict[diff.abs]
    else
      css_class = 'c1'
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
