class TeammateReview < ActiveRecord::Base
  has_many :teammate_review_scores
  belongs_to :reviewer, :class_name => "User", :foreign_key => "reviewer_id"
  belongs_to :reviewee, :class_name => "User", :foreign_key => "reviewee_id"
  
  # Computes the total score awarded for a  teammate review
  def get_total_score
    scores = Score.find_by_sql("select * from scores where instance_id = "+self.id.to_s+" and questionnaire_type_id= "+ QuestionnaireType.find_by_name("Teammate Review").id.to_s)
    total_score = 0
    scores.each{
      |item|
      total_score += item.score
    }   
    return total_score
  end 
end
