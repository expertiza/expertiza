class MultipleChoice < UnscoredQuestion
  def edit(count)
    html ='<tr>'
    html+='<td align="center"><input id="question_chk' +count.to_s+ '" type="checkbox"></td>'
    html+='<td><input size="6" value="'+self.seq.to_s+'" name="question['+self.id.to_s+'][seq]" id="question_'+self.id.to_s+'_seq" type="text"></td>'
    html+='<td><textarea cols="50" rows="1" name="question['+self.id.to_s+'][txt]" id="question_'+self.id.to_s+'_txt">'+self.txt+'</textarea></td>'
    html+='<td><input size="10" disabled="disabled" value="'+self.type+'" name="question['+self.id.to_s+'][type]" id="question_'+self.id.to_s+'_type" type="text">''</td>'
    html+='<td><!--placeholder (UnscoredQuestion does not need weight)--></td>'
    html+='<td> alternatives <input size="6" value="'+self.alternatives+'" name="question['+self.id.to_s+'][alternatives]" id="question_'+self.id.to_s+'_alternatives" type="text"></td>'
    html+='</tr>'

    html.html_safe
  end

  def view_question_text
    html = '<TR><TD align="left"> '+self.txt+' </TD>'
    html += '<TD align="left">'+self.type+'</TD>'
    html += '<td align="center">'+self.weight.to_s+'</TD>'
    html += '<TD align="center">&mdash;</TD>'
    html += '</TR>'
    html.html_safe
  end

  def complete
  	html = "Txt: <input id="question_txt" name="question[txt]" size="70" type="text" disabled="true"/>"
  	alternatives = self.alternatives.splict('|')
  	alternatives.each_with_index do |alternative, index|
  		html += "<input type="checkbox" id="multiple_choice"" +index_to_s+ "name=" +alternative+ ">"
  		html += alternative
  	end
  end

  def view_completed_question(response_id)
  	answer = Answer.where(question_id: self.id, response_id: response_id).first
  	html = "Txt: <input id="question_txt" name="question[txt]" size="70" type="text" disabled="true"/>"
  	alternatives = self.alternatives.splict('|')
  	alternatives.each_with_index do |alternative, index|
  		html += "<input type="checkbox" id="multiple_choice"" +index_to_s+ "name=" +alternative
  		html += "checked="checked"" if answer.answer == index
  		html += ">" + alternative
  	end
  end
end
