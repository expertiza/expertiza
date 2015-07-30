class Scale < ScoredQuestion
  def edit
  	html = "<form accept-charset="UTF-8" action="/questions/create" method="post">"
  	html += "Type: <input id="question_type" name="question[type]" type="text" value="Scale" size="3" disabled="true" />"
  	html += "Txt: <input id="question_txt" name="question[txt]" size="70" type="text" />"
  	html += "Min_label: <input id="question_min_label" name="question[min_label]" size="5" type="text" />"
  	html += "Max_label: <input id="question_max_label" name="question[max_label]" size="5" type="text" />"
  	html += "Weight: <input id="question_weight" name="question[weight]" size="1" type="text" />"
  	html += "<input name="commit" type="submit" value="Create/Edit" />"
  	html += "</form>"
  end

  def view_question_text
  	html = "Type: <input id="question_type" name="question[type]" type="text" value="Scale" size="3" disabled="true" />"
  	html += "Txt: <input id="question_txt" name="question[txt]" size="70" type="text" disabled="true" />"
  	html += "Min_label: <input id="question_min_label" name="question[min_label]" size="5" type="text" disabled="true" />"
  	html += "Max_label: <input id="question_max_label" name="question[max_label]" size="5" type="text" disabled="true" />"
  	html += "Weight: <input id="question_weight" name="question[weight]" size="1" type="text" disabled="true" />"
  end

  def complete
  	html = "<table border="0" cellpadding="5" cellspacing="0">"
  	html += "<th>" +self.txt+ "</th>"
  	html += "<tr><td></td>"
  	html += "<td><label>1</label></td>"
  	html += "<td><label>2</label></td>"
  	html += "<td><label>3</label></td>"
  	html += "<td><label>4</label></td>"
  	html += "<td><label>5</label></td">
  	html += "<td></td></tr>"
  	html += "<tr><td>" +self.min_label+ "</td>"
  	html += "<td><input type="radio" id="1" value="1"></td>"
  	html += "<td><input type="radio" id="2" value="2"></td>"
  	html += "<td><input type="radio" id="3" value="3"></td>"
  	html += "<td><input type="radio" id="4" value="4"></td>"
  	html += "<td><input type="radio" id="5" value="5"></td></tr></tbody></table>"
  	html += "<td>" +self.max_label+ "</td></tr></table>"
  end

  def view_completed_question(response_id)
  	answer = Answer.where(question_id: self.id, response_id: response_id).first
  	html = "<table border="0" cellpadding="5" cellspacing="0">"
  	html += "<th>" +self.txt+ "</th>"
  	html += "<tr><td></td>"
  	html += "<td><label>1</label></td>"
  	html += "<td><label>2</label></td>"
  	html += "<td><label>3</label></td>"
  	html += "<td><label>4</label></td>"
  	html += "<td><label>5</label></td">
  	html += "<td></td></tr>"
  	html += "<tr><td>" +self.min_label+ "</td>"
  	html += "<td><input type="radio" id="1" value="1"" 
  	html += "checked="checked"" if answer.answer == 1
  	html += "></td><td><input type="radio" id="2" value="2"" "></td>"
  	html += "checked="checked"" if answer.answer == 2
  	html += "></td><td><input type="radio" id="3" value="3"" "></td>"
  	html += "checked="checked"" if answer.answer == 3
  	html += "></td><td><input type="radio" id="4" value="4"" "></td>"
  	html += "checked="checked"" if answer.answer == 4
  	html += "></td><td><input type="radio" id="5" value="5"" "></td></tr></tbody></table>"
  	html += "checked="checked"" if answer.answer == 5
  	html += "></td><td>" +self.max_label+ "</td></tr></table>"
  end
end
