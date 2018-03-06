class QuizQuestion < Question
  attr_accessible :id, :txt, :weight, :questionnaire_id, :seq, :size,
                  :alternatives, :break_before, :max_label, :min_label, :questionnaire, :type

  has_many :quiz_question_choices, class_name: 'QuizQuestionChoice', foreign_key: 'question_id'
  def edit; end

  def view_question_text
    html = "<b>" + self.txt + '</b><br />'
    html += "Question Type: " + self.type + '<br />'
    if self.quiz_question_choices
      self.quiz_question_choices.each do |choices|
        html += if choices.iscorrect?
                  "  - <b>" + choices.txt + "</b><br /> "
                else
                  "  - " + choices.txt + "<br /> "
                end
      end
      html += '<br />'
    end
    html.html_safe
  end

  def complete; end

  def view_completed_question; end
end
