class ColumnHeader < QuestionnaireHeader
  def complete(count, answer=nil)
  	html = '<b style="color: #986633; font-size: x-large">' +self.txt+ '</b><br/><br/>'
    html.html_safe
  end
  def view_completed_question(count, answer)
  	html = '<tr>'
  	html += '<th style="width: 15%">' +self.txt+ '</th>'
    html.html_safe 
  end
end