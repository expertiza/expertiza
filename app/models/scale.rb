class Scale < ScoredQuestion
  include ActionView::Helpers
  # This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(count)
    html = edit_first_td(count) + edit_second_td(count)
    html += edit_third_td(count) + edit_forth_td(count)
    html += edit_sixth_td_max_label(count) + edit_sixth_td_min_label(count)
    safe_join([raw("<tr>"), raw("</tr>")], raw(html))
  end

  def edit_first_td(_count)
    html = '<td align="center"><a rel="nofollow" data-method="delete" href="/questions/'
    html += self.id.to_s + '">Remove</a></td>'
    html += '<td><input size="6" value="' + self.seq.to_s + '" name="question['

    html
  end

  def edit_second_td(_count)
    html = self.id.to_s + '][seq]" id="question_' + self.id.to_s + '_seq" type="text"></td>'
    html += '<td><textarea cols="50" rows="1" name="question[' + self.id.to_s + '][txt]" id="question_'

    html
  end

  def edit_third_td(_count)
    html = self.id.to_s + '_txt" placeholder="Edit question content here">' + self.txt + '</textarea></td>'
    html += '<td><input size="10" disabled="disabled" value="' + self.type + '" name="question['
    html
  end

  def edit_forth_td(_count)
    html = self.id.to_s + '][type]" id="question_' + self.id.to_s + '_type" type="text"></td>'
    html += '<td><input size="2" value="' + self.weight.to_s + '" name="question[' + self.id.to_s
    html += '][weight]" id="question_'
    html
  end

  def edit_sixth_td_max_label(_count)
    html = self.id.to_s + '_weight" type="text"></td>'
    html += '<td> max_label <input size="10" value="' + self.max_label.to_s
    html += '" name="question[' + self.id.to_s + '][max_label]" id="question_' + self.id.to_s
    html
  end

  def edit_sixth_td_min_label(_count)
    html = '_max_label" type="text">  min_label <input size="12" value="' + self.min_label.to_s
    html += '" name="question[' + self.id.to_s + '][min_label]" id="question_'
    html += self.id.to_s + '_min_label" type="text"></td>'
    html
  end

  # This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    html = view_question_text_tr
    html += view_question_text_if + '</TR>'
    safe_join(["".html_safe, "".html_safe], html.html_safe)
  end

  def view_question_text_tr
    html = '<TR><TD align="left"> ' + self.txt + ' </TD>'
    html += '<TD align="left">' + self.type + '</TD>'
    html += '<td align="center">' + self.weight.to_s + '</TD>'
    html
  end

  def view_question_text_if
    if !self.max_label.nil? && !self.min_label.nil?
      html = view_question_text_if_labelnil
    else
      html = view_question_text_if_label
    end
    html
  end

  def view_question_text_if_labelnil
    questionnaire = self.questionnaire
    html = '<TD align="center"> (' + self.min_label + ') '
    html += questionnaire.min_question_score.to_s
    html += ' to ' + questionnaire.max_question_score.to_s
    html += ' (' + self.max_label + ')</TD>'
    html
  end

  def view_question_text_if_label
    questionnaire = self.questionnaire
    html = '<TD align="center">' + questionnaire.min_question_score.to_s
    html += ' to ' + questionnaire.max_question_score.to_s + '</TD>'
    html
  end

  def complete(count, answer = nil, questionnaire_min, questionnaire_max)
    html = complete_list_div(count) + complete_list_input(count,answer) + complete_input(count)
    html += complete_table(questionnaire_min, questionnaire_max)
    html += complete_min_label(answer, questionnaire_min, questionnaire_max)
    html += complete_jquery(count) + complete_max_label
    safe_join(["".html_safe, "".html_safe], html.html_safe)
  end

  def complete_list_div(count)
    html = '<li><div><label for="responses_' + count.to_s + '">' + self.txt + '</label></div>'
    html
  end

  def complete_list_input(count,answer)
    html = '<input id="responses_' + count.to_s
    html += '_score" name="responses[' + count.to_s + '][score]" type="hidden"'
    html += 'value="' + answer.answer.to_s + '"' unless answer.nil?
    html += '>'
    html
  end

  def complete_input(count)
    html = '<input id="responses_' + count.to_s
    html += '_comments" name="responses[' + count.to_s + '][comment]" type="hidden" value="">'
    html
  end

  def complete_table(questionnaire_min, questionnaire_max)
    html = '<table>'
    html += '<tr><td width="10%"></td>'
    (questionnaire_min..questionnaire_max).each do |j|
      html += '<td width="10%"><label>' + j.to_s + '</label></td>'
    end
    html += '<td width="10%"></td></tr><tr>'
    html
  end

  def complete_min_label(answer = nil, questionnaire_min, questionnaire_max)
    html = if !self.min_label.nil?
             '<td width="10%">' + self.min_label + '</td>'
           else
             '<td width="10%"></td>'
           end
    (questionnaire_min..questionnaire_max).each do |j|
      html = '<td width="10%"><input type="radio" id="' + j.to_s + '" value="' + j.to_s + '" name="Radio_' + self.id.to_s + '"'
      html += 'checked="checked"' if (!answer.nil? and answer.answer == j) or (answer.nil? and questionnaire_min == j)
      html += '></td>'
    end
    html
  end

  def complete_jquery(_count)
    html = '<script>jQuery("input[name=Radio_' + self.id.to_s + ']:radio").change(function() {'
    html += 'var response_score = jQuery("#responses_' + count.to_s + '_score");'
    html += 'var checked_value = jQuery("input[name=Radio_' + self.id.to_s + ']:checked").val();'
    html += 'response_score.val(checked_value);});</script>'
    html
  end

  def complete_max_label
    html = if !self.max_label.nil?
             '<td width="10%">' + self.max_label + '</td>'
           else
             '<td width="10%"></td>'
           end
    html += '<td width="10%"></td></tr></table><br/>'
    html
  end

  def view_completed_question(count, answer, questionnaire_max)
    html = '<b>' + count.to_s + ". " + self.txt + "</b><BR/><BR/>"
    html += '<B>Score:</B> <FONT style="BACKGROUND-COLOR:gold">' + answer.answer.to_s
    html += '</FONT> out of <B>' + questionnaire_max.to_s + '</B></TD>'
    safe_join(["".html_safe, "".html_safe], html.html_safe)
  end
end
