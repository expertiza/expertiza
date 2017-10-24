class TextField < TextResponse
  def complete(count, answer = nil)
    html = if self.type == 'TextField' and self.break_before == true
             '<li>'
           else
             ''
           end
    html += '<label for="responses_' + count.to_s + '">' + self.txt + '</label>'
    html += '<input id="responses_' + count.to_s + '_score" name="responses[' + count.to_s + '][score]" type="hidden" value="">'
    html += '<input id="responses_' + count.to_s + '_comments" label=' + self.txt + ' name="responses[' + count.to_s + '][comment]" size=' + self.size.to_s + ' type="text"'
    html += 'value="' + answer.comments unless answer.nil?
    html += '">'
    html += '</li><BR/><BR/>' if self.type == 'TextField' and self.break_before == false
    html.html_safe
  end

  def view_completed_question(count, answer)
    if self.type == 'TextField' and self.break_before == true
      html = '<b>' + count.to_s + ". " + self.txt + "</b>"
      html += '&nbsp;&nbsp;&nbsp;&nbsp;'
      html += answer.comments
      html += '<BR/><BR/>' if Question.exists?(answer.question_id + 1) && Question.find(answer.question_id + 1).break_before == true
    else
      html = self.txt
      html += answer.comments
      html += '<BR/><BR/>'
    end
    html.html_safe
  end
end
