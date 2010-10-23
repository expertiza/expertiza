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

def display_as_table(reviews,prefix)

  String code ='<table border=1 width=100% class="grades"> <tr><th>Questions</th>'
  count=0
  for review in reviews
    count=count+1
    if prefix
      identifier = "<B>Reviewer:</B> "+review.map.reviewer.fullname
    else
      identifier = '<B>'+review.map.get_title+'</B> '+count.to_s+'</B>'

    end
    code+= '<th>'+identifier+'</th>'
  end
   code+='</tr>'

  quescnt=reviews[0].get_score_count
  for i in 0..quescnt-1
     code+='<tr class ="head"><td>'+ (i+1).to_s+ ".  " +Question.find_by_id(reviews[0].scores[i].question_id).txt+ '</td>'
     for review in reviews
       if review.scores[i].comments != nil
        code +='<td>'+review.scores[i].comments.gsub("<","&lt;").gsub(">","&gt;").gsub(/\n/,'<BR/>')+'</td>'
       end
      end
      code+='</tr>'
  end

  code+='<tr  class ="head"><td><b>Additional Comments</b></td>'
  for review in reviews
    code+='<td>'
    if review.additional_comment != nil
      code += review.additional_comment.gsub('^p','').gsub(/\n/,'<BR/>&nbsp;&nbsp;&nbsp;')
    end
    code+='</td>' 
  end

  code+='</tr>'
  code += "<tr class ='head'><td><B>Last reviewed</B> "
  for review in reviews
    if review.updated_at.nil?
      code += "<td> Not available</td>"
    else
      code += "<td>"+review.updated_at.strftime('%A %B %d %Y, %I:%M%p') + "</td>"
    end
  end
  code+='</tr>'
end

 def prepare_score
       String code1=""
      self.scores.each do |reviewScore|
        code1+=reviewScore.score.to_s+','
      end
        return code1.chop + '|'
 end

 def get_score_count
         cnt=0
        self.scores.each do |reviewScore|
          cnt+=1
        end
          return cnt
 end


end
