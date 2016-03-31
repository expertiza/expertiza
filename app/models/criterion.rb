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
    html = edit_end(self, html)

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
      if question_advice.advice && !question_advice.advice == ""
        advice_total_length += question_advice.advice.length
      end
    end

    if question_advices.length > 0 and advice_total_length > 0
       html = complete_show_advice(self, html)

      #[2015-10-26] Zhewei:
      #best to order advices high to low, e.g., 5 to 1
      #each level used to be a link;
      #clicking on the link caused the dropbox to be filled in with the corresponding number
      question_advices.reverse.each_with_index do |question_advice, index|
        html += '<a id="changeScore_>' + self.id.to_s + '" onclick="changeScore(' + count.to_s + ',' + index.to_s + ')">'
        html += (question_advices.length - index).to_s + ' - ' + question_advice.advice + '</a><br/>'
        html += '<script>'
        html += 'function changeScore(i, j) {'
        html += 'var elem = jQuery("#responses_" + i.toString() + "_score");'
        html += 'var opts = elem.children("option").length;'
        html += 'elem.val((opts - j - 1).toString());}'
        html += '</script>'
      end
      html += '</div>'
    end

    if dropdown_or_scale == 'dropdown'

      html = complete_drop_down(self, html, count, answer, questionnaire_min, questionnaire_max,cols,rows)

    elsif dropdown_or_scale == 'scale'

       html = complete_scale(self, html, count, answer, questionnaire_min, questionnaire_max,cols,rows)
    end
    html.html_safe
  end

  #This method returns what to display if a student is viewing a filled-out questionnaire
  def view_completed_question(count, answer,questionnaire_max)

		html = '<big><b>Question '+count.to_s+":</b> <I>"+self.txt+"</I></big><BR/>"

    if !answer.answer.nil?
      html += '<TABLE CELLPADDING="5"><TR><TD valign="top"><B>Score: </B></TD><TD><FONT style="BACKGROUND-COLOR:gold">'+answer.answer.to_s+'</FONT> out of <B>'+questionnaire_max.to_s+'</B></TD></TR>'
    else
      html += '<TABLE CELLPADDING="5"><TR><TD valign="top"><B>Score: </B></TD><TD><FONT style="BACKGROUND-COLOR:gold">--</FONT> out of <B>'+questionnaire_max.to_s+'</B></TD></TR>'
    end
    if answer.comments != nil
      html += '<TR><TD valign="top"><B>Response:&nbsp;</B></TD><TD>' + answer.comments.gsub("<", "&lt;").gsub(">", "&gt;").gsub(/\n/, '<BR/>')
    end
    html += '</TD></TR></TABLE><BR/>'
    html.html_safe
  end



  def complete_show_advice(ob, html)
    html += '<a id="showAdivce_' + ob.id.to_s + '" onclick="showAdvice(' + ob.id.to_s + ')">Show advice</a>'
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

    html += '<div id="' + ob.id.to_s + '_myDiv" style="display: none;">'
    return html
  end

  #This method process the complete for drop down
  def complete_drop_down(ob, html, count, answer, questionnaire_min, questionnaire_max,cols,rows)
    html += '<div><select id="responses_' +count.to_s+ '_score" name="responses[' +count.to_s+ '][score]">'
    html += '<option value=''>--</option>'
    for j in questionnaire_min..questionnaire_max
      if !answer.nil? and j == answer.answer
        html += '<option value=' + j.to_s + ' selected="selected">'
      else
        html += '<option value=' + j.to_s + '>'
      end
      if j == questionnaire_min

        html = complete_drop_down_label_config(html, ob.min_label)
      elsif j == questionnaire_max

        html = complete_drop_down_label_config(html, ob.max_label)
      else
        html += j.to_s + "</option>"
      end
    end
    html += "</select></div>"
    html = complete_answer_comment(count, html, answer,cols,rows)
    html += '</textarea></td></br><br/>'
    return html
  end

  #This method process the complete for scale
  def complete_scale(ob, html, count, answer, questionnaire_min, questionnaire_max,cols,rows)
    html += '<input id="responses_' +count.to_s+ '_score" name="responses[' +count.to_s+ '][score]" type="hidden"'
    html += 'value="'+answer.answer.to_s+'"' if !answer.nil?
    html += '>'

    html += '<table>'
    html += '<tr><td width="10%"></td>'
    for j in questionnaire_min..questionnaire_max
      html += '<td width="10%"><label>' +j.to_s+ '</label></td>'
    end
    html += '<td width="10%"></td></tr><tr>'


    html = complete_label(ob.min_label, html)
    html = complete_questionnaire_min_to_questionnaire_max(ob, html, answer, questionnaire_min, questionnaire_max)

    html += '<script>jQuery("input[name=Radio_' +ob.id.to_s+ ']:radio").change(function() {'
    html += 'var response_score = jQuery("#responses_' +count.to_s+ '_score");'
    html += 'var checked_value = jQuery("input[name=Radio_' +ob.id.to_s+ ']:checked").val();'
    html += 'response_score.val(checked_value);});</script>'

    html = complete_label(ob.max_label, html)
    html += '<td width="10%"></td></tr></table>'
    html = complete_answer_comment(count, html, answer,cols,rows)
    html += '</textarea><br/><br/>'
    return html
  end

  ## method added  to remove duplicated code
  def complete_answer_comment(count, html, answer,cols,rows)
    html += '<textarea cols=' +cols+ ' rows=' +rows+ ' id="responses_' +count.to_s+ '_comments" name="responses[' +count.to_s+ '][comment]" style="overflow:hidden;">'
    html += answer.comments if !answer.nil?
    return html
  end

  def complete_drop_down_label_config(html, label)
    html += j.to_s
    html += "-" + label if label && label.length>0
    html += "</option>"
    return html
  end

end
