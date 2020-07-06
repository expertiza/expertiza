class QuestionnaireHeader < Question
  # This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(_count)
    content_tag(:tr,
                capture do
                  concat super(nil)
                  concat content_tag(:td, '<!--placeholder (UploadFile does not need weight)-->', {}, false)
                end, {}, false)
  end

  def complete
    self.txt
  end

  def view_completed_question; end
end
