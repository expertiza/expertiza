class MultipleChoiceRadio < QuizQuestion
  def edit(count)
  end

  def complete(count, answer = nil)
  end


  def view_completed_question(user_answer)
    quiz_question_choices = QuizQuestionChoice.where(question_id: self.id)

    html = ''
    quiz_question_choices.each do |answer|
      if(answer.iscorrect)
        html += '<b>' + answer.txt + '</b> -- Correct <br>'
      else
        html +=  answer.txt + '<br>'
      end
    end


    html += '<br>Your answer is: '
    html += '<b>' + user_answer.first.comments.to_s + '</b>'
    if user_answer.first.answer==1
      html += '<img src="/assets/Check-icon.png"/>'
    else
      html += '<img src="/assets/delete_icon.png"/>'
    end
    html +='</b>'
    html += '<br><br><hr>'
    html.html_safe

  end
end
