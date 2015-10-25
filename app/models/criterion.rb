class Criterion < ScoredQuestion
  validates_presence_of :size

  #This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(count)
    html ='<tr>'
    html+='<td align="center"><a rel="nofollow" data-method="delete" href="/questions/' +self.id.to_s+ '">Remove</a></td>'
    html+='<td><input size="6" value="'+self.seq.to_s+'" name="question['+self.id.to_s+'][seq]" id="question_'+self.id.to_s+'_seq" type="text"></td>'
    html+='<td><textarea cols="50" rows="1" name="question['+self.id.to_s+'][txt]" id="question_'+self.id.to_s+'_txt">'+self.txt+'</textarea></td>'
    html+='<td><input size="10" disabled="disabled" value="'+self.type+'" name="question['+self.id.to_s+'][type]" id="question_'+self.id.to_s+'_type" type="text">''</td>'
    html+='<td><input size="2" value="'+self.weight.to_s+'" name="question['+self.id.to_s+'][weight]" id="question_'+self.id.to_s+'_weight" type="text">''</td>'
    html+='<td>text area size <input size="3" value="'+self.size.to_s+'" name="question['+self.id.to_s+'][size]" id="question_'+self.id.to_s+'_size" type="text"></td>'
    html+='<td> max_label <input size="10" value="'+self.max_label.to_s+'" name="question['+self.id.to_s+'][max_label]" id="question_'+self.id.to_s+'_max_label" type="text">  min_label <input size="10" value="'+self.min_label.to_s+'" name="question['+self.id.to_s+'][min_label]" id="question_'+self.id.to_s+'_min_label" type="text"></td>'
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

    html = '<li><div><label for="responses_' +count.to_s+ '">' +self.txt+ '</label></div>'
    #show advice for each criterion question
    question_advices = QuestionAdvice.where(question_id: self.id).sort_by { |advice| advice.id }
    advice_total_length = 0
    question_advices.each do |question_advice|
      advice_total_length += question_advice.advice.length
    end

    if question_advices.length > 0 and advice_total_length > 0
      html += '<a id="showAdivce_' + self.id.to_s + '" onclick="showAdvice(' + self.id.to_s + ')">Show advice</a>'
      html += '<script>'
      html += 'function showAdvice(i){'
      html += 'var element = document.getElementById("showAdivce_" + i.toString());'
      html += 'var show = element.innerHTML == "Hide advice";'
      html += 'if (show){'
      html += 'element.innerHTML="Show advice";'
      html += '}else{'
      html += 'element.innerHTML="Hide advice";}'
      html += 'toggleAdvice(i);}'

      html += 'function toggleAdvice(i) {'
      html += 'var elem = document.getElementById(i.toString() + "_myDiv");'
      html += 'if (elem.style.display == "none") {'
      html += 'elem.style.display = "";'
      html += '} else {'
      html += 'elem.style.display = "none";}}'
      html += '</script>'
    end

    html += '<div id="' + self.id.to_s + '_myDiv" style="display: none;">'
    for advice_num in 0..question_advices.length - 1
      html += (advice_num + 1).to_s + ' - ' + question_advices[advice_num].advice + '<br/>'
    end
    html += '</div>'

    if dropdown_or_scale == 'dropdown'
      html += '<div><select id="responses_' +count.to_s+ '_score" name="responses[' +count.to_s+ '][score]">'
      html += '<option value=''>--</option>'
      for j in questionnaire_min..questionnaire_max
        if !answer.nil? and j == answer.answer
          html += '<option value=' + j.to_s + ' selected="selected">' 
        else
          html += '<option value=' + j.to_s + '>'
        end
        if j == questionnaire_min
          html += j.to_s
          html += "-" + self.min_label if self.min_label && self.min_label.length>0
          html += "</option>"
        elsif j == questionnaire_max
          html += j.to_s
          html += "-" + self.max_label if self.max_label && self.max_label.length>0
          html += "</option>"
        else
          html += j.to_s + "</option>"
        end
      end
      html += "</select></div>"
      html += '<textarea cols=' +cols+ ' rows=' +rows+ ' id="responses_' +count.to_s+ '_comments" name="responses[' +count.to_s+ '][comment]" style="overflow:hidden;">'
      html += answer.comments if !answer.nil?
      html += '</textarea></td></br><br/>'
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
        html += 'checked="checked"' if (!answer.nil? and answer.answer == j) or (answer.nil? and questionnaire_min == j)
        html += '></td>'
      end
      html += '<script>jQuery("input[name=Radio_' +self.id.to_s+ ']:radio").change(function() {'
      html += 'var response_score = jQuery("#responses_' +count.to_s+ '_score");'
      html += 'var checked_value = jQuery("input[name=Radio_' +self.id.to_s+ ']:checked").val();'
      html += 'response_score.val(checked_value);});</script>'

      if !self.max_label.nil?
        html += '<td width="10%">' +self.max_label+ '</td>'
      else
        html += '<td width="10%"></td>'
      end

      html += '<td width="10%"></td></tr></table>'
      html += '<textarea cols=' +cols+ ' rows=' +rows+ ' id="responses_' +count.to_s+ '_comments" name="responses[' +count.to_s+ '][comment]" style="overflow:hidden;">'
      html += answer.comments if !answer.nil?
      html += '</textarea><br/><br/>'

    end
    html.html_safe
  end

  #This method returns what to display if a student is viewing a filled-out questionnaire
  def view_completed_question(count, answer,questionnaire_max)
		html = '<big><b>Question '+count.to_s+":</b> <I>"+self.txt+"</I></big><BR/><BR/>"
    if !answer.answer.nil?
		  html += '<TABLE CELLPADDING="5"><TR><TD valign="top"><B>Score:</B></TD><TD><FONT style="BACKGROUND-COLOR:gold">'+answer.answer.to_s+'</FONT> out of <B>'+questionnaire_max.to_s+'</B></TD></TR>'
    else
      html += '<TABLE CELLPADDING="5"><TR><TD valign="top"><B>Score:</B></TD><TD><FONT style="BACKGROUND-COLOR:gold">--</FONT> out of <B>'+questionnaire_max.to_s+'</B></TD></TR>'
    end
		if answer.comments != nil
			html += '<TR><TD valign="top"><B>Response:</B></TD><TD>' + answer.comments.gsub("<", "&lt;").gsub(">", "&gt;").gsub(/\n/, '<BR/>')
		end
		html += '</TD></TR></TABLE><BR/>'
		html.html_safe
  end

  
end
