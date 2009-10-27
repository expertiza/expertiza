class ReviewFeedback < ActiveRecord::Base
    has_many :review_scores
    belongs_to :mapping, :class_name => 'FeedbackMapping', :foreign_key => 'mapping_id'
    
  def display_as_html(prefix = nil,count = nil) 
    if prefix
      code = "<B>Author:</B> "+self.review.review_mapping.reviewee.name+'&nbsp;&nbsp;&nbsp;<a href="#" name= "feedback_'+prefix+"_"+self.id.to_s+'Link" onClick="toggleElement('+"'feedback_"+prefix+"_"+self.id.to_s+"','feedback'"+');return false;">hide feedback</a>'
    else
      code = '<B>Feedback '+count.to_s+'</B>&nbsp;&nbsp;&nbsp;<a href="#" name= "feedback_'+self.id.to_s+'Link" onClick="toggleElement('+"'feedback_"+self.id.to_s+"','feedback'"+');return false;">show feedback</a>'          
    end      
    code = code + "<BR/><B>Last updated:</B> "
    if self.updated_at.nil?
      code = code + "Not available"
    else
      code = code + self.updated_at.strftime('%A %B %d %Y, %I:%M%p')
    end
    if prefix
      code = code + '<div id="feedback_'+prefix+"_"+self.id.to_s+'" style="">'
    else
      code = code + '<div id="feedback_'+self.id.to_s+'" style="">'
    end
    code = code + '<BR/><BR/>'
    questionnaire = Questionnaire.find(self.mapping.assignment.author_feedback_questionnaire.id)
    questions = questionnaire.questions
    scores = Array.new
    questions.each{
       | question |
       score = Score.find_by_question_id_and_instance_id(question.id, self.id)
       if score
         scores << score
       end
    }
    
    scores.each{
      | reviewScore |      
      code = code + "<I>"+Question.find_by_id(reviewScore.question_id).txt+"</I><BR/><BR/>"
      code = code + '(<FONT style="BACKGROUND-COLOR:gold">'+reviewScore.score.to_s+"</FONT> out of <B>"+Question.find_by_id(reviewScore.question_id).questionnaire.max_question_score.to_s+"</B>): "+reviewScore.comments+"<BR/><BR/>"
    }          
    if self.additional_comment != nil
      comment = self.additional_comment.gsub('^p','').gsub(/\n/,'<BR/>&nbsp;&nbsp;&nbsp;')
    elsif self.txt != nil
      comment = self.txt.gsub('^p','').gsub(/\n/,'<BR/>&nbsp;&nbsp;&nbsp;')
    else
      comment = ""
    end
    code = code + "<B>Additional Comment:</B><BR/>"+comment+""
    code = code + "</div>"
    return code
  end  
  
  def delete
    type_id = QuestionnaireType.find_by_name("Author Feedback").id
    scores = Score.find_all_by_instance_id_and_questionnaire_type_id(self.id,type_id)
    scores.each {|score| score.destroy}    
    self.destroy
  end
    
    def reviewer
      self.review.review_mapping.reviewee      
    end
  
    def reviewee
      self.review.review_mapping.reviewer
    end
  
 # Computes the total score awarded for a feedback
  def get_total_score
    questions_query = "select id from questions where questionnaire_id = "+self.assignment.author_feedback_questionnaire_id.to_s
    
    scores = Score.find_by_sql("select * from scores where instance_id = "+self.id.to_s+" and question_id in ("+questions_query+") and questionnaire_type_id= "+ QuestionnaireType.find_by_name("Author Feedback").id.to_s)
    total_score = 0
    scores.each{
      |item|
      total_score += item.score
    }   
    return total_score
  end
  
 #Generate an email to the instructor when a new review exceeds the allowed difference
 #ajbudlon, nov 18, 2008
 def notify_on_difference(new_pct,avg_pct,limit)   
   instructor = User.find(self.assignment.instructor_id)  
   puts "*** in sending method ***"
   Mailer.deliver_message(
     {:recipients => instructor.email,
      :subject => "Expertiza Notification: A review feedback score is outside the acceptable range",
      :body => {
        :first_name => ApplicationHelper::get_user_first_name(instructor),
        :reviewer_name => User.find(self.author_id).fullname,
        :type => "feedback",
        :reviewee_name => self.review.review_mapping.reviewer.fullname,
        :limit => limit,
        :new_pct => new_pct,
        :avg_pct => avg_pct,
        :types => "review feedback",
        :performer => "author",
        :assignment => self.assignment,              
        :partial_name => 'limit_notify'
      }
     }
   )
          
 end  
end
