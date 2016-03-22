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

  end

  def view_completed_question(count, answer)

  end
end
