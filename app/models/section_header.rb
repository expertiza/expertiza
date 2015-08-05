class SectionHeader < QuestionnaireHeader
  def view_completed_question(count, answer)
  	html = '<b style="color: #986633; font-size: x-large">' +self.txt+ '</b><br/><br/>'
    html.html_safe 
  end
end