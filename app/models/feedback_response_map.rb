class FeedbackResponseMap < ResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :review, :class_name => 'Response', :foreign_key => 'reviewed_object_id'
  belongs_to :reviewer, :class_name => 'AssignmentParticipant', dependent: :destroy

  def assignment
    self.review.map.assignment
  end

  def show_review()
    if self.review
      return self.review.display_as_html()
    else
      return "No review was performed"
    end
  end

  def get_title
    return "Feedback"
  end

  def questionnaire
    self.assignment.questionnaires.find_by_type('AuthorFeedbackQuestionnaire')
  end

  def contributor
    self.review.map.reviewee
  end
  def email3(map_id, partial="new_submission")
    defn = Hash.new
    defn[:body] = Hash.new
    defn[:body][:partial_name] = partial
    response_map = ResponseMap.find map_id
    assignment=nil

    reviewer_participant_id =  response_map.reviewer_id
    participant = Participant.find(reviewer_participant_id)
    assignment = Assignment.find(participant.parent_id)

    defn[:subject] = "A new submission is available for "+assignment.name
    defn[:body][:type] = "Review Feedback"
    # reviewee is a response, reviewer is a participant
    # we need to track back to find the original reviewer on whose work the author comments
    response_id_for_original_feedback = response_map.reviewed_object_id
    response_for_original_feedback = Response.find response_id_for_original_feedback
    response_map_for_original_feedback = ResponseMap.find response_for_original_feedback.map_id
    original_reviewer_participant_id = response_map_for_original_feedback.reviewer_id

    participant = AssignmentParticipant.find(original_reviewer_participant_id)
    topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
    if topic_id.nil?
      defn[:body][:obj_name] = assignment.name
    else
      defn[:body][:obj_name] = SignUpTopic.find(topic_id).topic_name
    end

    user = User.find(participant.user_id)

    defn[:to] = user.email
    defn[:body][:first_name] = user.fullname
    Mailer.sync_message(defn).deliver
  end
end
