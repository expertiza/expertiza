class QuizQuestion < Question
  has_many :quiz_question_choices, class_name: 'QuizQuestionChoice', foreign_key: 'question_id', inverse_of: false, dependent: :nullify
  def edit
    @quiz_question_choices = QuizQuestionChoice.where(question_id: id)

    @html = '<tr><td>'
    @html += '<textarea cols="100" name="question[' + id.to_s + '][txt]" '
    @html += 'id="question_' + id.to_s + '_txt">' + txt + '</textarea>'
    @html += '</td></tr>'

    @html += '<tr><td>'
    @html += 'Question Weight: '
    @html += '<input type="number" name="question_weights[' + id.to_s + '][txt]" '
    @html += 'id="question_wt_' + id.to_s + '_txt" '
    @html += 'value="' + weight.to_s + '" min="0" />'
    @html += '</td></tr>'

  end

  def complete
    @quiz_question_choices = QuizQuestionChoice.where(question_id: id)
    @html = '<label for="' + id.to_s + '">' + txt + '</label><br>'

  end

  def view_question_text
    @html = '<b>' + txt + '</b><br />'
    @html += 'Question Type: ' + type + '<br />'
    @html += 'Question Weight: ' + weight.to_s + '<br />'
    if quiz_question_choices
      quiz_question_choices.each do |choices|
        @html += if choices.iscorrect?
                  '  - <b>' + choices.txt + '</b><br /> '
                else
                  '  - ' + choices.txt + '<br /> '
                end
      end
      @html += '<br />'
    end
    @html.html_safe
  end

  def view_completed_question; end
  def isvalid(choice_info)
    @valid = 'valid'
    @valid = 'Please make sure all questions have text' if txt == ''
  end

end
