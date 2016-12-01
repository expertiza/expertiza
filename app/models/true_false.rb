class TrueFalse < QuizQuestion
  def edit(count)
  end

  def complete
    quiz_question_choices = QuizQuestionChoice.where(question_id: self.id)
    html = ""
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
end
