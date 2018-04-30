# E1600
# A new type called SelfReviewResponseMap was created for ResponseMap to handle self-reviews independent
class SelfReviewResponseMap < ResponseMap
  belongs_to :reviewee, class_name: 'Team', foreign_key: 'reviewee_id'
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'reviewed_object_id'

  # This method is used to get questionnaire for self-review to be performed by user
  def questionnaire(round)
    if self.assignment.varying_rubrics_by_round?
      Questionnaire.find(self.assignment.review_questionnaire_id(round))
    else
      Questionnaire.find(self.assignment.review_questionnaire_id)
    end
  end

  # This method helps to find contributor - here Team ID
  def contributor
    Team.find_by(id: self.reviewee_id)
  end

  # This method returns 'Title' of type of review (used to manipulate headings accordingly)
  def get_title
    "Self Review"
  end

  # do not send any reminder for self review received.
  def email(defn, participant, assignment); end

  # return  the responses for specified round, for varying rubric feature -Yang
  def self.get_responses_for_team_round(team, round)
    responses = []
    if team.id
      maps = ResponseMap.where(reviewee_id: team.id, type: "SelfReviewResponseMap")
      maps.each do |map|
        if !map.response.empty? && !map.response.reject {|r| (r.round != round || !r.is_submitted) }.empty?
          responses << map.response.reject {|r| (r.round != round || !r.is_submitted) }.last
        end
      end
      responses.sort! {|a, b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
    end
    responses
  end
end
