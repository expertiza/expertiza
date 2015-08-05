class TextArea < TextResponse
  def complete
  	''
  end

  def view_completed_question(count, answer)
    html = '<big><b>Question '+count.to_s+":</b> <I>"+self.txt+"</I></big><BR/>"
    html += '</p><dl><dd>' +answer.comments+ '</dd></dl>'
    html.html_safe
  end 
end
