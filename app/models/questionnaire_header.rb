class QuestionnaireHeader < Question
	#This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(count)
    html = edit_prefix(self, html)
    html+='<td><!--placeholder (QuestionnaireHeader does not need weight)--></td>'
    html+='</tr>'

    html.html_safe
  end

  #This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    html = view_qt_prefix(ob, html)
    html += '<TD align="center">&mdash;</TD>'
    html += '</TR>'
    html.html_safe
  end

  def complete
    self.txt
  end

  def view_completed_question
  end
end
