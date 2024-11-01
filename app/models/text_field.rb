class TextField < TextResponse
  def complete(count, answer = nil)
    html = '<p style="width: 80%;">'
    html += '<label for="responses_' + count.to_s + '" >' + txt + '&nbsp;&nbsp;</label>'
    html += '<input id="responses_' + count.to_s + '_score" name="responses[' + count.to_s + '][score]" type="hidden" value="" ">'
    html += '<input id="responses_' + count.to_s + '_comments" label=' + txt + ' name="responses[' + count.to_s + '][comment]" style="width: 40%;" size=' + size.to_s + ' type="text"'
    html += 'value="' + answer.comments.to_s unless answer.nil?
    html += '">'
    html += '<BR/><BR/>' if (type == 'TextField') && (break_before == false)
    html.html_safe
  end

  def view_completed_question(count, answer)
    if (type == 'TextField') && (break_before == true)
      html = '<b>' + count.to_s + '. ' + txt + '</b>'
      html += '&nbsp;&nbsp;&nbsp;&nbsp;'
      html += answer.comments.to_s
      html += '<BR/><BR/>' if Question.exists?(answer.question_id + 1) && Question.find(answer.question_id + 1).break_before == true
    else
      html = txt
      html += answer.comments
      html += '<BR/><BR/>'
    end
    html.html_safe
  end
end
