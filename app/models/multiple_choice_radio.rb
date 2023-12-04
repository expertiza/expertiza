class MultipleChoiceRadio < QuizQuestion

  #editing multiple-choice radio question in quiz
  def edit
    super
    create_choices
    @html.html_safe
  end

  #completing multiple-choice radio in quiz
  def complete
    super
    complete_choices
    @html
  end

  def view_completed_question(user_answer)
    @quiz_question_choices = QuizQuestionChoice.where(question_id: id)
    view_correct_answer(@quiz_question_choices)
    view_your_answer(user_answer)
    @html.html_safe
  end

  def isvalid(choice_info)
    @valid = super(choice_info)

    return "Please make sure every question has text for all options" unless all_choices_have_text?(choice_info)

    #counts the number of choices that are correct
    correct_count = choice_info.count { |_idx, value| value[:iscorrect] == 1 || value[:iscorrect] == "1" }

    return "Please select a correct answer for all questions" if correct_count.zero?

    @valid
  end

  private

  def create_choices
    (0..3).each do |index|
      @html << create_choice_row(index)
    end
  end

  def create_choice_row(index)
    radio_button = create_radio_input_field(index)
    text_field = create_text_input_field(index)
    "<tr><td>#{radio_button}#{text_field}</td></tr>"
  end

  def create_radio_input_field(index)
    checked = @quiz_question_choices[index].iscorrect ? 'checked="checked" ' : ""
    "<input type='radio' name='quiz_question_choices[#{id}][MultipleChoiceRadio][correctindex]' " \
    "id='quiz_question_choices_#{id}_MultipleChoiceRadio_correctindex_#{index + 1}'" \
    "value='#{index + 1}' #{checked}/>"
  end

  def create_text_input_field(index)
    "<input type='text' name='quiz_question_choices[#{id}][MultipleChoiceRadio][#{index + 1}][txt]' " \
    "id='quiz_question_choices_#{id}_MultipleChoiceRadio_#{index + 1}_txt' " \
    "value='@quiz_question_choices[#{index}].txt' size='40' />"
  end

  def complete_choices
    (0..3).each do |i|
      @html << complete_choice_row(i)
    end
  end

  def complete_choice_row(index)
    "<input name = '#{id}' id = '#{id}_#{index + 1}' value = '#{@quiz_question_choices[index].txt}' type='radio'/>" \
    "#{@quiz_question_choices[index].txt.to_s} </br>"
  end

  def view_correct_answer(choices)
    @html = ""
    choices.each do |answer|
      @html << is_correct_answer_text(answer)
    end
  end

  def view_your_answer(user_answer)
    @html << "<br>Your answer is: <b> #{user_answer.first.comments.to_s}"
    @html << is_correct_answer_icon(user_answer)
    @html << " </b><br><br><hr>"
  end

  def is_correct_answer_icon(user_answer)
    if user_answer.first.answer == 1
      '<img src="/assets/Check-icon.png"/>'
    else
      '<img src="/assets/delete_icon.png"/>'
    end
  end

  def is_correct_answer_text(answer)
    if answer.iscorrect == 1 || answer.iscorrect == "1"
      "<b> #{answer.txt} </b> -- Correct <br>"
    else
      "#{answer.txt} <br>"
    end
  end
end
