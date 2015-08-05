class TextField < TextResponse
  def complete
  	''
  end

  def view_completed_question(count, answer)
    if self.break_before == true
      html = '<big><b>Question '+count.to_s+":</b> <I>"+self.txt+"</I></big>"
      html += '&nbsp;&nbsp;&nbsp;&nbsp;'
      html += answer.comments
    else
      html = self.txt
      html += answer.comments 
      html += '<BR/><BR/>'
    end
    html.html_safe
  end
end
