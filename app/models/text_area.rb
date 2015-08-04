class TextArea < TextResponse
  def edit
  	''
  end

  #This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    html = '<TR><TD align="left"> '+self.txt+' </TD>'
    html += '<TD align="left">'+self.type+'</TD>'
    html += '<td align="center">'+self.weight.to_s+'</TD>'
    html += '<TD align="center">-</TD>'
    html += '</TR>'
    html.html_safe
  end

  def complete
  	''
  end

  def view_completed_question(response_id)
  	''
  end 
end
