class QuestionnaireHeader < Question
  include ActionView::Helpers

  # This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(_count)
    # html = '<tr>'
    # html += '<td align="center"><a rel="nofollow" data-method="delete" href="/questions/' + self.id.to_s + '">Remove</a></td>'
    # html += '<td><input size="6" value="' + self.seq.to_s + '" name="question[' + self.id.to_s + '][seq]" id="question_' +
    #     self.id.to_s + '_seq" type="text"></td>'
    # html += '<td><textarea cols="50" rows="1" name="question[' + self.id.to_s + '][txt]" id="question_' + self.id.to_s +
    #     '_txt" placeholder="Edit question content here">' + self.txt + '</textarea></td>'
    # html += '<td><input size="10" disabled="disabled" value="' + self.type +
    #     '" name="question[' + self.id.to_s + '][type]" id="question_' + self.id.to_s + '_type" type="text"></td>'
    # html += '<td><!--placeholder (UploadFile does not need weight)--></td>'
    # html += '</tr>'
    #
    # html.html_safe
    content_tag(:tr,
                capture do
                  super(_count)
                  content_tag(:td, '<!--placeholder (UploadFile does not need weight)-->', {}, false)
                end, {}, false)
  end

  def complete
    self.txt
  end

  def view_completed_question; end
end
