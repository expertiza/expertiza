class ColumnHeader < QuestionnaireHeader
  def complete(_count, _answer = nil)
    html = '<tr>'
    html += '<th style="width: 15%">' + self.txt + '</th>'
    html.html_safe
  end

  def view_completed_question(_count, _answer)
    html = '<tr>'
    html += '<th style="width: 15%">' + self.txt + '</th>'
    html.html_safe
  end

  def build_form_data_string
    return %&{"type":"column-header","label":"#{self.txt.gsub('"', '\\\\\"')}","subtype":"h3"}&
  end
end
