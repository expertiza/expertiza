class MultipleChoiceCheckbox < QuizQuestion
  include ActionView::Helpers::FormHelper

  def edit(count)

  end

  def complete(count, answer=nil)
    @question = self
    html = ""
    html += label_tag("#{question.id}", question.txt) +"<br>"

    quiz_question_choices = QuizQuestionChoice.where(question_id: @question.id)
    quiz_question_choices.each do |choice|
      if answer=="view"
        html += check_box_tag ("#{question.id}[]", "#{choice.txt}", choice.iscorrect)
        html += label_tag("#{choice.txt}", choice.txt)
        html += "<br>"
      end
      if answer=="take"
        html += check_box_tag ("#{question.id}[]", "#{choice.txt}")
        html += label_tag("#{choice.txt}", choice.txt)
        html += "<br>"
      end
      html.html_safe
    end
  end

  def view_completed_question(count, answer)
    @question = self

    html=""
    html+= "<br>"
    QuizQuestionChoice.where(question_id: @question.id).each do |q_answer|
      if q_answer.iscorrect
        html+= "<b>" + q_answer.txt + "</b> -- Correct <br>"
      end
    end
    html+= "<br>"

    html+= "Your answer is:"
    if answer.first.answer==1
      html+= "<img src=/assets/Check-icon.png/>"
    else
      html+= "<img src=/assets/delete_icon.png/>"
    end
    html+="<br/>"
    answer.each do |a_answer|
      html+= "<b>"+ a_answer.comments + "<b><br>"
    end
    html+= "<br>"
  end
end