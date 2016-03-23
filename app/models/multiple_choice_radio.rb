class MultipleChoiceRadio < QuizQuestion
  include ActionView::Helpers::FormHelper

  def edit(count)

  end

  def complete(count, answer=nil)
    @question = self
    html = ""
    html += label_tag("#{@question.id}", @question.txt)
    html +=  "</br>"

    quiz_question_choices = QuizQuestionChoice.where(question_id: @question.id)
    quiz_question_choices.each do |choice|
      if display=="view"
        html += radio_button_tag("#{@question.id}", "#{choice.txt}", choice.iscorrect)
        html += label_tag("#{choice.id}", choice.txt) + "<br>"
      end
      if display=="take"
        html += radio_button_tag("#{@question.id}", "#{choice.txt}")
        html += label_tag("#{choice.id}", choice.txt) + "<br>"
      end
    end
    html += "</br>"
    html.html_safe
  end


  def view_completed_question(count, answer)
    @question = self

    html = ""
    html += "</br>"
    QuizQuestionChoice.where(question_id: @question.id).each do |q_answer|
      if q_answer.iscorrect
        html += "<b>" + q_answer.txt + "</b> -- Correct </br>"
      else
        html+= q_answer.txt + "</br>"
      end
    end
    html+= "<br>"

    html+= "Your answer is: <b>" + answer.first.comments + "</b>"
    if answer.first.answer==1
      html+= "<img src=/assets/Check-icon.png/>"
    else
      html+= "<img src=/assets/delete_icon.png/>"
    end
    html+= "<br>"
    html.html_safe
  end
end