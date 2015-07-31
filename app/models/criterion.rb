class Criterion < ScoredQuestion
  validates_presence_of :size
  
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

  def view_question_text
  	# html = "Type: <input id="question_type" name="question[type]" type="text" value="Criterion" size="3" disabled="true" />"
  	# html += "Txt: <input id="question_txt" name="question[txt]" size="70" type="text" value=" +self.txt+ " disabled="true" />"
  	# html += "Min_label: <input id="question_min_label" name="question[min_label]" size="5" type="text" value=" +self.min_label+ " disabled="true" />"
  	# html += "Max_label: <input id="question_max_label" name="question[max_label]" size="5" type="text" value=" +self.max_label+ " disabled="true" />"
  	# html += "TextArea size: <input id="question_size" name="question[size]" size="5" type="text" value=" +self.size+ " disabled="true"/>"
  	# html += "Weight: <input id="question_weight" name="question[weight]" size="1" type="text" value=" +self.weight+ " disabled="true" />"
  end

  def complete
  	# html = self.txt
  	# html += "<select id="answer_answer" name="answer[answer]">"
  	# html += "<option value="1">1-" +self.min_label+ "</option>"
  	# html += "<option value="2">2</option>"
  	# html += "<option value="3">3</option>"
  	# html += "<option value="4">4</option>"
  	# html += "<option value="5">5-" +self.max_label+ "</option></select><br/>"
  	# html += "Comment:<br/>"
  	# cols = self.size.split(',')[0]
  	# rows = self.size.split(',')[1]
  	# html += "<textarea id="answer_comments" name="answer[comments]" cols=" +cols+ " rows=" +rows+ "></textarea>"
  end

  def view_completed_question(count, answer,questionnaire_max)
		html = '<big><b>Question '+count.to_s+":</b> <I>"+self.txt+"</I></big><BR/><BR/>"
		html += '<TABLE CELLPADDING="5"><TR><TD valign="top"><B>Score:</B></TD><TD><FONT style="BACKGROUND-COLOR:gold">'+answer.answer.to_s+"</FONT> out of <B>"+questionnaire_max.to_s+"</B></TD></TR>"
		if answer.comments != nil
			html += '<TR><TD valign="top"><B>Response:</B></TD><TD>' + answer.comments.gsub("<", "&lt;").gsub(">", "&gt;").gsub(/\n/, '<BR/>')
		end
		html += '</TD></TR></TABLE><BR/>'
		html
  end

  
end
