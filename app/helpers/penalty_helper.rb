module PenaltyHelper
  def calculate_penalty(participant_id)
    @submission_deadline_type_id = 1
    @review_deadline_type_id = 2
    @meta_review_deadline_type_id = 5
    @participant = AssignmentParticipant.find(participant_id)
    @assignment = @participant.assignment
    if @assignment.late_policy_id
      late_policy = LatePolicy.find(@assignment.late_policy_id)
      @penalty_per_unit = late_policy.penalty_per_unit
      @max_penalty_for_no_submission = late_policy.max_penalty
      @penalty_unit = late_policy.penalty_unit
    end
    penalties = { submission: 0, review: 0, meta_review: 0 }
    penalties[:submission] = calculate_submission_penalty
    penalties[:review] = calculate_review_penalty
    penalties[:meta_review] = calculate_meta_review_penalty
    penalties
  end

  def calculate_submission_penalty
    return 0 if @penalty_per_unit.nil?

    submission_due_date = AssignmentDueDate.where(deadline_type_id: @submission_deadline_type_id,
                                                  parent_id: @assignment.id).first.due_at
    submission_records = SubmissionRecord.where(team_id: @participant.team.id, assignment_id: @participant.assignment.id)
    late_submission_times = submission_records.select { |submission_record| submission_record.updated_at > submission_due_date }
    if late_submission_times.any?
      last_submission_time = late_submission_times.last.updated_at
      if last_submission_time > submission_due_date
        time_difference = last_submission_time - submission_due_date
        penalty_units = calculate_penalty_units(time_difference, @penalty_unit)
        penalty_for_submission = penalty_units * @penalty_per_unit
        if penalty_for_submission > @max_penalty_for_no_submission
          @max_penalty_for_no_submission
        else
          penalty_for_submission
        end
      end
    else
      submission_records.any? ? 0 : @max_penalty_for_no_submission
    end
  end

  def calculate_review_penalty
    penalty = 0
    num_of_reviews_required = @assignment.num_reviews
    if num_of_reviews_required > 0 && !@penalty_per_unit.nil?
      review_mappings = ReviewResponseMap.where(reviewer_id: @participant.get_reviewer.id)
      review_due_date = AssignmentDueDate.where(deadline_type_id: @review_deadline_type_id,
                                                parent_id: @assignment.id).first
      penalty = compute_penalty_on_reviews(review_mappings, review_due_date.due_at, num_of_reviews_required) unless review_due_date.nil?
    end
    penalty
  end

  def calculate_meta_review_penalty
    penalty = 0
    num_of_meta_reviews_required = @assignment.num_review_of_reviews
    if num_of_meta_reviews_required > 0 && !@penalty_per_unit.nil?
      meta_review_mappings = MetareviewResponseMap.where(reviewer_id: @participant.id)
      meta_review_due_date = AssignmentDueDate.where(deadline_type_id: @meta_review_deadline_type_id,
                                                     parent_id: @assignment.id).first
      penalty = compute_penalty_on_reviews(meta_review_mappings, meta_review_due_date.due_at, num_of_meta_reviews_required) unless meta_review_due_date.nil?
    end
    penalty
  end

  def compute_penalty_on_reviews(review_mappings, review_due_date, num_of_reviews_required)
    review_map_created_at_list = []
    penalty = 0
    # Calculate the number of reviews that the user has completed so far.
    review_mappings.each do |map|
      unless map.response.empty?
        created_at = Response.find_by(map_id: map.id).created_at
        review_map_created_at_list << created_at
      end
    end
    review_map_created_at_list.sort!
    (0...num_of_reviews_required).each do |i|
      if review_map_created_at_list.at(i)
        if review_map_created_at_list.at(i) > review_due_date
          time_difference = review_map_created_at_list.at(i) - review_due_date
          penalty_units = calculate_penalty_units(time_difference, @penalty_unit)
          penalty_for_this_review = penalty_units * @penalty_per_unit
          if penalty_for_this_review > @max_penalty_for_no_submission
            penalty = @max_penalty_for_no_submission
          else
            penalty += penalty_for_this_review
          end
        end
      else
        penalty = @max_penalty_for_no_submission
      end
    end
    penalty
  end

  def calculate_penalty_units(time_difference, penalty_unit)
    case penalty_unit
    when 'Minute'
      time_difference / 60
    when 'Hour'
      time_difference / 3600
    when 'Day'
      time_difference / 86_400
    end
  end
end
