class TeammateReviewResponseMap < ResponseMap
  belongs_to :reviewee, inverse_of: :response_maps, class_name: 'Participant', foreign_key: 'reviewee_id'
  belongs_to :assignment, inverse_of: :response_maps, class_name: 'Assignment', foreign_key: 'reviewed_object_id'

  def questionnaire
    self.assignment.questionnaires.find_by(type: 'TeammateReviewQuestionnaire')
  end

  def contributor
    nil
  end

  def title
    "Teammate Review"
  end

  def self.teammate_response_report(id)
    TeammateReviewResponseMap.select("DISTINCT reviewer_id").where("reviewed_object_id = ?", id)
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
end
