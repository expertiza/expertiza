class Scale < ScoredQuestion
  # This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(_count)
    html = '<tr>'
    html += '<td align="center"><a rel="nofollow" data-method="delete" href="/questions/' + self.id.to_s + '">Remove</a></td>'
    html += '<td><input size="6" value="' + self.seq.to_s + '" name="question[' + self.id.to_s + '][seq]" id="question_' + self.id.to_s
    html += '_seq" type="text"></td><td><textarea cols="50" rows="1" name="question[' + self.id.to_s + '][txt]" id="question_' + self.id.to_s
    html += '_txt" placeholder="Edit question content here">' + self.txt + '</textarea></td>'
    html += '<td><input size="10" disabled="disabled" value="' + self.type + '" name="question[' + self.id.to_s
    html += '][type]" id="question_' + self.id.to_s + '_type" type="text"></td>'
    html += '<td><input size="2" value="' + self.weight.to_s + '" name="question[' + self.id.to_s
    html += '][weight]" id="question_' + self.id.to_s + '_weight" type="text"></td>'
    html += '<td> max_label <input size="10" value="' + self.max_label.to_s + '" name="question[' + self.id.to_s + '][max_label]" id="question_' + self.id.to_s
    html += '_max_label" type="text">  min_label <input size="12" value="' + self.min_label.to_s + '" name="question[' + self.id.to_s
    html += '][min_label]" id="question_' + self.id.to_s + '_min_label" type="text"></td>'
    html += '</tr>'

    html.html_safe
  end

  # This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    html = '<TR><TD align="left"> ' + self.txt + ' </TD>'
    html += '<TD align="left">' + self.type + '</TD>'
    html += '<td align="center">' + self.weight.to_s + '</TD>'
    questionnaire = self.questionnaire
    if !self.max_label.nil? && !self.min_label.nil?
      html += '<TD align="center"> (' + self.min_label + ') ' + questionnaire.min_question_score.to_s + ' to '
      html += questionnaire.max_question_score.to_s + ' (' + self.max_label + ')</TD>'
    else
      html += '<TD align="center">' + questionnaire.min_question_score.to_s + ' to ' + questionnaire.max_question_score.to_s + '</TD>'
    end
    html += '</TR>'
    html.html_safe
  end

  def complete(count, questionnaire_min, questionnaire_max, answer = nil)
    html = '<div><label for="responses_' + count.to_s + '">' + self.txt + '</label></div>'
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

    html += if !self.min_label.nil?
              '<td width="10%">' + self.min_label + '</td>'
            else
              '<td width="10%"></td>'
            end
    (questionnaire_min..questionnaire_max).each do |j|
      html += '<td width="10%"><input type="radio" id="' + j.to_s
      html += '" value="' + j.to_s + '" name="Radio_' + self.id.to_s + '"'
      html += 'checked="checked"' if (!answer.nil? and answer.answer == j) or (answer.nil? and questionnaire_min == j)
      html += '></td>'
    end
    html += '<script>jQuery("input[name=Radio_' + self.id.to_s + ']:radio").change(function() {'
    html += 'var response_score = jQuery("#responses_' + count.to_s + '_score");'
    html += 'var checked_value = jQuery("input[name=Radio_' + self.id.to_s + ']:checked").val();'
    html += 'response_score.val(checked_value);});</script>'

    html += if !self.max_label.nil?
              '<td width="10%">' + self.max_label + '</td>'
            else
              '<td width="10%"></td>'
            end

    html += '<td width="10%"></td></tr></table><br/>'
    html.html_safe
  end

  def view_completed_question(count, answer, questionnaire_max)
    html = '<b>' + count.to_s + ". " + self.txt + "</b><BR/><BR/>"
    html += '<B>Score:</B> <FONT style="BACKGROUND-COLOR:gold">' + answer.answer.to_s + '</FONT> out of <B>' + questionnaire_max.to_s + '</B></TD>'
    html.html_safe
  end
end
