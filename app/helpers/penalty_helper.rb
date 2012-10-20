module PenaltyHelper

  def calculate_penalty(participant_id)

    @max_penalty_per_missed_review = 3

    @submission_deadline_type_id = 1
    @review_deadline_type_id = 2
    @meta_review_deadline_type_id = 5

    @participant = AssignmentParticipant.find(participant_id)
    @assignment = @participant.assignment

    penalties = Hash.new(0)

    calculate_penalty = true
    if (calculate_penalty == true)             # TODO add calculate_penalty column to the assignment table and use its value to check if the penalty is to be calculated for the assignment or not
      stage = @assignment.get_current_stage(@participant.topic_id)
      if (stage == "Complete")

        # calculate submission penalty
        calculate_submission_penalty()

        # calculate review penalty
        penalties[:review] = calculate_review_penalty()
        penalties[:meta_review] = calculate_meta_review_penalty()
        penalties[:author_feedback] = calculate_author_feedback_penalty()
        penalties[:team_mate_feedback] = calculate_team_feedback_penalty()
      end
    end

    penalties
  end

  def calculate_submission_penalty

  end

  def calculate_review_penalty()
    # Check number of reviews required for the assignment
    # TODO : check how to set num_reviews in assignments table
    num_of_reviews_required = 2
    if (num_of_reviews_required > 0)

      #reviews
      if @assignment.team_assignment
        review_mappings = TeamReviewResponseMap.find_all_by_reviewer_id(@participant.id)
      else
        review_mappings = ParticipantReviewResponseMap.find_all_by_reviewer_id(@participant.id)
      end

      review_due_date = DueDate.find_by_deadline_type_id_and_assignment_id(@review_deadline_type_id, @assignment.id).due_at

      compute_penalty_on_reviews(review_mappings, review_due_date, num_of_reviews_required)
    end
  end

  def calculate_meta_review_penalty()

    # Check number of reviews required for the assignment
    # TODO : check how to set num_reviews in assignments table
    num_of_meta_reviews_required = 2
    if (num_of_meta_reviews_required > 0)

      meta_review_mappings = MetareviewResponseMap.find_all_by_reviewer_id(@participant.id)

      meta_review_due_date = DueDate.find_by_deadline_type_id_and_assignment_id(@meta_review_deadline_type_id, @assignment.id).due_at

      compute_penalty_on_reviews(meta_review_mappings, meta_review_due_date, num_of_meta_reviews_required)
    end
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

    review_map_created_at_after_due_date_list = Array.new

    # Calculate the number of reviews that the user has completed so far.
    num_of_reviews_completed_before_deadline = 0
    num_of_reviews_completed = 0
    review_mappings.each do |map|
      created_at = Response.find_by_map_id(map.id).created_at
      num_of_reviews_completed += 1 if map.response
      if(created_at < review_due_date)
        num_of_reviews_completed_before_deadline += 1
      else
        review_map_created_at_after_due_date_list <<  created_at
      end
    end

    review_map_created_at_after_due_date_list.sort!

    penalty = 0
    # assign max penalty for all the reviews which are not completed
    if(num_of_reviews_completed_before_deadline >= num_of_reviews_required)
      # no need to calculate the penalty
    else
      # assign maximum penalty for uncompleted reviews
      if(num_of_reviews_required > num_of_reviews_completed)
        penalty += (num_of_reviews_required - num_of_reviews_completed) * @max_penalty_per_missed_review
      else
        # calculate the penalty for reviews completed after deadline
        for i in 0..(num_of_reviews_required - num_of_reviews_completed_before_deadline)
          (review_map_created_at_after_due_date_list[i] - review_due_date) * @penalty_per_unit
        end
      end
    end
    penalty
  end

end