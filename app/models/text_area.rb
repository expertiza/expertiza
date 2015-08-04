class TextArea < TextResponse
  def complete
  	''
  end

  def view_completed_question(count, answer)
    html = '<li><p><i>'
    html += '<label for="response_' +count.to_s+ '">' +self.txt+ '</label></i>'
    html += '</p><dl><dd>' +answer.comments+ '</dd></dl></li>'
    html.html_safe
  end 
end
