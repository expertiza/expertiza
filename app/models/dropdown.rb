class DropDown < UnscoredQuestion
  def edit
  	html = "<form accept-charset="UTF-8" action="/questions/create" method="post">"
  	html += "Type: <input id="question_type" name="question[type]" type="text" value="DropDown" size="3" disabled="true" />"
  	html += "Txt: <input id="question_txt" name="question[txt]" size="70" type="text" />"
  	html += "Alternatives: <input id="question_alternatives" name="question[alternatives]" size="5" type="text" />"
  	html += "<input name="commit" type="submit" value="Create/Edit" />"
  	html += "</form>"
  end

  def view_question_text
  	html = "Type: <input id="question_type" name="question[type]" type="text" value="DropDown" size="3" disabled="true" />"
  	html += "Txt: <input id="question_txt" name="question[txt]" size="70" type="text" value=" +self.txt+ " disabled="true" />"
  	html += "Alternatives: <input id="question_alternatives" name="question[alternatives]" size="5" type="text" value=" +self.alternatives+ " disabled="true" />"
  end

  def complete
  	html = self.txt
  	alternatives = self.alternatives.splict('|')
  	html += "<select id="answer_answer" name="answer[answer]">"
  	alternatives.each_with_index do |alternative, index|
  		html += "<option value=" +index.to_s+ ">" +index.to_s+ "-" +alternative+ "</option>"
  	end
  	html += "</select>"
  end

  def view_completed_question(response_id)
  	answer = Answer.where(question_id: self.id, response_id: response_id).first
  	html = self.txt
  	alternatives = self.alternatives.splict('|')
  	html += "<select id="answer_answer" name="answer[answer]">"
  	alternatives.each_with_index do |alternative, index|
  		html += "<option value=" +index.to_s
  		html += "selected="selected"" if answer.answer == index
  		html += ">" +index.to_s+ "-" +alternative+ "</option>"
  	end
  	html += "</select>"
  end
end
