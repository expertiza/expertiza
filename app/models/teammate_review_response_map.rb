class TeammateReviewResponseMap < ResponseMap
  belongs_to :reviewee, class_name: 'Participant', foreign_key: 'reviewee_id'
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'reviewed_object_id'

  def questionnaire
    self.assignment.questionnaires.find_by_type('TeammateReviewQuestionnaire')
  end

  def contributor
    nil
  end

  def get_title
    "Teammate Review"
  end

  def self.teammate_response_report(id)
    @reviewers = TeammateReviewResponseMap.select("DISTINCT reviewer_id").where("reviewed_object_id = ?", id)
  end

  # Send Teammate Review Emails
  # Refactored from email method in response.rb
  def email(defn, participant, assignment)
    defn[:body][:type] = "Teammate Review"
    participant = AssignmentParticipant.find(reviewee_id)
    topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
    defn[:body][:obj_name] = assignment.name
    user = User.find(participant.user_id)
    defn[:body][:first_name] = user.fullname
    defn[:to] = user.email
    Mailer.sync_message(defn).deliver
  end

  def update_good_teammate_badge

    number_of_scores = 0
    aggregate_score = 0
    average_score = 0

    # Get the threshold for this assigment's Good Teammate badge.
    threshold = AssignmentBadge.find_by(badge_id: 2, assignment_id: assignment.id).threshold

    # Get all teammate reviews that have been submitted for this reviewee.
    reviews = TeammateReviewResponseMap.where(reviewee_id: reviewee.id)

    # Loop through each of these teammate reviews.
    reviews.each do |review|

      # Get the response for each review.
      response = Response.find_by(map_id: review.id)

      # Make sure the response exists.
      unless response.nil?

        # Count the number of responses.
        number_of_scores += 1

        # Collect the aggregate score of the responses.
        aggregate_score += response.get_average_score

      end
    end

    # Calculate the overall average score across all teammate reviews.
    average_score = aggregate_score / number_of_scores

    # Retrieve the Good Teammate badge for the reviewee if it exists.
    good_teammate_badge = AwardedBadge.find_by(badge_id: 2, participant_id: reviewee.id)

    # If the reviewee has not been awarded this badge, but their average rises above the threshold, award the badge.
    if (good_teammate_badge == nil && average_score >= threshold)
      AwardedBadge.create(badge_id: 2, participant_id: reviewee.id)
    end

    # If the reviewee has been awarded this badge, but their average drops below the threshold, revoke the badge.
    if (good_teammate_badge != nil && average_score < threshold)
      AwardedBadge.find_by(badge_id: 2, participant_id: reviewee.id).delete
    end
  end
end
