class Scale < ScoredQuestion
  #This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(count)
    html ='<tr>'
    html+='<td align="center"><input id="question_chk' +count.to_s+ '" type="checkbox"></td>'
    html+='<td><input size="6" value="'+self.seq.to_s+'" name="question['+self.id.to_s+'][seq]" id="question_'+self.id.to_s+'_seq" type="text"></td>'
    html+='<td><textarea cols="50" rows="1" name="question['+self.id.to_s+'][txt]" id="question_'+self.id.to_s+'_txt">'+self.txt+'</textarea></td>'
    html+='<td><input size="10" disabled="disabled" value="'+self.type+'" name="question['+self.id.to_s+'][type]" id="question_'+self.id.to_s+'_type" type="text">''</td>'
    html+='<td><input size="6" value="'+self.weight.to_s+'" name="question['+self.id.to_s+'][weight]" id="question_'+self.id.to_s+'_weight" type="text">''</td>'
    html+='<td> max_label <input size="4" value="'+self.max_label.to_s+'" name="question['+self.id.to_s+'][max_label]" id="question_'+self.id.to_s+'_max_label" type="text">  min_label <input size="4" value="'+self.min_label.to_s+'" name="question['+self.id.to_s+'][min_label]" id="question_'+self.id.to_s+'_min_label" type="text"></td>'
    html+='</tr>'

    html.html_safe
  end

  #This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    html = '<TR><TD align="left"> '+self.txt+' </TD>'
    html += '<TD align="left">'+self.type+'</TD>'
    html += '<td align="center">'+self.weight.to_s+'</TD>'
    questionnaire = self.questionnaire
    if !self.max_label.nil? && !self.min_label.nil?
      html += '<TD align="center"> ('+self.min_label+') '+questionnaire.min_question_score.to_s+' to '+ questionnaire.max_question_score.to_s + ' ('+self.max_label+')</TD>'
    else
      html += '<TD align="center">'+questionnaire.min_question_score.to_s+' to '+ questionnaire.max_question_score.to_s + '</TD>'
    end
    html += '</TR>'
    html.html_safe
  end

  def complete(count, answer=nil, questionnaire_min, questionnaire_max)
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
    html.html_safe

    html = self.txt + '<br>'
    html += '<textarea cols=' +cols+ ' rows=' +rows+ ' id="responses_' +count.to_s+ '_comments" name="responses[' +count.to_s+ '][comment]" style="overflow:hidden;">'
    html += answer.comments if !answer.nil?
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

  def view_completed_question(count, answer,questionnaire_max)
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
    html.html_safe
  end
end
