class TeammateReviewResponseMap < ResponseMap
  belongs_to :reviewee, class_name: 'Participant', foreign_key: 'reviewee_id'
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'reviewed_object_id'

  def questionnaire(duty = nil)
    self.assignment.questionnaires.each do |questionnaire|
      if questionnaire.type == 'TeammateReviewQuestionnaire'
        assignment_questionnaires = AssignmentQuestionnaire.where(assignment_id: self.assignment.id ,questionnaire_id: questionnaire.id)
        assignment_questionnaires.each do |assignment_questionnaire|
          if assignment_questionnaire.duty_name == duty
            @questionnaire = questionnaire
            break
          end
        end

      end
    end
    @questionnaire
  end

  def contributor
    nil
  end

  def get_title
    "Teammate Review"
  end

  def self.teammate_response_report(id)
    # Example query
    # SELECT distinct reviewer_id FROM response_maps where type = 'TeammateReviewResponseMap' and reviewed_object_id = 711
    @reviewers = ResponseMap.select("DISTINCT reviewer_id").where(["reviewed_object_id = ? and type = ?", id, 'TeammateReviewResponseMap'])
  end

  #Send Teammate Review Emails
  #Refactored from email method in response.rb
  def email(defn,assignment,participant)
    defn[:body][:type] = "Teammate Review"
    participant = AssignmentParticipant.find(reviewee_id)
    topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
    defn[:body][:obj_name] = SignUpTopic.find(topic_id).topic_name rescue nil
    user = User.find(participant.user_id)
    defn[:body][:first_name] = user.fullname
    defn[:to] = user.email
    Mailer.sync_message(defn).deliver
  end
end
