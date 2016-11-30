class MultipleChoiceRadio < QuizQuestion
  def edit
    quiz_question_choices = QuizQuestionChoice.where(question_id: self.id)

    html = '<tr><td>'
    html += '<textarea cols="100" name="question[' + self.id.to_s + '][txt]" '
    html += 'id="question_' + self.id.to_s + '_txt">' + self.txt + '</textarea>'
    html += '</td></tr>'

    for i in 0..3
      html += "<tr><td>"

      html += '<input type="radio" name="quiz_question_choices[' + self.id.to_s + '][MultipleChoiceRadio][correctindex]" '
      html += 'id="quiz_question_choices_' + self.id.to_s + '_MultipleChoiceRadio_correctindex_' + (i + 1).to_s + '" value="' + (i + 1).to_s + '" '
      html += 'checked="checked" ' if quiz_question_choices[i].iscorrect
      html += '/>'

      html += '<input type="text" name="quiz_question_choices[' + self.id.to_s + '][MultipleChoiceRadio][' + (i + 1).to_s + '][txt]" '
      html += 'id="quiz_question_choices_' + self.id.to_s + '_MultipleChoiceRadio_' + (i + 1).to_s + '_txt" '
      html += 'value="' + quiz_question_choices[i].txt + '" size="40" />'

      html += '</td></tr>'
    end

    html.html_safe
  end

  def complete(count, answer = nil)
  end

  def view_completed_question(count, answer)
  end
end
