class Response < ActiveRecord::Base
  belongs_to :map, :class_name => 'ResponseMap', :foreign_key => 'map_id'
  has_many :scores, :class_name => 'Score', :foreign_key => 'response_id'
  
  def display_as_html(prefix = nil, count = nil)
    if prefix
      identifier = "<B>Reviewer:</B> "+self.map.reviewer.fullname
      str = prefix+"_"+self.id.to_s
    else
      identifier = '<B>'+self.map.get_title+'</B> '+count.to_s+'</B>'
      str = self.id.to_s
    end    
    code = identifier+'&nbsp;&nbsp;&nbsp;<a href="#" name= "review_'+str+'Link" onClick="toggleElement('+"'review_"+str+"','review'"+');return false;">hide review</a><BR/>'                
    code += "<B>Last reviewed:</B> "
    if self.updated_at.nil?
      code += "Not available"
    else
      code += self.updated_at.strftime('%A %B %d %Y, %I:%M%p')
    end
    code += '<div id="review_'+str+'" style=""><BR/><BR/>'
    
    count = 0
    self.scores.each{
      | reviewScore |
      count += 1
      code += '<big><b>Question '+count.to_s+":</b> <I>"+Question.find_by_id(reviewScore.question_id).txt+"</I></big><BR/><BR/>"
      code += '<TABLE CELLPADDING="5"><TR><TD valign="top"><B>Score:</B></TD><TD><FONT style="BACKGROUND-COLOR:gold">'+reviewScore.score.to_s+"</FONT> out of <B>"+Question.find_by_id(reviewScore.question_id).questionnaire.max_question_score.to_s+"</B></TD></TR>"
      if reviewScore.comments != nil
        code += '<TR><TD valign="top"><B>Response:</B></TD><TD>' + reviewScore.comments.gsub("<","&lt;").gsub(">","&gt;").gsub(/\n/,'<BR/>')
      end
      code += '</TD></TR></TABLE><BR/>'
    }           
    
    if self.additional_comment != nil
      comment = self.additional_comment.gsub('^p','').gsub(/\n/,'<BR/>&nbsp;&nbsp;&nbsp;')
    else
      comment = ''
    end
    code += "<B>Additional Comment:</B><BR/>"+comment+"</div>"
    return code
  end  
  
  # Computes the total score awarded for a review
  def get_total_score
    total_score = 0
    
    self.map.questionnaire.questions.each{
      | question |
      item = Score.find_by_response_id_and_question_id(self.id, question.id)
      total_score += item.score      
    }    
    return total_score        
  end  
  
 #Generate an email to the instructor when a new review exceeds the allowed difference
 #ajbudlon, nov 18, 2008
 def notify_on_difference(new_pct,avg_pct,limit)
   mapping = self.map
   instructor = mapping.assignment.instructor 
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
 
  def delete
    self.scores.each {|score| score.destroy}
    self.destroy
  end  
  
  	# getTotalScore()
	# Returns the total score from this response
	# Created by: Jason Vorenkamp
	# Created on: November 1, 2010
	# Project: CSC 517 - OSS Project - 320 Assemssment

	def getTotalScore()

		# TODO The method get_total_score() above does not seem correct.  Replace with this method.

		totalScore = 0

		self.scores.each  {|score| totalScore = totalScore + score.score }

		totalScore;

	end

	# getMaximumScore()
	# Returns the maximum possible score for this response
	# Created by: Jason Vorenkamp
	# Created on: November 1, 2010
	# Project: CSC 517 - OSS Project - 320 Assemssment

	def getMaximumScore()

		maxScore = 0

		self.scores.each  {|score| maxScore = maxScore + score.question.questionnaire.max_question_score }

		maxScore;

	end

	# getAverageScore()
	# Returns the average score for this response as an integer (0-100)
	# Created by: Jason Vorenkamp
	# Created on: November 1, 2010
	# Project: CSC 517 - OSS Project - 320 Assessment

	def getAverageScore()

		if getMaximumScore != 0 then

			((getTotalScore.to_f / getMaximumScore.to_f) * 100).to_i

		else

			0

		end

	end
  
end
