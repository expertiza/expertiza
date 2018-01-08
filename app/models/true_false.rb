class TrueFalse < QuizQuestion
  def edit
    quiz_question_choices = QuizQuestionChoice.where(question_id: self.id)

    html = '<tr><td>'
    html += '<textarea cols="100" name="question[' + self.id.to_s + '][txt]" '
    html += 'id="question_' + self.id.to_s + '_txt">' + self.txt + '</textarea>'
    html += '</td></tr>'

    html += '<tr><td>'
    html += '<input type="radio" name="quiz_question_choices[' + self.id.to_s + '][TrueFalse][1][iscorrect]" '
    html += 'id="quiz_question_choices_' + self.id.to_s + '_TrueFalse_1_iscorrect_True" value="True" '
    html += 'checked="checked" ' if quiz_question_choices[0].iscorrect
    html += '/>True'
    html += '</td></tr>'

    html += '<tr><td>'
    html += '<input type="radio" name="quiz_question_choices[' + self.id.to_s + '][TrueFalse][1][iscorrect]" '
    html += 'id="quiz_question_choices_' + self.id.to_s + '_TrueFalse_1_iscorrect_True" value="False" '
    html += 'checked="checked" ' if quiz_question_choices[1].iscorrect
    html += '/>False'
    html += '</td></tr>'

    html.html_safe
  end

  def complete
    quiz_question_choices = QuizQuestionChoice.where(question_id: self.id)
    html = "<label for=\"" + self.id.to_s + "\">" + self.txt + "</label><br>"
    for i in 0..1
      txt = quiz_question_choices[i].txt
      html += "<input name = " + "\"#{self.id}\" "
      html += "id = " + "\"#{self.id}" + "_" + "#{i + 1}\" "
      html += "value = " + "\"#{quiz_question_choices[i].txt}\" "
      html += "type=\"radio\"/>"
      html += if i == 0
                "True"
              else
                "False"
              end
      html += "</br>"
    end
    html
  end

  def view_completed_question(user_answer)
    quiz_question_choices = QuizQuestionChoice.where(question_id: self.id)
    html = ''
    html += 'Correct Answer is: <b>'
    html += if quiz_question_choices[0].iscorrect
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
    valid = "valid"
    valid = "Please make sure all questions have text" if self.txt == ''
    correct_count = 0
    choice_info.each do |_idx, value|
      if value[:txt] == ''
        valid = "Please make sure every question has text for all options"
        break
      end
      correct_count += 1 if value.key?(:iscorrect)
    end
    valid = "Please select a correct answer for all questions" if correct_count == 0
    valid
  end
end
