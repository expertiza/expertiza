class Criterion < ScoredQuestion
  validates_presence_of :size

  #This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(count)
    html ='<tr>'
    html+='<td align="center"><input id="question_chk' +count.to_s+ '" type="checkbox"></td>'
    html+='<td><input size="6" value="'+self.seq.to_s+'" name="question['+self.id.to_s+'][seq]" id="question_'+self.id.to_s+'_seq" type="text"></td>'
    html+='<td><textarea cols="50" rows="1" name="question['+self.id.to_s+'][txt]" id="question_'+self.id.to_s+'_txt">'+self.txt+'</textarea></td>'
    html+='<td><input size="10" disabled="disabled" value="'+self.type+'" name="question['+self.id.to_s+'][type]" id="question_'+self.id.to_s+'_type" type="text">''</td>'
    html+='<td><input size="6" value="'+self.weight.to_s+'" name="question['+self.id.to_s+'][weight]" id="question_'+self.id.to_s+'_weight" type="text">''</td>'
    html+='<td>text area size <input size="6" value="'+self.size.to_s+'" name="question['+self.id.to_s+'][size]" id="question_'+self.id.to_s+'_size" type="text"></td>'
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

  def complete(count, answer=nil, questionnaire_min, questionnaire_max, dropdown_or_scale)
  	if self.size.nil?
      cols = '70'
      rows = '1'
    else 
      cols = self.size.split(',')[0]
      rows = self.size.split(',')[1]
    end

    html = self.txt + '<br>'
    if dropdown_or_scale == 'dropdown'
      html += '<table><td valign="top"><textarea cols=' +cols+ ' rows=' +rows+ ' id="responses_' +count.to_s+ '_comments" name="responses[' +count.to_s+ '][comment]" style="overflow:hidden;">'
      html += answer.comments if !answer.nil?
      html += '</textarea></td><td valign="top">'
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
      html += "</select></td></table><br><br><br>"
    elsif dropdown_or_scale == 'scale'
      html += '<input id="responses_' +count.to_s+ '_score" name="responses[' +count.to_s+ '][score]" type="hidden"'
      html += 'value="'+answer.answer.to_s+'"' if !answer.nil?
      html += '>'

      html += '<table>'
      html += '<tr><td width="10%"></td>'
      for j in questionnaire_min..questionnaire_max
        html += '<td width="10%"><label>' +j.to_s+ '</label></td>'
      end
      html += '<td width="10%"></td></tr><tr>'

      if !self.min_label.nil?
        html += '<td width="10%">' +self.min_label+ '</td>'
      else
        html += '<td width="10%"></td>'
      end
      for j in questionnaire_min..questionnaire_max
        html += '<td width="10%"><input type="radio" id="' +j.to_s+ '" value="' +j.to_s+ '" name="Radio_' +self.id.to_s+ '"'
        html += 'checked="checked"' if !answer.nil? && answer.answer == j
        html += '></td>'
      end
      if !self.max_label.nil?
        html += '<td width="10%">' +self.max_label+ '</td>'
      else
        html += '<td width="10%"></td>'
      end

      html += '<td width="10%"></td></tr></table>'
      html += '<textarea cols=' +cols+ ' rows=' +rows+ ' id="responses_' +count.to_s+ '_comments" name="responses[' +count.to_s+ '][comment]" style="overflow:hidden;">'
      html += answer.comments if !answer.nil?
      html += '</textarea><br/>'
      html += '<script>$("input[name=Radio_' +self.id.to_s+ ']:radio").change(function() {'
      html += 'var response_score = jQuery("#responses_' +count.to_s+ '_score");'
      html += 'for (i = <%=questionnaire_min%>; i <= <%=questionnaire_max%>; i++) { '
      html += 'if (jQuery("#"+i.toString()).attr("checked")) {'
      html += 'response_score.val(jQuery("#"+i.toString()).val());}}}</script>'
    end
    html.html_safe
  end

  #This method returns what to display if a student is viewing a filled-out questionnaire
  def view_completed_question(count, answer,questionnaire_max)
		html = '<big><b>Question '+count.to_s+":</b> <I>"+self.txt+"</I></big><BR/><BR/>"
		html += '<TABLE CELLPADDING="5"><TR><TD valign="top"><B>Score:</B></TD><TD><FONT style="BACKGROUND-COLOR:gold">'+answer.answer.to_s+"</FONT> out of <B>"+questionnaire_max.to_s+"</B></TD></TR>"
		if answer.comments != nil
			html += '<TR><TD valign="top"><B>Response:</B></TD><TD>' + answer.comments.gsub("<", "&lt;").gsub(">", "&gt;").gsub(/\n/, '<BR/>')
		end
		html += '</TD></TR></TABLE><BR/>'
		html.html_safe
  end

  
end
