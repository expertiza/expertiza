class TextArea < TextResponse
  def complete(count, answer=nil)
  	if self.size.nil?
      cols = '70'
      rows = '1'
    elsif 
      cols = self.size.split(',')[0]
      rows = self.size.split(',')[1]
    end
    html = '<li><p><label for="responses_' +count.to_s+ '">' +self.txt+ '</label></p>'
    html += '<input id="responses_' +count.to_s+ '_score" name="responses[' +count.to_s+ '][score]" type="hidden" value="">'
    html += '<p><textarea cols="' +cols+ '" rows="' +rows+ '" id="responses_' +count.to_s+ '_comments" name="responses[' +count.to_s+ '][comment]" >'
    html += answer.comments if !answer.nil?
    html += '</textarea>'
    html += '</p></li>'
    html.html_safe
  end

  def view_completed_question(count, answer)
    html = '<big><b>Question '+count.to_s+":</b> <i>"+self.txt+"</i></big><BR/>"
    html += '&nbsp;' * 8 + answer.comments.gsub('^p', '').gsub(/\n/, '<BR/>')+ '<BR/><BR/>'
    html.html_safe
  end 
end
