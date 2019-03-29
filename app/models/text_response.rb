class TextResponse < Question
  validates :size, presence: true

  # This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(_count)
    content_tag(:tr,
                capture do
                  concat super(nil)
                  concat content_tag(:td, '<!--placeholder (TextRsponse does not need weight)-->', {}, false)
                  concat content_tag(:td, 'text area size <input size="6" value="' + self.size.to_s +
                          '" name="question[' + self.id.to_s + '][size]" id="question_' + self.id.to_s + '_size" type="text">', {}, false)
                end, {}, false)
  end

  def complete; end

  def view_completed_question; end
end
