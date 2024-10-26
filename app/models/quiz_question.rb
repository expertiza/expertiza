class QuizQuestion < Question
  has_many :quiz_item_choices, class_name: 'QuizQuestionChoice', foreign_key: 'item_id', inverse_of: false, dependent: :nullify
  def edit; end

  def view_item_text
    html = '<b>' + txt + '</b><br />'
    html += 'Question Type: ' + type + '<br />'
    html += 'Question Weight: ' + weight.to_s + '<br />'
    if quiz_item_choices
      quiz_item_choices.each do |choices|
        html += if choices.iscorrect?
                  '  - <b>' + choices.txt + '</b><br /> '
                else
                  '  - ' + choices.txt + '<br /> '
                end
      end
      html += '<br />'
    end
    html.html_safe
  end

  def complete; end

  def view_completed_item; end
end
