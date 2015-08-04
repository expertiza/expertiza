class Checkbox < UnscoredQuestion
  def edit
    ''
  end

  #This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    html = '<TR><TD align="left"> '+self.txt+' </TD>'
    html += '<TD align="left">'+self.type+'</TD>'
    html += '<td align="center">'+self.weight.to_s+'</TD>'
    html += '<TD align="center">True/False</TD>'
    html += '</TR>'
    html.html_safe
  end

  def complete
    ''
  end

  #This method returns what to display if a student is viewing a filled-out questionnaire
  def view_completed_question(count, answer)
    if answer.answer == 1
      html = '<li><p><img src="/images/Check-icon.png">' +self.txt+ '<br></p></li>'
    else
      html = '<li><p><img src="/images/delete-icon.png">' +self.txt+ '<br></p></li>'
    end
    html.html_safe
  end

  def self.checked?(response_id)
    answer = Answer.where(question_id: self.id, response_id: response_id).first
    return answer.comment == '0'
  end
end
