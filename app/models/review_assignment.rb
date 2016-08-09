module ReviewAssignment
  # assign the reviewer to review the assignment_team's submission. Only used in the assignments that do not have any topic
  # Parameter assignment_team is the candidate assignment team, it cannot be a team w/o submission, or have reviewed by reviewer, or reviewer's own team.
  # (guaranteed by candidate_assignment_teams_to_review method)
  def assign_reviewer_dynamically_no_topic(reviewer, assignment_team)
    if assignment_team.nil?
      raise "There are no more submissions available for that review right now. Try again later."
    end

    assignment_team.assign_reviewer(reviewer)
  end

  def assign_reviewer_dynamically(reviewer, topic)
    # The following method raises an exception if not successful which
    # has to be captured by the caller (in review_mapping_controller)
    contributor = contributor_to_review(reviewer, topic)
    contributor.assign_reviewer(reviewer)
  end

end