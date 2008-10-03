class TeammateReview < ActiveRecord::Base
  has_many :teammate_review_scores
  belongs_to :reviewer, :class_name => "User", :foreign_key => "reviewer_id"
  belongs_to :reviewee, :class_name => "User", :foreign_key => "reviewee_id"
  
  # Computes the total score awarded for a  teammate review
  def get_total_score
    scores = TeammateReviewScore.find_all_by_teammate_review_id(self.id)
    total_score = 0
    scores.each{
      |item|
      total_score += item.score
    }   
    return total_score
  end
  
  def display_as_html  
    code = "<B>Reviewer:</B> "+self.reviewer.fullname+'&nbsp;&nbsp;&nbsp;<a href="#" name= "review'+self.id.to_s+'Link" onClick="toggleElement('+"'review"+self.id.to_s+"','review'"+');return false;">hide teammate review</a>'
    code = code + '<div id="review'+self.id.to_s+'" style="">'   
    code = code + '<BR/><BR/>'
    TeammateReviewScore.find_all_by_teammate_review_id(self.id).each{
      | TeammateReviewScore |      
      code = code + "<I>"+TeammateReviewScore.question.txt+"</I><BR/><BR/>"
      code = code + '(<FONT style="BACKGROUND-COLOR:gold">'+TeammateReviewScore.score.to_s+"</FONT> out of <B>"+TeammateReviewScore.question.questionnaire.max_question_score.to_s+"</B>): "+TeammateReviewScore.comments+"<BR/><BR/>"
    }          
    comment = self.additional_comment.gsub('^p','').gsub(/\n/,'<BR/>&nbsp;&nbsp;&nbsp;')    
    code = code + "<B>Additional Comment:</B><BR/>"+comment+""
    code = code + "</div>"
    return code
  end
end
