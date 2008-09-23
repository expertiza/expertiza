class ReviewOfReview < ActiveRecord::Base
    has_many :review_of_review_scores
    belongs_to :review_of_review_mapping

  def display_as_html(prefix)         
    code = "<B>Metareviewer:</B> "+self.review_of_review_mapping.review_reviewer.fullname+'&nbsp;&nbsp;&nbsp;<a href="#" name= "metareview_'+prefix+"_"+self.id.to_s+'Link" onClick="toggleElement('+"'metareview_"+prefix+"_"+self.id.to_s+"','metareview'"+');return false;">hide metareview</a>'
    code = code + '<div id="metareview_'+prefix+"_"+self.id.to_s+'" style="">'
    code = code +"<BR/><BR/>"    
    ReviewOfReviewScore.find_all_by_review_of_review_id(self.id).each{
      | reviewScore |      
      code = code + "<I>"+reviewScore.question.txt+"</I><BR/><BR/>"
      code = code + '(<FONT style="BACKGROUND-COLOR:gold">'+reviewScore.score.to_s+"</FONT> out of <B>"+reviewScore.question.questionnaire.max_question_score.to_s+"</B>): "+reviewScore.comments+"<BR/><BR/>"
    }  
    code = code + "</div>"
    return code
  end

  # Computes the total score awarded for a metareview
  def get_total_score
    scores = ReviewOfReviewScore.find_all_by_review_of_review_id(self.id)
    total_score = 0
    scores.each{
      |item|
      total_score += item.score
    }   
    return total_score
  end

  def delete
    rOfRScores = ReviewOfReviewScore.find(:all, :conditions => ['review_of_review_id =?',self.id])
    rOfRScores.each {|review| rOfRScores.delete }
    self.destroy
  end

  # Generate emails for reviewers when a new review of their work is made
  #ajbudlon, sept 07, 2007        
  def email
   review_of_review_mapping = ReviewOfReviewMapping.find_by_id(self.review_of_review_mapping_id)
   review_mapping = ReviewMapping.find_by_id(review_of_review_mapping.review_mapping_id)
      
   if User.find_by_id(review_mapping.reviewer_id).email_on_review_of_review
     review_num = get_review_number(review_of_review_mapping)     
     review_id = review_of_review_mapping.review_id
     review = Review.find(review_id)
     
     user = User.find(review_mapping.reviewer_id)
     recipient = User.find_by_id(review_mapping.reviewer_id).email
     Mailer.deliver_message(
         {:recipients => recipient,
          :subject => "An new review of review is available for #{self.name}",
          :body => {
           :obj_name => Assignment.find_by_id(review_mapping.assignment_id).name,
           :type => "review of review",
           :location => "Review "+get_review_number(review_of_review_mapping).to_s,
           :review_scores => review.review_scores,
           :ror_review_scores => self.review_of_review_scores,
           :user_name => ApplicationHelper::get_user_first_name(user),
           :partial_name => "update"
          }
         }
        )         
   end  
  end
  
  # Get all review mappings for this assignment & reviewer
  # required to give reviewer location of new submission content
  # link can not be provided as it might give user ability to access data not
  # available to them.  
  #ajbudlon, sept 07, 2007       
  def get_review_number(mapping)
    reviewer_mappings = ReviewMapping.find_by_sql(
      "select * from review_of_review_mappings where assignment_id = " +self.id.to_s +
      " and review_id = " + mapping.review_id.to_s
    )
    review_num = 1
    for rm in reviewer_mappings
      if rm.reviewer_id != mapping.reviewer_id
        review_num += 1
      else
        break
      end
    end  
    return review_num
  end    
end
