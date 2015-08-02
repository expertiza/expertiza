class Criterion < ScoredQuestion
  validates_presence_of :size

  #This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit
  	# html = "<form accept-charset="UTF-8" action="/questions/create" method="post">"
  	# html += "Type: <input id="question_type" name="question[type]" type="text" value="Criterion" size="3" disabled="true" />"
  	# html += "Txt: <input id="question_txt" name="question[txt]" size="70" type="text" />"
  	# html += "Min_label: <input id="question_min_label" name="question[min_label]" size="5" type="text" />"
  	# html += "Max_label: <input id="question_max_label" name="question[max_label]" size="5" type="text" />"
  	# html += "TextArea size: <input id="question_size" name="question[size]" size="5" type="text" />"
  	# html += "Weight: <input id="question_weight" name="question[weight]" size="1" type="text" />"
  	# html += "<input name="commit" type="submit" value="Create/Edit" />"
  	# html += "</form>"
  end

  #This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    html = '<TR><TD align="left"> '+self.txt+' </TD>'
    html += '<TD align="left">'+self.type+'</TD>'
    html += '<td align="center">'+self.weight.to_s+'</TD>'
    questionnaire = self.questionnaire
    html += '<TD align="center">'+questionnaire.min_question_score.to_s+' to '+ questionnaire.max_question_score.to_s + '</TD>'
    html += '</TR>'
    html.html_safe
  end

  def complete(count, answer=nil, questionnaire_min, questionnaire_max)
  	if self.size.nil?
      cols = '70'
      rows = '1'
    elsif 
      cols = self.size.split(',')[0]
      rows = self.size.split(',')[1]
    end
    html = self.txt + '<br>'
    html += '<textarea cols=' +cols+ ' rows=' +rows+ ' id="responses_' +count.to_s+ '_comments" name="responses[' +count.to_s+ '][comment]" style="overflow:hidden;">'
    html += answer.comments if !answer.comments.nil?
    html += '</textarea>'
    html += '<select id="responses_' +count.to_s+ '_score" name="responses[' +count.to_s+ '][score]">'
    for j in questionnaire_min..questionnaire_max
      if !answer.nil? and j == answer.answer
        html += '<option value=' + j.to_s + ' selected="selected">' 
      else
        html += '<option value=' + j.to_s + '>'
      end
      if j == questionnaire_min
        html += j.to_s
        html += "-" + self.min_label if !self.min_label.nil?
        html += "</option>"
      elsif j == questionnaire_max
        html += j.to_s
        html += "-" + self.max_label if !self.max_label.nil?
        html += "</option>"
      else
        html += j.to_s + "</option>"
      end
    end
    html += "</select><br><br><br>"
    html.html_safe
  end

  #This method returns what to display if a student is viewing a filled-out questionnaire
  def view_completed_question(count, answer,questionnaire_max)
		html = '<big><b>Question '+count.to_s+":</b> <I>"+self.txt+"</I></big><BR/><BR/>"
		html += '<TABLE CELLPADDING="5"><TR><TD valign="top"><B>Score:</B></TD><TD><FONT style="BACKGROUND-COLOR:gold">'+answer.answer.to_s+"</FONT> out of <B>"+questionnaire_max.to_s+"</B></TD></TR>"
		if answer.comments != nil
			html += '<TR><TD valign="top"><B>Response:</B></TD><TD>' + answer.comments.gsub("<", "&lt;").gsub(">", "&gt;").gsub(/\n/, '<BR/>')
		end
		html += '</TD></TR></TABLE><BR/>'
		html.html_safe
  end

  
end
