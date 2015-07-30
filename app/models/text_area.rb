class TextArea < TextResponse
  def edit
  	html = "<form accept-charset="UTF-8" action="/questions/create" method="post">"
  	html += "Type: <input id="question_type" name="question[type]" type="text" value="Scale" size="3" disabled="true" />"
  	html += "Txt: <input id="question_txt" name="question[txt]" size="70" type="text" />"
  	html += "TextArea size: <input id="question_size" name="question[size]" size="5" type="text" />"
  	html += "Weight: <input id="question_weight" name="question[weight]" size="1" type="text" />"
  	html += "<input name="commit" type="submit" value="Create/Edit" />"
  	html += "</form>"
  end

  def view_question_text
  	html = "Type: <input id="question_type" name="question[type]" type="text" value="Scale" size="3" disabled="true" />"
  	html += "Txt: <input id="question_txt" name="question[txt]" size="70" type="text" disabled="true" />"
  	html += "TextArea size: <input id="question_size" name="question[size]" size="5" type="text" disabled="true" />"
  	html += "Weight: <input id="question_weight" name="question[weight]" size="1" type="text" disabled="true" />"
  end

  def complete
  	html = self.txt
  	cols = self.size.split(',')[0]
  	rows = self.size.split(',')[1]
  	html += "<textarea id="answer_comments" name="answer[comments]" cols=" +cols+ " rows=" +rows+ "></textarea>"
  end

  def view_completed_question(response_id)
  	answer = Answer.where(question_id: self.id, response_id: response_id).first
  	html = self.txt
  	cols = self.size.split(',')[0]
  	rows = self.size.split(',')[1]
  	html += "<textarea id="answer_comments" name="answer[comments]" cols=" +cols+ " rows=" +rows+ ">" +answer.comments+ "</textarea>"
  end 
end
