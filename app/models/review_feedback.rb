class ReviewFeedback < ActiveRecord::Base
    has_many :review_scores
    belongs_to :mapping, :class_name => 'FeedbackMapping', :foreign_key => 'mapping_id'
    
  def display_as_html(prefix = nil,count = nil) 
    if prefix
      identifier = "<B>Author:</B> "+self.mapping.reviewer.fullname
      str = prefix+"_"+self.id.to_s
    else
      identifier = '<B>Feedback '+count.to_s+'</B>'
      str = self.id.to_s
    end    
    code = identifier+'&nbsp;&nbsp;&nbsp;<a href="#" name= "feedback_'+str+'Link" onClick="toggleElement('+"'feedback_"+str+"','feedback'"+');return false;">hide feedback</a>'
      
    code += "<BR/><B>Last updated:</B> "
    if self.updated_at.nil?
      code += "Not available"
    else
      code += self.updated_at.strftime('%A %B %d %Y, %I:%M%p')
    end
    
    code += '<div id="feedback_'+str+'" style=""><BR/><BR/>'    
    questionnaire = self.mapping.assignment.questionnaires.find_by_type('AuthorFeedbackQuestionnaire')
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
      code += "<I>"+Question.find_by_id(reviewScore.question_id).txt+"</I><BR/><BR/>"
      code += '(<FONT style="BACKGROUND-COLOR:gold">'+reviewScore.score.to_s+"</FONT> out of <B>"+Question.find_by_id(reviewScore.question_id).questionnaire.max_question_score.to_s+"</B>): "+reviewScore.comments+"<BR/><BR/>"
    }          
    if self.additional_comment != nil
      comment = self.additional_comment.gsub('^p','').gsub(/\n/,'<BR/>&nbsp;&nbsp;&nbsp;')
    elsif self.txt != nil
      comment = self.txt.gsub('^p','').gsub(/\n/,'<BR/>&nbsp;&nbsp;&nbsp;')
    else
      comment = ""
    end
    code += "<B>Additional Comment:</B><BR/>"+comment+"</div>"
    return code
  end  
  
  def self.get_assessments_for(participant)
    assessments = find(:all, :include => :mapping, :conditions => ['reviewee_id = ?',participant.id])
    return assessments.sort {|a,b| a.mapping.reviewer.fullname <=> b.mapping.reviewer.fullname }    
  end
  
  def delete
    type_id = QuestionnaireType.find_by_name("Author Feedback").id
    scores = Score.find_all_by_instance_id_and_questionnaire_type_id(self.id,type_id)
    scores.each {|score| score.destroy}    
    self.destroy
  end
  
 # Computes the total score awarded for a feedback
  def get_total_score
    questionnaire = self.mapping.assignment.questionnaires.find_by_type('AuthorFeedbackQuestionnaire')
    questions = questionnaire.questions
    
    total_score = 0
    
    questions.each{
      | question |
      item = Score.find_by_instance_id_and_question_id(self.id, question.id)
      total_score += item.score      
    }    
    return total_score
  end
  
 #Generate an email to the instructor when a new review exceeds the allowed difference
 #ajbudlon, nov 18, 2008
 def notify_on_difference(new_pct,avg_pct,limit)   
   instructor = User.find(self.mapping.assignment.instructor_id)  
   Mailer.deliver_message(
     {:recipients => instructor.email,
      :subject => "Expertiza Notification: A review feedback score is outside the acceptable range",
      :body => {
        :first_name => ApplicationHelper::get_user_first_name(instructor),
        :reviewer_name => self.mapping.reviewer.user.fullname,
        :type => "feedback",
        :reviewee_name => self.mapping.review.review_mapping.reviewer.fullname,
        :limit => limit,
        :new_pct => new_pct,
        :avg_pct => avg_pct,
        :types => "review feedback",
        :performer => "author",
        :assignment => self.mapping.assignment,              
        :partial_name => 'limit_notify'
      }
     }
   )
          
 end  
end
