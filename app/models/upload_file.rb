class UploadFile < Question
  #This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(count)
    html = edit_prefix(self, html)
    html+='<td><!--placeholder (UploadFile does not need weight)--></td>'
    html+='</tr>'

    html.html_safe
  end

  #This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    html = view_qt_prefix(self, html)
    html += '<TD align="center">&mdash;</TD>'
    html += '</TR>'
    html.html_safe
  end

  def complete(count, answer=nil)
    #Use "app/views/submitted_content/_submitted_files.html.erb" partial.
  end
  def view_completed_question(count, files)
  	#Use "display_directory_tree" method in "app/helpers/submitted_content_helper.rb"
  end
end
