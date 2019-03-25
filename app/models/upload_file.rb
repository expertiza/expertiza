class UploadFile < Question
  include ActionView::Helpers

  # This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit
    content_tag(:tr,
                capture do
                  super(nil)
                  content_tag(:td, '<!--placeholder (UploadFile does not need weight)-->', {}, false)
                end, {}, false)
  end

  def complete(count, answer = nil)
    # Use "app/views/submitted_content/_submitted_files.html.erb" partial.
  end

  def view_completed_question(count, files)
    # Use "display_directory_tree" method in "app/helpers/submitted_content_helper.rb"
  end
end
