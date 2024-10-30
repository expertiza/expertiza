module ReviewAssignment
  def contributors
    # ACS Contributors are just teams, so removed check to see if it is a team assignment
    @contributors ||= teams # ACS
  end

  # Returns a set of topics that can be reviewed.
  # We choose the topics if one of its submissions has received the fewest reviews so far
  # reviewer, the parameter, is an object of Participant
  def candidate_topics_to_review(reviewer)
    return nil if sign_up_topics.empty? # This is not a topic assignment

    # Initialize contributor set with all teams participating in this assignment
    contributor_set = Array.new(contributors)

    # Reject contributors that have not selected a topic, or have no submissions
    contributor_set = reject_by_no_topic_selection_or_no_submission(contributor_set)

    # Reject contributions of topics whose deadline has passed, or which are not reviewable in the current stage
    contributor_set = reject_by_deadline(contributor_set)

    # Filter submissions already reviewed by reviewer
    contributor_set = reject_previously_reviewed_submissions(contributor_set, reviewer)

    # Filter submission by reviewer him/her self
    contributor_set = reject_own_submission(contributor_set, reviewer)

    # Filter the contributors with the least number of reviews
    # (using the fact that each contributor is associated with a topic)
    contributor_set = reject_by_least_reviewed(contributor_set)

    contributor_set = reject_by_max_reviews_per_submission(contributor_set)

    # if this assignment does not allow reviewer to review other artifacts on the same topic,
    # remove those teams from candidate list.
    contributor_set = reject_by_same_topic(contributor_set, reviewer) unless can_review_same_topic?

    # Add topics for all remaining submissions to a list of available topics for review
    candidate_topics = Set.new
    contributor_set.each do |contributor|
      candidate_topics.add(signed_up_topic(contributor))
    end
    candidate_topics
  end

  def signed_up_topic(team)
    # The purpose is to return the topic that the contributor has signed up to do for this assignment.
    # Returns a record from the sign_up_topic table that gives the topic_id for which the contributor has signed up
    # Look for the topic_id where the team_id equals the contributor id (contributor is a team or a participant)

    # If this is an assignment with quiz required
    if require_quiz?
      sign_ups = SignedUpTeam.where(team_id: team.id)
      sign_ups.each do |sign_up|
        sign_up_topic = SignUpTopic.find(sign_up.topic_id)
        if sign_up_topic.assignment_id == id
          contributors_sign_up_topic = sign_up_topic
          return contributors_sign_up_topic
        end
      end
    end

    # Look for the topic_id where the team_id equals the contributor id (contributor is a team)
    return if SignedUpTeam.where(team_id: team.id, is_waitlisted: 0).empty?

    topic_id = SignedUpTeam.find_by(team_id: team.id, is_waitlisted: 0).topic_id
    SignUpTopic.find(topic_id)
  end

  def assign_reviewer_dynamically(reviewer, topic)
    # The following method raises an exception if not successful which
    # has to be captured by the caller (in review_mapping_controller)
    contributor = contributor_to_review(reviewer, topic)
    contributor.assign_reviewer(reviewer)
  end

  # This method is only for the assignments without topics
  def candidate_assignment_teams_to_review(reviewer)
    # the contributors are AssignmentTeam objects
    contributor_set = Array.new(contributors)

    # Reject contributors that have no submissions
    contributor_set.select!(&:has_submissions?)

    # Filter submissions already reviewed by reviewer
    contributor_set = reject_previously_reviewed_submissions(contributor_set, reviewer)

    # Filter submission by reviewer him/her self
    contributor_set = reject_own_submission(contributor_set, reviewer)

    # Filter the contributors with the least number of reviews
    contributor_set = reject_by_least_reviewed(contributor_set)

    contributor_set = reject_by_max_reviews_per_submission(contributor_set)

    contributor_set
  end

  # assign the reviewer to review the assignment_team's submission. Only used in the assignments that do not have any topic
  # Parameter assignment_team is the candidate assignment team, it cannot be a team w/o submission, or have reviewed by reviewer, or reviewer's own team.
  # (guaranteed by candidate_assignment_teams_to_review method)
  def assign_reviewer_dynamically_no_topic(reviewer, assignment_team)
    raise 'There are no more submissions available for that review right now. Try again later.' if assignment_team.nil?

    assignment_team.assign_reviewer(reviewer)
  end

  private

  def reject_by_least_reviewed(contributor_set)
    contributor = contributor_set.min_by { |contributor_item| contributor_item.review_mappings.reject { |review_mapping| review_mapping.response.nil? }.count }
    min_reviews = begin
                    contributor.review_mappings.reject { |review_mapping| review_mapping.response.nil? }.count
                  rescue StandardError
                    0
                  end
    contributor_set.reject! { |contributor_item| contributor_item.review_mappings.reject { |review_mapping| review_mapping.response.nil? }.count > min_reviews + review_topic_threshold }
    contributor_set
  end

  def reject_by_max_reviews_per_submission(contributor_set)
    contributor_set.reject! { |contributor| contributor.responses.select(&:is_submitted).count >= max_reviews_per_submission }
    contributor_set
  end

  def reject_by_same_topic(contributor_set, reviewer)
    reviewer_team = AssignmentTeam.team(reviewer)
    # it is possible that this reviewer does not have a team, if so, do nothing
    if reviewer_team
      topic_id = reviewer_team.topic
      # it is also possible that this reviewer has team, but this team has no topic yet, if so, do nothing
      contributor_set = contributor_set.reject { |contributor| contributor.topic == topic_id } if topic_id
    end

    contributor_set
  end

  def reject_previously_reviewed_submissions(contributor_set, reviewer)
    contributor_set = contributor_set.reject { |contributor| contributor.reviewed_by?(reviewer) }
    contributor_set
  end

  def reject_own_submission(contributor_set, reviewer)
    contributor_set.reject! { |contributor| contributor.user?(User.find(reviewer.user_id)) }
    contributor_set
  end

  def reject_by_deadline(contributor_set)
    contributor_set.reject! do |contributor|
      (contributor.assignment.current_stage(signed_up_topic(contributor).id) == 'Complete') ||
        !contributor.assignment.can_review(signed_up_topic(contributor).id)
    end
    contributor_set
  end

  def reject_by_no_topic_selection_or_no_submission(contributor_set)
    contributor_set.reject! { |contributor| signed_up_topic(contributor).nil? || !contributor.has_submissions? }
    contributor_set
  end

  # Returns a contributor to review if available, otherwise will raise an error
  def contributor_to_review(reviewer, topic)
    raise 'Please select a topic' if topics? && topic.nil?
    raise 'This assignment does not have topics' if !topics? && topic
    # This condition might happen if the reviewer waited too much time in the
    # select topic page and other students have already selected this topic.
    # Another scenario is someone that deliberately modifies the view.
    raise 'This topic has too many reviews; please select another one.' if topic && !candidate_topics_to_review(reviewer).include?(topic)

    contributor_set = Array.new(contributors)
    work = topic.nil? ? 'assignment' : 'topic'

    # 1) Only consider contributors that worked on this topic; 2) remove reviewer as contributor
    # 3) remove contributors that have not submitted work yet
    contributor_set.reject! do |contributor|
      signed_up_topic(contributor) != topic || # both will be nil for assignments with no signup sheet
        contributor.includes?(reviewer) ||
        !contributor.has_submissions?
    end

    raise "There are no more submissions to review on this #{work}." if contributor_set.empty?

    # Reviewer can review each contributor only once
    contributor_set.reject! { |contributor| contributor.reviewed_by?(reviewer) }
    raise "You have already reviewed all submissions for this #{work}." if contributor_set.empty?

    # Reduce to the contributors with the least number of reviews ("responses") received
    min_contributor = contributor_set.min_by { |a| a.responses.count }
    min_reviews = min_contributor.responses.count
    contributor_set.reject! { |contributor| contributor.responses.count > min_reviews }

    # Pick the contributor whose most recent reviewer was assigned longest ago
    contributor_set.sort! { |a, b| a.review_mappings.last.id <=> b.review_mappings.last.id } if min_reviews > 0

    # Choose a contributor at random (.sample) from the remaining contributors.
    # Actually, we SHOULD pick the contributor who was least recently picked.  But sample
    # is much simpler, and probably almost as good, given that even if the contributors are
    # picked in round-robin fashion, the reviews will not be submitted in the same order that
    # they were picked.
    contributor_set.sample
  end
end
