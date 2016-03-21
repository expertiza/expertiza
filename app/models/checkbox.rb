class Checkbox < UnscoredQuestion
  #This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(count)
    html = edit_prefix(self, html)
    html+='<td><!--placeholder (UnscoredQuestion does not need weight)--></td>'
    html+='</tr>'

    html.html_safe
  end

  #This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    html = view_qt_prefix(self, html)
    html += '<TD align="center">Checked/Unchecked</TD>'
    html += '</TR>'
    html.html_safe
  end

  def complete(count, answer=nil)
    curr_question = Question.find(self.id)
    prev_question = Question.where("seq < ?", curr_question.seq).order(:seq).last
    next_question = Question.where("seq > ?", curr_question.seq).order(:seq).first
    html = ''
    if prev_question.type == 'ColumnHeader'
      html = '<td style="padding: 15px;">'
    end

    html += '<input id="responses_' +count.to_s+ '_comments" name="responses[' +count.to_s+ '][comment]" type="hidden" value="">'
    html += '<input id="responses_' +count.to_s+ '_score" name="responses[' +count.to_s+ '][score]" type="hidden"'
    html += hasAnswer(html , answer)
    html += '>'
    html += '<input id="responses_' +count.to_s+ '_checkbox" type="checkbox" onchange="checkbox' +count.to_s+ 'Changed()"'
    html += 'checked="checked"' if !answer.nil? and answer.answer == 1
    html += '>'
    html += '<label for="responses_' +count.to_s+ '">' +self.txt+ '</label>'

    html += '<script>function checkbox' +count.to_s+ 'Changed() {'
    html += ' var checkbox = jQuery("#responses_' +count.to_s+ '_checkbox");'
    html += ' var response_score = jQuery("#responses_' +count.to_s+ '_score");'
    html += 'if (checkbox.is(":checked")) {'
    html += 'response_score.val("1");'
    html += '} else {' 
    html += 'response_score.val("0");}}</script>'
    
    html = nextQuestionTail(html, next_question)
    html.html_safe
  end


  #YJ private for complete()
  def hasAnswer(html, answer)
    if !answer.nil? and answer.answer == 1
      html += 'value="1"'
    else
      html += 'value="0"'
    end 
    return html
  end
  
  def nextQuestionTail(html, next_q)
    if next_q.type == 'ColumnHeader'
      html += '</td></tr>'
    elsif next_q.type == 'SectionHeader' or next_q.type == 'TableHeader'
      html += '</td></tr></table><br/>'
    else
      html += '<BR/>'
    end
    return html 
  end

  #This method returns what to display if a student is viewing a filled-out questionnaire
  def view_completed_question(count, answer)
    curr_question = Question.find(self.id)
    prev_question = Question.where("seq < ?", curr_question.seq).order(:seq).last
    next_question = Question.where("seq > ?", curr_question.seq).order(:seq).first
    if prev_question.type == 'ColumnHeader'
      html = '<td style="padding: 15px;">'
    else
      html = ''
    end
    if answer.answer == 1
      html += '<big><b>Question '+count.to_s+':</b>&nbsp;&nbsp;<img src="/assets/Check-icon.png"><i>'+self.txt+'</i></big><BR/>'
    else
      html += '<big><b>Question '+count.to_s+':</b>&nbsp;&nbsp;<img src="/assets/delete_icon.png"><i>'+self.txt+'</i></big><BR/>'
    end
    
    if next_question.type == 'ColumnHeader'
      html += '</td></tr>'
    elsif next_question.type == 'TableHeader'
      html += '</td></tr></table><br/>'
    else
      html += '<BR/>'
    end

    html.html_safe
  end
end
