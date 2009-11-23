class TeammateReview < ActiveRecord::Base
  has_many :teammate_review_scores
  belongs_to :mapping, :class_name => "TeammateReviewMapping", :foreign_key => "mapping_id"
  
  # Computes the total score awarded for a  teammate review
  def get_total_score
    questionnaire = Questionnaire.find(self.mapping.assignment.teammate_review_questionnaire_id)
    questions = questionnaire.questions
    
    total_score = 0
    
    questions.each{
      | question |
      item = Score.find_by_instance_id_and_question_id(self.id, question.id)
      total_score += item.score      
    }    
    return total_score        
  end 
  
  def display_as_html(prefix = nil, count = nil)
    if prefix
      identifier = "<B>Reviewer:</B> "+self.mapping.reviewer.fullname
      str = prefix+"_"+self.id.to_s
    else
      identifier = '<B>Teammate Review '+count.to_s+'</B>'
      str = self.id.to_s
    end    
    code = identifier+'&nbsp;&nbsp;&nbsp;<a href="#" name= "teammate_review_'+str+'Link" onClick="toggleElement('+"'teammate_review_"+str+"','teammate_review'"+');return false;">hide review</a><BR/>'           
    code += "<BR/><B>Last updated:</B> "
    if self.updated_at.nil?
      code += "Not available"
    else
      code += self.updated_at.strftime('%A %B %d %Y, %I:%M%p')
    end     
        
    code += '<div id="teammate_review_'+str+'" style=""><BR/><BR/>'
    questionnaire = Questionnaire.find(self.mapping.assignment.teammate_review_questionnaire_id)
    questions = questionnaire.questions
    scores = Array.new
    questions.each{
       | question |
       score = Score.find_by_question_id_and_instance_id(question.id, self.id)
       if score
         scores << score
       end
    }    

    count = 0
    scores.each{
      | reviewScore |
      count += 1
      code += "<B>Question "+count.to_s+": </B><I>"+Question.find_by_id(reviewScore.question_id).txt+"</I><BR/><BR/>"
      code += '&nbsp;&nbsp;&nbsp;(<FONT style="BACKGROUND-COLOR:gold">'+reviewScore.score.to_s+"</FONT> out of <B>"+Question.find_by_id(reviewScore.question_id).questionnaire.max_question_score.to_s+"</B>): "+reviewScore.comments.gsub("<","&lt;").gsub(">","&gt;")+"<BR/><BR/>"
    }     
    if self.additional_comment != nil
      comment = self.additional_comment.gsub('^p','').gsub(/\n/,'<BR/>&nbsp;&nbsp;&nbsp;')
    else
      comment = ''
    end
    code += "<B>Additional Comment:</B><BR/>"+comment+"</div>"
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
