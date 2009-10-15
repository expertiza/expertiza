class TeammateReview < ActiveRecord::Base
  has_many :teammate_review_scores
  belongs_to :mapping, :class_name => "TeammateReviewMapping", :foreign_key => "mapping_id"
  
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
  
  def display_as_html(prefix = nil, count = nil)
    if prefix
       code = "<B>Reviewer:</B> "+self.reviewer.fullname+'&nbsp;&nbsp;&nbsp;<a href="#" name= "teammate_review_'+prefix+"_"+self.id.to_s+'Link" onClick="toggleElement('+"'teammate_review_"+prefix+"_"+self.id.to_s+"','teammate_review'"+');return false;">hide review</a><BR/>'
    else
       code = '<B>Teammate Review '+count.to_s+'</B> &nbsp;&nbsp;&nbsp;<a href="#" name= "teammate_review_'+self.id.to_s+'Link" onClick="toggleElement('+"'teammate_review_"+self.id.to_s+"','teammate_review'"+');return false;">hide review</a><BR/>'           
    end
    # teammate reviews do not currently support updated_at
    #code = code + "<B>Last reviewed:</B> "
    #if self.updated_at.nil?
    #  code = code + "Not available"
    #else
    #  code = code + self.updated_at.strftime('%A %B %d %Y, %I:%M%p')
    #end
    if prefix
      code = code + '<div id="teammate_review_'+prefix+"_"+self.id.to_s+'" style="">'
    else
      code = code + '<div id="teammate_review_'+self.id.to_s+'" style="">'
    end
    code = code + '<BR/><BR/>'
    scores = Score.find_by_sql("select * from scores where instance_id = "+self.id.to_s+" and questionnaire_type_id= "+ QuestionnaireType.find_by_name("Teammate Review").id.to_s)
    count = 0
    scores.each{
      | reviewScore |
      count = count + 1
      code = code + "<B>Question "+count.to_s+": </B><I>"+Question.find_by_id(reviewScore.question_id).txt+"</I><BR/><BR/>"
      code = code + '&nbsp;&nbsp;&nbsp;(<FONT style="BACKGROUND-COLOR:gold">'+reviewScore.score.to_s+"</FONT> out of <B>"+Question.find_by_id(reviewScore.question_id).questionnaire.max_question_score.to_s+"</B>): "+reviewScore.comments.gsub("<","&lt;").gsub(">","&gt;")+"<BR/><BR/>"
    }     
    if self.additional_comment != nil
      comment = self.additional_comment.gsub('^p','').gsub(/\n/,'<BR/>&nbsp;&nbsp;&nbsp;')
    else
      comment = ''
    end
    code = code + "<B>Additional Comment:</B><BR/>"+comment+""
    code = code + "</div>"
    return code
  end   
  
  #return the reviewer for this review
  def reviewer
    self.mapping.reviewer.user
  end
  
  #return the reviewee for this review
  def reviewee
    self.mapping.reviewee.user
  end
  
 #Generate an email to the instructor when a new review exceeds the allowed difference
 #ajbudlon, nov 18, 2008
 def notify_on_difference(new_pct,avg_pct,limit)
   mapping = TeammateReviewMapping.find(self.mapping_id)
   instructor = User.find(mapping.assignment.instructor_id)  
   puts "*** in sending method ***"
   Mailer.deliver_message(
     {:recipients => instructor.email,
      :subject => "Expertiza Notification: A review score is outside the acceptable range",
      :body => {        
        :first_name => ApplicationHelper::get_user_first_name(instructor),
        :reviewer_name => mapping.reviewer.fullname,
        :type => "review",
        :reviewee_name => mapping.reviewee.fullname,
        :limit => limit,
        :new_pct => new_pct,
        :avg_pct => avg_pct,
        :types => "reviews",
        :performer => "reviewer",
        :assignment => mapping.assignment,    
        :partial_name => 'limit_notify'
      }
     }
   )
          
 end  
  
  
end
