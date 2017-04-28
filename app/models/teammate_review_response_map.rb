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
    # Example query
    # SELECT distinct reviewer_id FROM response_maps where type = 'TeammateReviewResponseMap' and reviewed_object_id = 711
    @reviewers = ResponseMap.select("DISTINCT reviewer_id").where(["reviewed_object_id = ? and type = ?", id, 'TeammateReviewResponseMap'])
  end

  #Send Teammate Review Emails
  #Refactored from email method in response.rb
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

  def self.assign_t_avg_to_part(participant)
    teammate_reviews = participant.teammate_reviews
    team_id = TeamsUser.team_id(participant.parent_id, participant.user_id)
    if team_id.nil?
      return false
    end
    team = Team.find(team_id)
    team_size = team.participants.size
    sum = 0;
    if team_size == 0 || team_size == 1
      return false
    end
    if teammate_reviews.size == team_size - 1
      teammate_reviews.each do |teammate_review|
        sum += teammate_review.get_average_score
      end
      participant.t_rev_avg = sum / (team_size - 1)
      participant.save
    end
    TeammateReviewResponseMap.calc_team_avg_t_rev(team)
  end

  def self.calc_team_avg_t_rev(team)
    if team.nil?
      return false
    end
    team_participants = team.participants
    sum = 0;
    team_participants.each do |team_member|
      if team_member.t_rev_avg != -1
        sum += team_member.t_rev_avg
      else
        return false
      end
    end
    team.t_rev_avg = sum / team_participants.size
    team.save
  end
end
