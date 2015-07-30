class Criterion < ScoredQuestion
  def edit
  	html = "<form accept-charset="UTF-8" action="/questions/create" method="post">"
  	html += "Type: <input id="question_type" name="question[type]" type="text" value="Scale" size="3" disabled="true" />"
  	html += "Txt: <input id="question_txt" name="question[txt]" size="70" type="text" />"
  	html += "Min_label: <input id="question_min_label" name="question[min_label]" size="5" type="text" />"
  	html += "Max_label: <input id="question_max_label" name="question[max_label]" size="5" type="text" />"
  	html += "TextArea size: <input id="question_size" name="question[size]" size="5" type="text" />"
  	html += "Weight: <input id="question_weight" name="question[weight]" size="1" type="text" />"
  	html += "<input name="commit" type="submit" value="Create/Edit" />"
  	html += "</form>"
  end

  def view_question_text
  	html = "Type: <input id="question_type" name="question[type]" type="text" value="Scale" size="3" disabled="true" />"
  	html += "Txt: <input id="question_txt" name="question[txt]" size="70" type="text" disabled="true" />"
  	html += "Min_label: <input id="question_min_label" name="question[min_label]" size="5" type="text" disabled="true" />"
  	html += "Max_label: <input id="question_max_label" name="question[max_label]" size="5" type="text" disabled="true" />"
  	html += "TextArea size: <input id="question_size" name="question[size]" size="5" type="text" disabled="true"/>"
  	html += "Weight: <input id="question_weight" name="question[weight]" size="1" type="text" disabled="true" />"
  end

  def complete
  	html = self.txt
  	html += "<select id="answer_answer" name="answer[answer]">"
  	html += "<option value="1">1-" +self.min_label+ "</option>"
  	html += "<option value="2">2</option>"
  	html += "<option value="3">3</option>"
  	html += "<option value="4">4</option>"
  	html += "<option value="5">5-" +self.max_label+ "</option></select><br/>"
  	html += "Comment:<br/>"
  	cols = self.size.split(',')[0]
  	rows = self.size.split(',')[1]
  	html += "<textarea id="answer_comments" name="answer[comments]" cols=" +cols+ " rows=" +rows+ "></textarea>"
  end

  def view_completed_question(response_id)
  	answer = Answer.where(question_id: self.id, response_id: response_id).first
  	html = self.txt
  	html += "<select id="answer_answer" name="answer[answer]">"
  	html += "<option value="1""
  	html += "selected="selected"" if answer.answer == 1
  	html += ">1-" +self.min_label+ "</option><option value="2""
  	html += "selected="selected"" if answer.answer == 2
  	html += ">2</option><option value="3""
  	html += "selected="selected"" if answer.answer == 3
  	html += ">3</option><option value="4""
  	html += "selected="selected"" if answer.answer == 4
  	html += ">4</option><option value="5""
  	html += "selected="selected"" if answer.answer == 5
  	html += ">5-" +self.max_label+ "</option></select><br/>"
  	html += "Comment:<br/>"
  	cols = self.size.split(',')[0]
  	rows = self.size.split(',')[1]
  	html += "<textarea id="answer_comments" name="answer[comments]" cols=" +cols+ " rows=" +rows+ ">" +answer.comments+ "</textarea>"
  end

  
end
