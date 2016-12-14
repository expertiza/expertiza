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
    html = "<label for=\""+self.id.to_s+"\">"+self.txt+"</label><br>"
    for i in 0..1
      txt = quiz_question_choices[i].txt
      html += "<input name = " + "\"#{self.id}\" "
      html += "id = " + "\"#{self.id}" + "_" + "#{i + 1}\" "
      html += "value = " + "\"#{quiz_question_choices[i].txt}\" "
      html += "type=\"radio\"/>"
      if i == 0
        html += "True"
      else
        html += "False"
      end
      html += "</br>"
    end
    html
  end

  def view_completed_question(user_answer)
    quiz_question_choices = QuizQuestionChoice.where(question_id: self.id)
    html = ''
    html += 'Correct Answer is: <b>'
    if quiz_question_choices[0].iscorrect
      html+='True</b><br/>'
    else
      html+='False</b><br/>'
    end
    html += 'Your answer is: <b>' + user_answer.first.comments.to_s
    if user_answer.first.answer==1
      html += '<img src="/assets/Check-icon.png"/>'
    else
      html += '<img src="/assets/delete_icon.png"/>'
    end

    html +='</b>'
    html += '<br><br><hr>'
    html.html_safe
    #html += 'i += 1'
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
    end
    valid
  end
end
