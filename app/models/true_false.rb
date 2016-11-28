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

  def complete(count, answer = nil)
  end

  def view_completed_question(count, answer)
  end
end
