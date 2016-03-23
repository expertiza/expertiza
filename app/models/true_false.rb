class TrueFalse < QuizQuestion
  include ActionView::Helpers::FormHelper

  def edit(count)
    @question = self
    questionnum = @question.id

    html = ""

    #QuizQuestion needs to do some generic stuff before and after,
    #so we call it with a block.
    super(count) do |common_html|
      html += common_html

      #@quiz_question_choices = QuizQuestionChoice.where(question_id: @question.id)
      @quiz_question_choices = @question.quiz_question_choices

      for @quiz_question_choice in @quiz_question_choices
        html += "<tr><td>&nbsp;&nbsp;&nbsp;"

        if @quiz_question_choice.txt == "True"
          html += radio_button_tag("quiz_question_choices[#{questionnum}][TrueFalse][1][iscorrect]", 'True', @quiz_question_choice.iscorrect) + "   True"
        end

        if @quiz_question_choice.txt == "False"
          html += radio_button_tag("quiz_question_choices[#{questionnum}][TrueFalse][1][iscorrect]", 'False', @quiz_question_choice.iscorrect) + "   False"
        end

        html += "</td></tr>"
      end
    end

    html.html_safe
  end

  def complete(count, answer=nil)
    @question = self
    html = ""
    html += label_tag("#{question.id}", question.txt) +"<br>"

    quiz_question_choices = QuizQuestionChoice.where(question_id: @question.id)
    quiz_question_choices.each do |choice|
      if answer=="view"
        html += check_box_tag("#{@question.id}", "#{choice.txt}", choice.iscorrect)
        html += label_tag("#{@question.id}_"+choice.txt, choice.txt)
        html += "<br>"
      end

      if answer=="take"
        html += radio_button_tag("#{@question.id}", "#{choice.txt}")
        html += label_tag("#{@question.id}_"+choice.txt, choice.txt)
        html += "<br>"
      end
    end
    html += "<br>"
    html.html_safe
  end

  def view_completed_question(count, answer)
    @question = self

    html=""
    html+= "Correct Answer is: <b>"
    html+= QuizQuestionChoice.where(question_id: @question.id,iscorrect: 1).first.txt
    html+= "</b><br/>"
    html+= "Your answer is: <b>"
    html+= answer.first.coments + "</b>"
    if(answer.first.answer == 1)
      html+= "<img src=/assets/Check-icon.png/>"
    else
      html+= "<img src=/assets/delete_icon.png/>"
    end
    html+= "<br><br>"
  end
  
end
