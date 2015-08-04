class TextField < TextResponse
  def complete
  	''
  end

  def view_completed_question(count, answer)
    html = '<i><label for="response_' +count.to_s+ '">' +self.txt+ '</label></i>'
    html += answer.comments.to_s
    html.html_safe
  end
end
