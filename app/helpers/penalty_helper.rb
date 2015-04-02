module PenaltyHelper

  def calculate_penalty(participant_id)

    @submission_deadline_type_id = 1
    @review_deadline_type_id = 2
    @meta_review_deadline_type_id = 5

    @participant = AssignmentParticipant.find(participant_id)
    @assignment = @participant.assignment
    if @assignment.late_policy_id
      @penalty_per_unit = LatePolicy.find(@assignment.late_policy_id).penalty_per_unit
      @max_penalty_for_no_submission = LatePolicy.find(@assignment.late_policy_id).max_penalty
      @penalty_unit = LatePolicy.find(@assignment.late_policy_id).penalty_unit
    end

    penalties = Hash.new(0)

    calculate_penalty = @assignment.calculate_penalty
    if (calculate_penalty == true)             # TODO add calculate_penalty column to the assignment table and use its value to check if the penalty is to be calculated for the assignment or not
      stage = @assignment.get_current_stage(@participant.topic_id)
      if (stage == "Finished")
        penalties[:submission] = calculate_submission_penalty()
        penalties[:review] = calculate_review_penalty()
        penalties[:meta_review] = calculate_meta_review_penalty()
        #penalties[:author_feedback] = calculate_author_feedback_penalty()
        #penalties[:team_mate_feedback] = calculate_team_feedback_penalty()
      end
    else
      penalties[:submission] = 0
      penalties[:review] = 0
      penalties[:meta_review] = 0
    end

    penalties
  end

  def set_penalty_policy()
    @late_policy = Assignment.find(@assignment_id).late_policy
    @late_policy.max_penalty
  end

  def calculate_submission_penalty
    penalty = 0
    # penalty_unit = @late_policy.penalty_unit
    submission_due_date = DueDate.where(deadline_type_id: @submission_deadline_type_id, assignment_id:  @assignment.id).first.due_at

    resubmission_times = @participant.resubmission_times
    if(resubmission_times.any?)
      last_submission_time = resubmission_times.at(resubmission_times.size-1).resubmitted_at
      if(last_submission_time > submission_due_date)
        if(@penalty_unit == 'Minute')
          penalty_minutes = ((last_submission_time - submission_due_date))/60
        elsif(@penalty_unit == 'Hour')
          penalty_minutes = ((last_submission_time - submission_due_date))/3600
        elsif(@penalty_unit == 'Day')
          penalty_minutes = ((last_submission_time - submission_due_date))/86400
        end
        penalty_for_submission = penalty_minutes * @penalty_per_unit
        if (penalty_for_submission > @max_penalty_for_no_submission)
          penalty = @max_penalty_for_no_submission
        else
          penalty = penalty_for_submission
        end
      end
    else
      penalty = @max_penalty_for_no_submission
    end
  end

  def calculate_review_penalty()

    penalty = 0
    num_of_reviews_required = @assignment.num_reviews
    if (num_of_reviews_required > 0)

      #reviews
      if @assignment.team_assignment
        review_mappings = TeamReviewResponseMap.where(reviewer_id: @participant.id)
      else
        review_mappings = ParticipantReviewResponseMap.where(reviewer_id: @participant.id)
      end

      review_due_date = DueDate.where(deadline_type_id: @review_deadline_type_id, assignment_id:  @assignment.id).first

      if(review_due_date != nil)
        penalty = compute_penalty_on_reviews(review_mappings, review_due_date.due_at, num_of_reviews_required)
      end
    end
    penalty
  end

  def calculate_meta_review_penalty()
    penalty = 0
    num_of_meta_reviews_required = @assignment.num_review_of_reviews
    if (num_of_meta_reviews_required > 0)

      meta_review_mappings = MetareviewResponseMap.where(reviewer_id: @participant.id)

      meta_review_due_date = DueDate.where(deadline_type_id: @meta_review_deadline_type_id, assignment_id:  @assignment.id).first

      if(meta_review_due_date != nil)
        penalty = compute_penalty_on_reviews(meta_review_mappings, meta_review_due_date.due_at, num_of_meta_reviews_required)
      end
    end
    penalty
  end

  def calculate_author_feedback_penalty
    penalty = 0
    penalty
  end

  def calculate_team_feedback_penalty
    penalty = 0
    penalty
  end

  def compute_penalty_on_reviews(review_mappings, review_due_date, num_of_reviews_required)

    review_map_created_at_list = Array.new

    ## Calculate the number of reviews that the user has completed so far.
    #num_of_reviews_completed_before_deadline = 0
    #num_of_reviews_completed = 0
    #review_mappings.each do |map|
    #  created_at = Response.find_by_map_id(map.id).created_at
    #  num_of_reviews_completed += 1 if map.response
    #  if(created_at < review_due_date)
    #    num_of_reviews_completed_before_deadline += 1
    #  else
    #    review_map_created_at_after_due_date_list <<  created_at
    #  end
    #end
    #
    #review_map_created_at_after_due_date_list.sort!
    #
    #penalty = 0
    ## assign max penalty for all the reviews which are not completed
    #if(num_of_reviews_completed_before_deadline >= num_of_reviews_required)
    #  # no need to calculate the penalty
    #else
    #  # assign maximum penalty for uncompleted reviews
    #  if(num_of_reviews_required > num_of_reviews_completed)
    #    penalty += (num_of_reviews_required - num_of_reviews_completed) * @max_penalty_per_missed_review
    #  else
    #    # calculate the penalty for reviews completed after deadline
    #    for i in 0..(num_of_reviews_required - num_of_reviews_completed_before_deadline)
    #      penalty += (review_map_created_at_after_due_date_list[i] - review_due_date) * @penalty_per_unit
    #    end
    #  end
    #end
    #penalty

    penalty = 0

    # Calculate the number of reviews that the user has completed so far.
    review_mappings.each do |map|
      if map.response
        created_at = Response.find_by_map_id(map.id).created_at
        review_map_created_at_list <<  created_at
      end
    end

    review_map_created_at_list.sort!

    for i in 0...num_of_reviews_required
      if review_map_created_at_list.at(i)
        if (review_map_created_at_list.at(i) > review_due_date)

          if(@penalty_unit == 'Minute')
            penalty_minutes = ((review_map_created_at_list.at(i) - review_due_date))/60
          elsif(@penalty_unit == 'Hour')
            penalty_minutes = ((review_map_created_at_list.at(i) - review_due_date))/3600
          elsif(@penalty_unit == 'Day')
            penalty_minutes = ((review_map_created_at_list.at(i) - review_due_date))/86400
          end
          penalty_for_this_review = penalty_minutes * @penalty_per_unit
          if (penalty_for_this_review > @max_penalty_for_no_submission)
            penalty = @max_penalty_for_no_submission
          else
            penalty += penalty_for_this_review
          end
        end
      elsif
        penalty = @max_penalty_for_no_submission
      end
    end
    penalty
  end
end
