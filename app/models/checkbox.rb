class Checkbox < UnscoredQuestion
  include ActionView::Helpers
  # This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(count)
    html = edit_first_td(count) + edit_second_td(count) + edit_third_td(count)
    html += edit_forth_td(count) + edit_fifth_td(count)
    safe_join(["<tr>".html_safe, "</tr>".html_safe], html.html_safe)
  end

  def edit_first_td(_count)
    html = '<td align="center"><a rel="nofollow" data-method="delete" href="/questions/'
    html += self.id.to_s + '">Remove</a></td>'
    html
  end

  def edit_second_td(_count)
    html = '<td><input size="6" value="' + self.seq.to_s + '" name="question['
    html += self.id.to_s + '][seq]" id="question_' + self.id.to_s + '_seq" type="text"></td>'
    html
  end

  def edit_third_td(_count)
    html = '<td><textarea cols="50" rows="1" name="question[' + self.id.to_s + '][txt]" id="question_'
    html += self.id.to_s + '_txt" placeholder="Edit question content here">' + self.txt + '</textarea></td>'
    html
  end

  def edit_forth_td(_count)
    html = '<td><input size="10" disabled="disabled" value="' + self.type + '" name="question['
    html += self.id.to_s + '][type]" id="question_' + self.id.to_s + '_type" type="text"></td>'
    html
  end

  def edit_fifth_td(_count)
    html = '<td><!--placeholder (UnscoredQuestion does not need weight)--></td>'
    html
  end

  # This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    html = view_question_text_tr
    safe_join(["".html_safe, "".html_safe], html.html_safe)
  end

  def view_question_text_tr
    html = '<TR><TD align="left"> ' + self.txt + ' </TD>'
    html += '<TD align="left">' + self.type + '</TD>'
    html += '<td align="center">' + self.weight.to_s + '</TD>'
    html += '<TD align="center">Checked/Unchecked</TD>'
    html += '</TR>'
    html
  end

  def complete(count, answer = nil)
    html = complete_or_completed_question + complete_first_second_input(count)
    html += complete_input_if(answer) + complete_third_input(count, answer)
    html += '<label for="responses_' + count.to_s + '">&nbsp;&nbsp;' + self.txt + '</label>'
    html += complete_script(count) + complete_script_if
    html += complete_if_columnheader
    safe_join(["".html_safe, "".html_safe], html.html_safe)
  end

  def complete_or_completed_question
    curr_question = Question.find(self.id)
    prev_question = Question.where("seq < ?", curr_question.seq).order(:seq).last
    html = if prev_question.type == 'ColumnHeader'
             '<td style="padding: 15px;">'
           else
             ''
           end
    html
  end

  def complete_first_second_input(count)
    html = '<input id="responses_' + count.to_s + '_comments" name="responses[' + count.to_s + '][comment]" type="hidden" value="">'
    html += '<input id="responses_' + count.to_s + '_score" name="responses[' + count.to_s + '][score]" type="hidden"'
    html
  end

  def complete_input_if(answer = nil)
    html = if !answer.nil? and answer.answer == 1
             'value="1"'
           else
             'value="0"'
           end
    html += '>'
    html
  end

  def complete_third_input(count, answer = nil)
    html = '<input id="responses_' + count.to_s + '_checkbox" type="checkbox" onchange="checkbox' + count.to_s + 'Changed()"'
    html += 'checked="checked"' if !answer.nil? and answer.answer == 1
    html += '>'

    html
  end

  def complete_script(count)
    html = '<script>function checkbox' + count.to_s + 'Changed() {'
    html += ' var checkbox = jQuery("#responses_' + count.to_s + '_checkbox");'
    html += ' var response_score = jQuery("#responses_' + count.to_s + '_score");'
    html
  end

  def complete_script_if
    html = 'if (checkbox.is(":checked")) {'
    html += 'response_score.val("1");'
    html += '} else {'
    html += 'response_score.val("0");}}</script>'
    html
  end

  def complete_if_columnheader
    curr_question = Question.find(self.id)
    next_question = Question.where("seq > ?", curr_question.seq).order(:seq).first
    html = if next_question.type == 'ColumnHeader'
             '</td></tr>'
           elsif next_question.type == 'SectionHeader' or next_question.type == 'TableHeader'
             '</td></tr></table><br/>'
           else
             '<BR/>'
           end
    html
  end

  # This method returns what to display if a student is viewing a filled-out questionnaire
  def view_completed_question(count, answer)
    html = complete_or_completed_question
    html += view_completed_question_answer(count, answer)
    html += view_completed_question_if_columnheader
    safe_join(["".html_safe, "".html_safe], html.html_safe)
  end

  def view_completed_question_answer(count, answer)
    html = if answer.answer == 1
             '<b>' + count.to_s + '. &nbsp;&nbsp;<img src="/assets/Check-icon.png">' + self.txt + '</b><BR/>'
           else
             '<b>' + count.to_s + '. &nbsp;&nbsp;<img src="/assets/delete_icon.png">' + self.txt + '</b><BR/>'
           end
    html
  end

  def view_completed_question_if_columnheader
    curr_question = Question.find(self.id)
    next_question = Question.where("seq > ?", curr_question.seq).order(:seq).first
    html = if next_question.type == 'ColumnHeader'
             '</td></tr>'
           elsif next_question.type == 'TableHeader'
             '</td></tr></table><br/>'
           else
             '<BR/>'
           end
    html
  end
end
