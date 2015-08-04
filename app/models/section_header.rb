class SectionHeader < QuestionnaireHeader
  def view_completed_question(count, answer)
  	html = '<b style="color: #986633">' +self.txt+ '</b><br/>'
    html.html_safe 
  end
end