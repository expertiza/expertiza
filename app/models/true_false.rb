class TrueFalse < QuizQuestion
  def edit
    quiz_item_choices = QuizQuestionChoice.where(item_id: id)

    html = '<tr><td>'
    html += '<textarea cols="100" name="item[' + id.to_s + '][txt]" '
    html += 'id="item_' + id.to_s + '_txt">' + txt + '</textarea>'
    html += '</td></tr>'

    html += '<tr><td>'
    html += 'Question Weight: '
    html += '<input type="number" name="item_weights[' + id.to_s + '][txt]" '
    html += 'id="item_wt_' + id.to_s + '_txt" '
    html += 'value="' + weight.to_s + '" min="0" />'
    html += '</td></tr>'

    html += '<tr><td>'
    html += '<input type="radio" name="quiz_item_choices[' + id.to_s + '][TrueFalse][1][iscorrect]" '
    html += 'id="quiz_item_choices_' + id.to_s + '_TrueFalse_1_iscorrect_True" value="True" '
    html += 'checked="checked" ' if quiz_item_choices[0].iscorrect
    html += '/>True'
    html += '</td></tr>'

    html += '<tr><td>'
    html += '<input type="radio" name="quiz_item_choices[' + id.to_s + '][TrueFalse][1][iscorrect]" '
    html += 'id="quiz_item_choices_' + id.to_s + '_TrueFalse_1_iscorrect_True" value="False" '
    html += 'checked="checked" ' if quiz_item_choices[1].iscorrect
    html += '/>False'
    html += '</td></tr>'

    html.html_safe
  end

  def complete
    quiz_item_choices = QuizQuestionChoice.where(item_id: id)
    html = '<label for="' + id.to_s + '">' + txt + '</label><br>'
    (0..1).each do |i|
      html += '<input name = ' + "\"#{id}\" "
      html += 'id = ' + "\"#{id}" + '_' + "#{i + 1}\" "
      html += 'value = ' + "\"#{quiz_item_choices[i].txt}\" "
      html += 'type="radio"/>'
      html += if i == 0
                'True'
              else
                'False'
              end
      html += '</br>'
    end
    html
  end

  def view_completed_item(user_answer)
    quiz_item_choices = QuizQuestionChoice.where(item_id: id)
    html = ''
    html += 'Correct Answer is: <b>'
    html += if quiz_item_choices[0].iscorrect
              'True</b><br/>'
            else
              'False</b><br/>'
            end
    html += 'Your answer is: <b>' + user_answer.first.comments.to_s
    html += if user_answer.first.answer == 1
              '<img src="/assets/Check-icon.png"/>'
            else
              '<img src="/assets/delete_icon.png"/>'
            end

    html += '</b>'
    html += '<br><br><hr>'
    html.html_safe
    # html += 'i += 1'
  end

  def isvalid(choice_info)
    valid = 'valid'
    valid = 'Please make sure all items have text' if txt == ''
    correct_count = 0
    choice_info.each do |_idx, value|
      if value[:txt] == ''
        valid = 'Please make sure every item has text for all options'
      end
      correct_count += 1 if value[:iscorrect] == 1.to_s
    end
    valid = 'Please select a correct answer for all items' if correct_count == 0
    valid
  end
end
