class TextField < TextResponse
  def edit
  	html = "<form accept-charset="UTF-8" action="/questions/create" method="post">"
  	html += "Type: <input id="question_type" name="question[type]" type="text" value="TextField" size="3" disabled="true" />"
  	html += "Txt: <input id="question_txt" name="question[txt]" size="70" type="text" />"
  	html += "TextField size: <input id="question_size" name="question[size]" size="5" type="text" />"
  	html += "Break_before: <input id="question_break_before" name="question[break_before]" size="1" type="text" />"
  	html += "<input name="commit" type="submit" value="Create/Edit" />"
  	html += "</form>"
  end

  def view_question_text
  	html = "Type: <input id="question_type" name="question[type]" type="text" value="TextField" size="3" disabled="true" />"
  	html += "Txt: <input id="question_txt" name="question[txt]" size="70" type="text" value=" +self.txt+ " disabled="true" />"
  	html += "TextField size: <input id="question_size" name="question[size]" size="5" type="text" value=" +self.size+ " disabled="true" />"
  	html += "Break_before: <input id="question_break_before" name="question[break_before]" size="1" value=" +self.break_before+ " type="text" />"
  end

  def complete
  	html = self.txt
  	html += "<input id="answer_comments" name="answer[comments]" size=" +self.size+ " type="text"/>"
	#find next question record
	next_question = Question.where("id > ?", self.id).first
	while next_question.break_before == false
	  	html += "-<input id="answer_comments" name="answer[comments]" size=" +next_question.size+ " type="text"/>"
	  	next_question = Question.where("id > ?", next_question.id).first
	end
  end

  def view_completed_question(response_id)
  	answer = Answer.where(question_id: self.id, response_id: response_id).first
  	html = self.txt
  	html += "<input id="answer_comments" name="answer[comments]" size=" +self.size+ " type="text" value=" +answer.comments+ "/>"
  	#find next question record
	next_question = Question.where("id > ?", self.id).first
	while next_question.break_before == false
  		next_answer = Answer.where(question_id: next_question.id, response_id: response_id).first
	  	html += "-<input id="answer_comments" name="answer[comments]" size=" +next_question.size+ " type="text" value=" +next_answer.comments+ "/>"
	  	next_question = Question.where("id > ?", next_question.id).first
	end
  end
end
