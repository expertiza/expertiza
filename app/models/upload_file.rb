class UploadFile < Question
  # This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(_count)
    html = '<tr>'
    html += '<td align="center"><a rel="nofollow" data-method="delete" href="/questions/' + self.id.to_s + '">Remove</a></td>'
    html += '<td><input size="6" value="' + self.seq.to_s + '" name="question[' + self.id.to_s + '][seq]" id="question_' + self.id.to_s + '_seq" type="text"></td>'
    html += '<td><textarea cols="50" rows="1" name="question[' + self.id.to_s + '][txt]" id="question_' + self.id.to_s + '_txt" placeholder="Edit question content here">' + self.txt + '</textarea></td>'
    html += '<td><input size="10" disabled="disabled" value="' + self.type + '" name="question[' + self.id.to_s + '][type]" id="question_' + self.id.to_s + '_type" type="text">''</td>'
    html += '<td><!--placeholder (UploadFile does not need weight)--></td>'
    html += '</tr>'

    html.html_safe
  end

  # This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    html = '<TR><TD align="left"> ' + self.txt + ' </TD>'
    html += '<TD align="left">' + self.type + '</TD>'
    html += '<td align="center">' + self.weight.to_s + '</TD>'
    html += '<TD align="center">&mdash;</TD>'
    html += '</TR>'
    html.html_safe
  end

  def complete(count, answer = nil)
    # Use "app/views/submitted_content/_submitted_files.html.erb" partial.
  end

  def view_completed_question(count, files)
    # Use "display_directory_tree" method in "app/helpers/submitted_content_helper.rb"
  end
end
