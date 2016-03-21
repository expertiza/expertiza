class Scale < ScoredQuestion
  #This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(count)
    html ='<tr>'
    html+='<td align="center"><a rel="nofollow" data-method="delete" href="/questions/' +self.id.to_s+ '">Remove</a></td>'
    html+='<td><input size="6" value="'+self.seq.to_s+'" name="question['+self.id.to_s+'][seq]" id="question_'+self.id.to_s+'_seq" type="text"></td>'
    html+='<td><textarea cols="50" rows="1" name="question['+self.id.to_s+'][txt]" id="question_'+self.id.to_s+'_txt">'+self.txt+'</textarea></td>'
    html+='<td><input size="10" disabled="disabled" value="'+self.type+'" name="question['+self.id.to_s+'][type]" id="question_'+self.id.to_s+'_type" type="text">''</td>'
    html+='<td><input size="2" value="'+self.weight.to_s+'" name="question['+self.id.to_s+'][weight]" id="question_'+self.id.to_s+'_weight" type="text">''</td>'
    html = edit_end(self, html)
    html.html_safe
  end

  def complete(count, answer=nil, questionnaire_min, questionnaire_max)
  	html = self.txt + '<br>'
    html += '<input id="responses_' +count.to_s+ '_score" name="responses[' +count.to_s+ '][score]" type="hidden"'
    html += 'value="'+answer.answer.to_s+'"' if !answer.nil?
    html += '>'
    html += '<input id="responses_' +count.to_s+ '_comments" name="responses[' +count.to_s+ '][comment]" type="hidden" value="">'

    html += '<table>'
    html += '<tr><td width="10%"></td>'
    for j in questionnaire_min..questionnaire_max
      html += '<td width="10%"><label>' +j.to_s+ '</label></td>'
    end
    html += '<td width="10%"></td></tr><tr>'
    html = complete_label(self.min_label, html)
    html = complete_questionnaire_min_to_questionnaire_max(self, html, answer, questionnaire_min, questionnaire_max)
    html += '<script>jQuery("input[name=Radio_' +self.id.to_s+ ']:radio").change(function() {'
    html += 'var response_score = jQuery("#responses_' +count.to_s+ '_score");'
    html += 'var checked_value = jQuery("input[name=Radio_' +self.id.to_s+ ']:checked").val();'
    html += 'response_score.val(checked_value);});</script>'
    html = complete_label(self.max_label, html)

    html += '<td width="10%"></td></tr></table>'
    html.html_safe
  end

  def view_completed_question(count, answer,questionnaire_max)
    html = '<big><b>Question '+count.to_s+":</b> <I>"+self.txt+"</I></big><BR/><BR/>"
  	html += '<B>Score:</B> <FONT style="BACKGROUND-COLOR:gold">'+answer.answer.to_s+'</FONT> out of <B>'+questionnaire_max.to_s+'</B></TD>'
    html.html_safe
  end


end
