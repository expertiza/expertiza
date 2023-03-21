class ColumnHeader < QuestionnaireHeader
  def complete(_count, _answer = nil)
    html = '<tr>'
    html += '<th style="width: 15%">' + txt + '</th>'
    html.html_safe
  end

  def view_completed_question(_count, _answer)
    html = '<tr>'
    html += '<th style="width: 15%">' + txt + '</th>'
    html.html_safe
  end
end
