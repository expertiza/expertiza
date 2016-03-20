class MultipleChoiceCheckbox < QuizQuestion
  include ActionView::Helpers::FormHelper

  def edit(count)
    @question = self
    questionnum = @question.id

    html = ""

    #QuizQuestion needs to do some generic stuff before,
    #so we call it with a block.
    super(count) do |common_html|
      html += common_html

      #@quiz_question_choices = QuizQuestionChoice.where(question_id: @question.id)
      @quiz_question_choices = @question.quiz_question_choices

      i = 1
      for @quiz_question_choice in @quiz_question_choices
        html += "<tr><td>&nbsp;&nbsp;&nbsp;"

        html += hidden_field_tag("quiz_question_choices[#{questionnum}][MultipleChoiceCheckbox][#{i}][iscorrect]",'0')
        html += check_box_tag("quiz_question_choices[#{questionnum}][MultipleChoiceCheckbox][#{i}][iscorrect]",'1', @quiz_question_choice.iscorrect)
        html += "&nbsp;" + text_field_tag("quiz_question_choices[#{questionnum}][MultipleChoiceCheckbox][#{i}][txt]", @quiz_question_choice.txt, :size=>40)

        html += "</td></tr>"

        i += 1
      end
    end

    html.html_safe
  end

  def complete(count, answer=nil)

  end

  def view_completed_question(count, answer)

  end
end
