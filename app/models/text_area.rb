class TextArea < TextResponse
  include ActionView::Helpers

  def complete(count, answer = nil)
    cols, rows = complete_get_cols_rows

    html = '<p><label for="responses_' + count.to_s + '">' + self.txt + '</label></p>'
    html += '<input id="responses_' + count.to_s + '_score" name="responses[' + count.to_s + '][score]" type="hidden" value="">'

    html += '<p><textarea cols="' + cols + '" rows="' + rows
    html += '" id="responses_' + count.to_s + '_comments" name="responses[' + count.to_s + '][comment]" >'

    html += answer.comments unless answer.nil?
    html += '</textarea></p>'
    safe_join(["<li>".html_safe, "</li>".html_safe], html.html_safe)
  end

  def complete_get_cols_rows
    return '70', '1' if self.size.nil?
    [self.size.split(',')[0], self.size.split(',')[1]]
  end

  def view_completed_question(count, answer)
    html = '<b>' + count.to_s + ". " + self.txt + "</b><BR/>"
    html += '&nbsp;' * 8 + completed_question_data(answer) + '<BR/><BR/>'

    safe_join(["".html_safe, "".html_safe], html.html_safe)
  end

  def completed_question_data(answer)
    answer.comments.gsub('^p', '').gsub(/\n/, '<BR/>')
  end
end
