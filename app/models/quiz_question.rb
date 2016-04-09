class QuizQuestion < Question
  has_many :quiz_question_choices, :class_name => 'QuizQuestionChoice', :foreign_key => 'question_id'
  belongs_to :quiz_questionnaire, class_name: 'QuizQuestionnaire', foreign_key: :questionnaire_id
  validates_presence_of :txt, message: 'Please make sure all questions have text'
  validate :has_correct_choice

  # Verify that the question has one choice that is considered correct.
  def has_correct_choice
    if !quiz_question_choices.any? { |choice| choice.iscorrect }
      errors.add :correct_choice, 'Please select a correct answer for all questions'
    end
  end

  def edit
  end

  def view_question_text
    html = "<b>" + self.txt + '</b><br />'
    html += "Question Type: " + self.type + '<br />'
    if self.quiz_question_choices
      self.quiz_question_choices.each do |choices|
        if choices.iscorrect?
          html += "  - <b>"+choices.txt+"</b><br /> "
        else
          html += "  - "+choices.txt+"<br /> "
        end
      end
      html += '<br />'
    end
    html.html_safe
  end

  def complete
  end

  def view_completed_question
  end

end
