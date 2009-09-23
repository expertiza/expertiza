class ReviewOfReview < ActiveRecord::Base
    has_many :review_of_review_scores
    belongs_to :review_of_review_mapping

  def display_as_html(prefix)
    if self.review_of_review_mapping.review_reviewer != nil
       review_reviewer = self.review_of_review_mapping.review_reviewer
    else
       review_reviewer = User.find(self.review_of_review_mapping.reviewer_id)
    end
    code = "<B>Metareviewer:</B> "+review_reviewer.fullname+'&nbsp;&nbsp;&nbsp;<a href="#" name= "metareview_'+prefix+"_"+self.id.to_s+'Link" onClick="toggleElement('+"'metareview_"+prefix+"_"+self.id.to_s+"','metareview'"+');return false;">hide metareview</a>'
    code = code + '<div id="metareview_'+prefix+"_"+self.id.to_s+'" style="">'
    code = code +"<BR/><BR/>"
    scores = Score.find_by_sql("select * from scores where instance_id = "+self.id.to_s+" and questionnaire_type_id= "+ QuestionnaireType.find_by_name("Metareview").id.to_s)
    scores.each{
      | reviewScore |      
      code = code + "<I>"+Question.find_by_id(reviewScore.question_id).txt+"</I><BR/><BR/>"
      code = code + '(<FONT style="BACKGROUND-COLOR:gold">'+reviewScore.score.to_s+"</FONT> out of <B>"+Question.find_by_id(reviewScore.question_id).questionnaire.max_question_score.to_s+"</B>): "+reviewScore.comments+"<BR/><BR/>"
    }  
    code = code + "</div>"
    return code
  end
  
  def reviewer
    if self.review_of_review_mapping.review_reviewer_id != nil
      User.find(self.review_of_review_mapping.review_reviewer_id)
    else
      User.find(self.review_of_review_mapping.reviewer_id)
    end
  end

  # Computes the total score awarded for a metareview
  def get_total_score
    scores = Score.find_by_sql("select * from scores where instance_id = "+self.id.to_s+" and questionnaire_type_id= "+ QuestionnaireType.find_by_name("Metareview").id.to_s)
    total_score = 0
    scores.each{
      |item|
      total_score += item.score
    }   
    return total_score
  end

  def self.get_metareivew_mapping
    ReviewOfReviewMapping.find_by_id(self.review_of_review_mapping_id)
  end

  def delete
    rOfRScores = Score.find_by_sql("select * from scores where instance_id = "+self.id.to_s+" and questionnaire_type_id= "+ QuestionnaireType.find_by_name("Metareview").id)
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
          :subject => "A new review of review is available for #{self.name}",
          :body => {
           :obj_name => Assignment.find_by_id(review_mapping.assignment_id).name,
           :type => "review of review",
           :location => "Review "+get_review_number(review_of_review_mapping).to_s,
           :review_scores => Score.find(:all, :conditions=>["instance_id=? and questionnaire_type_id=?",review.id, QuestionnaireType.find_by_name("Review").id]),
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
  
 #Generate an email to the instructor when a new review exceeds the allowed difference
 #ajbudlon, nov 18, 2008
 def notify_on_difference(new_pct,avg_pct,limit)
   mapping = ReviwOfReviewMapping.find(self.review_of_review_mapping_id)
   if mapping.review_reviewer_id.nil?
      reviewer = mapping.reviewer
   else
      reviewer = mapping.review_reviewer
   end   
   instructor = User.find(self.assignment.instructor_id)  
   puts "*** in sending method ***"
   Mailer.deliver_message(
     {:recipients => instructor.email,
      :subject => "Expertiza Notification: A metareview score is outside the acceptable range",
      :body => {
        :first_name => ApplicationHelper::get_user_first_name(instructor),
        :reviewer => reviewer,
        :type => "metareview",
        :reviewee => mapping.review_mapping.reviewer,
        :limit => limit,
        :new_pct => new_pct,
        :avg_pct => avg_pct,
        :types => "metareviews",
        :performer => "metareviewer",
        :assignment => mapping.review_mapping.assignment,              
        :partial_name => 'limit_notify'
      }
     }
   )
          
 end   
  
end
