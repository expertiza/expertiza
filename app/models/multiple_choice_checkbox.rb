class MultipleChoiceCheckbox < QuizQuestion
  def edit
    quiz_question_choices = QuizQuestionChoice.where(question_id: self.id)

    html = '<tr><td>'
    html += '<textarea cols="100" name="question[' + self.id.to_s + '][txt]" '
    html += 'id="question_' + self.id.to_s + '_txt">' + self.txt + '</textarea>'
    html += '</td></tr>'

    for i in 0..3
      html += "<tr><td>"

      html += '<input type="hidden" name="quiz_question_choices[' + self.id.to_s + '][MultipleChoiceCheckbox][' + (i + 1).to_s + '][iscorrect]" '
      html += 'id="quiz_question_choices_' + self.id.to_s + '_MultipleChoiceCheckbox_' + (i + 1).to_s + '_iscorrect" value="0" />'

      html += '<input type="checkbox" name="quiz_question_choices[' + self.id.to_s + '][MultipleChoiceCheckbox][' + (i + 1).to_s + '][iscorrect]" '
      html += 'id="quiz_question_choices_' + self.id.to_s + '_MultipleChoiceCheckbox_' + (i + 1).to_s + '_iscorrect" value="1" '
      html += 'checked="checked" ' if quiz_question_choices[i].iscorrect
      html += '/>'

      html += '<input type="text" name="quiz_question_choices[' + self.id.to_s + '][MultipleChoiceCheckbox][' + (i + 1).to_s + '][txt]" '
      html += 'id="quiz_question_choices_' + self.id.to_s + '_MultipleChoiceCheckbox_' + (i + 1).to_s + '_txt" '
      html += 'value="' + quiz_question_choices[i].txt + '" size="40" />'

      html += '</td></tr>'
    end

    html.html_safe
  end

  def complete
    quiz_question_choices = QuizQuestionChoice.where(question_id: self.id)
    html = "<label for=\""+self.id.to_s+"\">"+self.txt+"</label><br>"
    for i in 0..3
      txt = quiz_question_choices[i].txt
      html += "<input name = " + "\"#{self.id}[]\" "
      html += "id = " + "\"#{self.id}" + "_" + "#{i + 1}\" "
      html += "value = " + "\"#{quiz_question_choices[i].txt}\" "
      html += "type=\"checkbox\"/>"
      html += "#{i + 1}"
      html += "</br>"
    end
    html
  end

  def view_completed_question(user_answer)
    quiz_question_choices = QuizQuestionChoice.where(question_id: self.id)
    html = ''
    quiz_question_choices.each do |answer|
      if(answer.iscorrect)
          html += '<b>' + answer.txt + '</b> -- Correct <br>'
      end
    end
    html += '<br>Your answer is:'
    if user_answer[0].answer == 1
      html += '<img src="/assets/Check-icon.png"/><br>'
    else
      html += '<img src="/assets/delete_icon.png"/><br>'
    end
    user_answer.each do |answer|
      html += '<b>' + answer.comments.to_s + '</b><br>'
    end
    html += '<br><hr>'
    html.html_safe

  end

  def isvalid(choice_info)
    valid = "valid"
    if(self.txt == '')
      valid = "Please make sure all questions have text"
    end
    correct_count = 0
    choice_info.each do |idx, value|
      if value[:txt] == ''
        valid = "Please make sure every question has text for all options"
        break
      end
      if value[:iscorrect] == 1.to_s
        correct_count+=1
      end
    end
    if correct_count == 0  
      valid = "Please select a correct answer for all questions"
    elsif correct_count ==1
      valid = "A multiple-choice checkbox question should have more than one correct answer."
    end
    valid
  end
end
