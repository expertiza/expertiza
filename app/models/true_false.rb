class TrueFalse < QuizQuestion
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

  def view_completed_question(user_answer)
    @quiz_question_choices = QuizQuestionChoice.where(question_id: id)
    view_correct_answer(@quiz_question_choices)
    view_your_answer(user_answer)
    @html.html_safe
  end

  def isvalid(choice_info)
    @valid = super(choice_info)

    return 'Please make sure every question has text for all options' unless all_choices_have_text?(choice_info)

    #counts the number of choices that are correct
    correct_count = choice_info.count { |_idx, value| value.key?(:iscorrect) }

    return 'Please select a correct answer for all questions' if correct_count.zero?

    @valid
  end

  private
  def create_choices
    @html << create_choice_row(0, 'True')
    @html << create_choice_row(1, 'False')
  end

  def create_choice_row(index, true_false)
    radio_button = create_radio_input_field(index, true_false)
    "<tr><td>#{radio_button}</td></tr>"
  end

  def create_radio_input_field(index, true_false)
    checked = @quiz_question_choices[index].iscorrect ? 'checked="checked" ' : ''
    "<input type='radio' name='quiz_question_choices[#{id}][TrueFalse][1][iscorrect]' "\
    "id='quiz_question_choices_#{id}_TrueFalse_1_iscorrect_True' value='True' #{checked} /> #{true_false}"
  end

  def complete_choices
    (0..1).each do |i|
      @html << complete_choice_row(i)
    end
  end

  def complete_choice_row(i)
    true_false = i == 0 ? 'True' : 'False'
    "<input name = '#{id}' id = '#{id}_#{i + 1}' value = '#{@quiz_question_choices[i].txt} type='radio'/> #{true_false} </br>"
  end

  def view_correct_answer(choices)
    @html = ''
    @html << 'Correct Answer is: <b>'
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
    if @quiz_question_choices[0].iscorrect
      "True"
    else
      "False"
    end
    "</b><br/>"
  end
end
