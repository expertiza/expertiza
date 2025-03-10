class Scale < ScoredQuestion
  # This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(_count)
    html = '<tr>'
    html += '<td align="center"><a rel="nofollow" data-method="delete" href="/questions/' + id.to_s + '">Remove</a></td>'
    html += '<td><input size="6" value="' + seq.to_s + '" name="question[' + id.to_s + '][seq]" id="question_' + id.to_s
    html += '_seq" type="text"></td><td><textarea cols="50" rows="1" name="question[' + id.to_s + '][txt]" id="question_' + id.to_s
    html += '_txt" placeholder="Edit question content here">' + txt + '</textarea></td>'
    html += '<td><input size="10" disabled="disabled" value="' + type + '" name="question[' + id.to_s
    html += '][type]" id="question_' + id.to_s + '_type" type="text"></td>'
    html += '<td><input size="2" value="' + weight.to_s + '" name="question[' + id.to_s
    html += '][weight]" id="question_' + id.to_s + '_weight" type="text"></td>'
    html += '<td> max_label <input size="10" value="' + max_label.to_s + '" name="question[' + id.to_s + '][max_label]" id="question_' + id.to_s
    html += '_max_label" type="text">  min_label <input size="12" value="' + min_label.to_s + '" name="question[' + id.to_s
    html += '][min_label]" id="question_' + id.to_s + '_min_label" type="text"></td>'
    html += '</tr>'

    html.html_safe
  end

  # This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    html = '<TR><TD align="left"> ' + txt + ' </TD>'
    html += '<TD align="left">' + type + '</TD>'
    html += '<td align="center">' + weight.to_s + '</TD>'
    questionnaire = self.questionnaire
    if max_label.nil? || min_label.nil?
      html += '<TD align="center">' + questionnaire.min_question_score.to_s + ' to ' + questionnaire.max_question_score.to_s + '</TD>'
    else
      html += '<TD align="center"> (' + min_label + ') ' + questionnaire.min_question_score.to_s + ' to '
      html += questionnaire.max_question_score.to_s + ' (' + max_label + ')</TD>'
    end
    html += '</TR>'
    html.html_safe
  end

  def complete(count, questionnaire_min, questionnaire_max, answer = nil)
    html = '<div><label for="responses_' + count.to_s + '">' + txt + '</label></div>'
    html += '<input id="responses_' + count.to_s + '_score" name="responses[' + count.to_s + '][score]" type="hidden"'
    html += 'value="' + answer.answer.to_s + '"' unless answer.nil?
    html += '>'
    html += '<input id="responses_' + count.to_s + '_comments" name="responses[' + count.to_s + '][comment]" type="hidden" value="">'

    html += '<table>'
    html += '<tr><td width="10%"></td>'
    (questionnaire_min..questionnaire_max).each do |j|
      html += '<td width="10%"><label>' + j.to_s + '</label></td>'
    end
    html += '<td width="10%"></td></tr><tr>'

    html += if min_label.nil?
              '<td width="10%"></td>'
            else
              '<td width="10%">' + min_label + '</td>'
            end
    (questionnaire_min..questionnaire_max).each do |j|
      html += '<td width="10%"><input type="radio" id="' + j.to_s
      html += '" value="' + j.to_s + '" name="Radio_' + id.to_s + '"'
      html += 'checked="checked"' unless (answer.nil? || (answer.answer != j)) && (answer || (questionnaire_min != j))
      html += '></td>'
    end
    html += '<script>jQuery("input[name=Radio_' + id.to_s + ']:radio").change(function() {'
    html += 'var response_score = jQuery("#responses_' + count.to_s + '_score");'
    html += 'var checked_value = jQuery("input[name=Radio_' + id.to_s + ']:checked").val();'
    html += 'response_score.val(checked_value);});</script>'

    html += if max_label.nil?
              '<td width="10%"></td>'
            else
              '<td width="10%">' + max_label + '</td>'
            end

    html += '<td width="10%"></td></tr></table><br/>'
    html.html_safe
  end

  def view_completed_question(count, answer, questionnaire_max)
    html = '<b>' + count.to_s + '. ' + txt + '</b><BR/><BR/>'
    html += '<B>Score:</B> <FONT style="BACKGROUND-COLOR:gold">' + answer.answer.to_s + '</FONT> out of <B>' + questionnaire_max.to_s + '</B></TD>'
    html.html_safe
  end
end
