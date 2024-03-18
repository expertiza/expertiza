class TextArea < TextResponse
  def complete(count, answer = nil)
    if size.nil?
      cols = '70'
      rows = '1'
    else
      cols = size.split(',')[0]
      rows = size.split(',')[1]
    end
    html = '<p><label for="responses_' + count.to_s + '">' + txt + '</label></p>'
    html += '<input id="responses_' + count.to_s + '_score" name="responses[' + count.to_s + '][score]" type="hidden" value="">'
    html += '<p><textarea cols="' + cols + '" rows="' + rows + '" id="responses_' + count.to_s + '_comments" name="responses[' + count.to_s + '][comment]" class="tinymce">'
    html += answer.comments unless answer.nil?
    html += '</textarea>'
    html += '</p>'
    html.html_safe
  end

  def view_completed_question(count, answer)
    html = '<b>' + count.to_s + '. ' + txt + '</b><BR/>'
    html += '&nbsp;' * 8 + answer.comments.gsub('^p', '').gsub(/\n/, '<BR/>') + '<BR/><BR/>'
    html.html_safe
  end
end
