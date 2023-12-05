class MultipleChoiceCheckbox < QuizQuestion
  def edit
    super
    create_choices
    @html.html_safe
  end

  def complete
    super
    complete_choices
    @html
  end

  def view_completed_question(user_answers)
    quiz_question_choices = QuizQuestionChoice.where(question_id: id)
    view_correct_answers(@quiz_question_choices)
    view_your_answers(user_answers)
    @html.html_safe
  end

  def isvalid(choice_info)
    @validity_message = super(choice_info)

    return @validity_message if @validity_message != "valid"

    return "Please make sure every question has text for all options" unless all_choices_have_text?(choice_info)

    correct_count = choice_info.count { |_idx, value| value[:iscorrect] == 1 }

    if correct_count.zero?
      @validity_message = "Please select a correct answer for all questions"
    elsif correct_count == 1
      @validity_message = "A multiple-choice checkbox question should have more than one correct answer."
    elsif correct_count == 2
      @validity_message = "valid"
    end
    @validity_message
  end

  private

  def create_choices
    (0..3).each do |i|
      @html << create_choice_row(i)
    end
  end

  def create_choice_row(i)
    checkbox_button = create_checkbox_input_field(i)
    text_field = create_text_input_field(i)
    "<tr><td>#{checkbox_button}#{text_field}</td></tr>"
  end

  def create_checkbox_input_field(i)
    checked = @quiz_question_choices[i].iscorrect ? 'checked="checked" ' : ""
    "<input type='hidden' name='quiz_question_choices[#{id}][MultipleChoiceCheckbox][#{i + 1}][iscorrect]' " \
    "id='quiz_question_choices_#{id}_MultipleChoiceCheckbox_#{i + 1}_iscorrect' value='0' /> " \
    "<input type='checkbox' name='quiz_question_choices[#{id}][MultipleChoiceCheckbox][#{i + 1}][iscorrect]' " \
    "id='quiz_question_choices_#{id}_MultipleChoiceCheckbox_#{i + 1}_iscorrect' value='1'#{checked}/>"
  end

  def create_text_input_field(i)
    "<input type='text' name='quiz_question_choices[#{id}][MultipleChoiceCheckbox][#{i + 1}][txt]' " \
    "id='quiz_question_choices_#{id}_MultipleChoiceCheckbox_#{i + 1}_txt' " \
    "value= '#{@quiz_question_choices[i].txt}' size='40' />"
  end

  def complete_choices
    (0..3).each do |i|
      @html << complete_choice_row(i)
    end
  end

  def complete_choice_row(i)
    # txt = quiz_question_choices[i].txt
    "<input name = '#{id}' id = '#{id}_#{i + 1}' value = '#{@quiz_question_choices[i].txt}' type='checkbox'/> " \
    "#{@quiz_question_choices[i].txt.to_s} </br>"
  end

  def view_correct_answers(choices)
    @html = ""
    choices.each do |answer|
      @html << is_correct_answer_text(answer)
    end
  end

  def view_your_answers(user_answers)
    @html << "<br>Your answer is: #{is_correct_answer_icon(user_answers)}"
    user_answers.each do |answer|
      @html << "<b> #{answer.comments} </b> <br>"
    end
    @html << "<br><hr>"
  end

  def is_correct_answer_icon(user_answers)
    if user_answers.first.answer == 1
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

  # #checks if each choice has text
  # def all_choices_have_text?(choice_info)
  #   choice_info.all? { |_idx, value|  value[:txt].present? }
  # end
end
