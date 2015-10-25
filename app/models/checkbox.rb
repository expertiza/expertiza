class Checkbox < UnscoredQuestion
  #This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(count)
    html ='<tr>'
    html+='<td align="center"><a rel="nofollow" data-method="delete" href="/questions/' +self.id.to_s+ '">Remove</a></td>'
    html+='<td><input size="6" value="'+self.seq.to_s+'" name="question['+self.id.to_s+'][seq]" id="question_'+self.id.to_s+'_seq" type="text"></td>'
    html+='<td><textarea cols="50" rows="1" name="question['+self.id.to_s+'][txt]" id="question_'+self.id.to_s+'_txt">'+self.txt+'</textarea></td>'
    html+='<td><input size="10" disabled="disabled" value="'+self.type+'" name="question['+self.id.to_s+'][type]" id="question_'+self.id.to_s+'_type" type="text">''</td>'
    html+='<td><!--placeholder (UnscoredQuestion does not need weight)--></td>'
    html+='</tr>'

    html.html_safe
  end

  #This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    html = '<TR><TD align="left"> '+self.txt+' </TD>'
    html += '<TD align="left">'+self.type+'</TD>'
    html += '<td align="center">'+self.weight.to_s+'</TD>'
    html += '<TD align="center">Checked/Unchecked</TD>'
    html += '</TR>'
    html.html_safe
  end

  def complete(count, answer=nil)
    curr_question = Question.find(self.id)
    prev_question = Question.where("seq < ?", curr_question.seq).order(:seq).last
    next_question = Question.where("seq > ?", curr_question.seq).order(:seq).first
    if prev_question.type == 'ColumnHeader'
      html = '<td style="padding: 15px;">'
    else
      html = ''
    end

    html += '<input id="responses_' +count.to_s+ '_comments" name="responses[' +count.to_s+ '][comment]" type="hidden" value="">'
    html += '<input id="responses_' +count.to_s+ '_score" name="responses[' +count.to_s+ '][score]" type="hidden"'
    if !answer.nil? and answer.answer == 1
      html += 'value="1"'
    else
      html += 'value="0"'
    end 
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

    if next_question.type == 'ColumnHeader'
      html += '</td></tr>'
    elsif next_question.type == 'SectionHeader' or next_question.type == 'TableHeader'
      html += '</td></tr></table><br/>'
    else
      html += '<BR/>'
    end
    html.html_safe
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
