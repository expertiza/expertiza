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
    @valid = super(choice_info)

    return 'Please make sure every question has text for all options' unless all_choices_have_text?(choice_info)

    correct_count = choice_info.count { |_idx, value| value.key?(:iscorrect) }

    if correct_count.zero?
      @valid = 'Please select a correct answer for all questions'
    elsif correct_count == 1
      @valid = 'A multiple-choice checkbox question should have more than one correct answer.'
    elsif correct_count == 2
      @valid = 'valid'
    end
    @valid
  end

  private
  
  def create_choices
    (0..3).each do |i|
      @html << create_choice_row(index)
    end
  end 

  def create_choice_row(index)
    checkbox_button = create_checkbox_input_field(index)
    text_field = create_text_input_field(index)
    "<tr><td>#{checkbox_button}#{text_field}</td></tr>"
  end

  def create_checkbox_input_field(index)
    checked = @quiz_question_choices[index].iscorrect ? 'checked="checked" ' : ''
    "<input type='hidden' name='quiz_question_choices[#{id}][MultipleChoiceCheckbox][#{i+1}][iscorrect]' "\
    "id='quiz_question_choices_#{id}_MultipleChoiceCheckbox_#{index+1}_iscorrect' value='0' /> "\
    "<input type='checkbox' name='quiz_question_choices[#{id}][MultipleChoiceCheckbox][#{i+1}][iscorrect]' "\
   "id='quiz_question_choices_#{id}_MultipleChoiceCheckbox_#{index+1}_iscorrect' value='1'#{checked}/>"
  end

  def create_text_input_field(index)
    "<input type='text' name='quiz_question_choices[#{id}][MultipleChoiceCheckbox][#{index+1}][txt]' "\
    "id='quiz_question_choices_#{id}_MultipleChoiceCheckbox_#{index+1}_txt' "\
    "value= '{@quiz_question_choices[#{index}].txt}' size='40' />"
  end

  def complete_choices
    (0..3).each do |i|
      @html << complete_choice_row(i)
    end
  end

  def complete_choice_row(index)
    # txt = quiz_question_choices[i].txt
    "<input name = '#{id}' id = '#{id}_#{index + 1}' value = '#{@quiz_question_choices[index].txt}' type='checkbox'/> "\
    "#{@quiz_question_choices[index].txt.to_s} </br>"
  end

  def view_correct_answers(choices)
    @html = ''
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
    if answer.iscorrect
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