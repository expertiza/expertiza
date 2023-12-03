class QuizQuestion < Question
  has_many :quiz_question_choices, class_name: "QuizQuestionChoice", foreign_key: "question_id", inverse_of: false, dependent: :nullify

  def edit
    @quiz_question_choices = QuizQuestionChoice.where(question_id: id)
    @html = create_html_content
  end

  def complete
    @quiz_question_choices = QuizQuestionChoice.where(question_id: id)
    @html = create_label
  end

  def view_question_text
    @html = "<b>#{txt}</b><br />"
    @html << "Question Type: " + type + "<br />"
    @html << "Question Weight: " + weight.to_s + "<br />"
    @html << create_choices if quiz_question_choices.present?
    @html.html_safe
  end

  def view_completed_question; end

  def isvalid(choice_info)
    @valid = "valid"
    @valid = "Please make sure all questions have text" if txt == ""
    @valid
  end

  private

  def create_html_content
    html_content = ""
    html_content << create_textarea_row
    html_content << create_weight_input_row
    html_content
  end

  def create_textarea_row
    "<tr><td><textarea cols='100' name='question[#{id}][txt]' id='question_#{id}_txt'>#{txt}</textarea></td></tr>"
  end

  def create_weight_input_row
    "<tr><td>Question Weight: <input type='number' name='question_weights[#{id}][txt]' id='question_wt_#{id}_txt' value='#{weight}' min='0' /></td></tr>"
  end

  def create_label
    "<label for='#{id}'>#{txt}</label><br />"
  end

  def create_choices
    choices_html = ""
    quiz_question_choices.each do |choice|
      choices_html << choice_html(choice)
    end
    choices_html << "<br />"
    choices_html
  end

  def choice_html(choice)
    if choice.iscorrect?
      "  - <b>#{choice.txt}</b><br /> "
    else
      "  - #{choice.txt}<br /> "
    end
  end

  def all_choices_have_text?(choice_info)
    choice_info.all? { |_idx, value| value[:txt].present? }
  end
end
