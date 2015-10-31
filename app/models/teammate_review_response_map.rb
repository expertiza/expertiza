class TeammateReviewResponseMap < ResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'reviewed_object_id'

  def questionnaire
    self.assignment.questionnaires.find_by_type('TeammateReviewQuestionnaire')
  end

  def contributor
    nil
  end

  def get_title
    return "Teammate Review"
  end
  def email4(map_id, partial="new_submission")
    defn = Hash.new
    defn[:body] = Hash.new
    defn[:body][:partial_name] = partial
    response_map = ResponseMap.find map_id
    assignment=nil

    reviewer_participant_id =  response_map.reviewer_id
    participant = Participant.find(reviewer_participant_id)
    assignment = Assignment.find(participant.parent_id)

    defn[:subject] = "A new submission is available for "+assignment.name
    defn[:body][:type] = "Teammate Review"
    participant = AssignmentParticipant.find(response_map.reviewee_id)
    topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
    defn[:body][:obj_name] = SignUpTopic.find(topic_id).topic_name
    user = User.find(participant.user_id)
    defn[:body][:first_name] = user.fullname
    defn[:to] = user.email
    Mailer.sync_message(defn).deliver

  end
end
