class TeammateReviewResponseMap < ResponseMap
  belongs_to :reviewee, class_name: 'Participant', foreign_key: 'reviewee_id'
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'reviewed_object_id'

  def itemnaire
    assignment.itemnaires.find_by(type: 'TeammateReviewQuestionnaire')
  end

  # E2147 : gets itemnaire for a particular duty. If no itemnaire is found for the given duty, returns the
  # default itemnaire set for TeammateReviewQuestionnaire type.
  def itemnaire_by_duty(duty_id)
    duty_itemnaire = AssignmentQuestionnaire.where(assignment_id: assignment.id, duty_id: duty_id).first
    if duty_itemnaire.nil?
      itemnaire
    else
      Questionnaire.find(duty_itemnaire.itemnaire_id)
    end
  end

  def contributor
    nil
  end

  def get_title
    'Teammate Review'
  end

  def get_reviewer
    AssignmentParticipant.find(reviewer_id)
  end

  def self.teammate_response_report(id)
    TeammateReviewResponseMap.select('DISTINCT reviewer_id').where('reviewed_object_id = ?', id)
  end

  # Send Teammate Review Emails
  # Refactored from email method in response.rb
  def email(defn, _participant, assignment)
    defn[:body][:type] = 'Teammate Review'
    participant = AssignmentParticipant.find(reviewee_id)
    defn[:body][:obj_name] = assignment.name
    user = User.find(participant.user_id)
    defn[:body][:first_name] = user.fullname
    defn[:to] = user.email
    Mailer.sync_message(defn).deliver
  end
end
