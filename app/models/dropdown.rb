class Dropdown < UnscoredQuestion
  validates_presence_of :alternatives
  
  def edit(count)
  	html ='<tr>'
    html+='<td align="center"><a rel="nofollow" data-method="delete" href="/questions/' +self.id.to_s+ '">Remove</a></td>'
    html+='<td><input size="6" value="'+self.seq.to_s+'" name="question['+self.id.to_s+'][seq]" id="question_'+self.id.to_s+'_seq" type="text"></td>'
    html+='<td><textarea cols="50" rows="1" name="question['+self.id.to_s+'][txt]" id="question_'+self.id.to_s+'_txt">'+self.txt+'</textarea></td>'
    html+='<td><input size="10" disabled="disabled" value="'+self.type+'" name="question['+self.id.to_s+'][type]" id="question_'+self.id.to_s+'_type" type="text">''</td>'
    html+='<td><!--placeholder (UnscoredQuestion does not need weight)--></td>'
    html+='<td> alternatives <input size="6" value="'+self.alternatives+'" name="question['+self.id.to_s+'][alternatives]" id="question_'+self.id.to_s+'_alternatives" type="text"></td>'
    html+='</tr>'

    html.html_safe
  end

  def view_question_text
    html = '<TR><TD align="left"> '+self.txt+' </TD>'
    html += '<TD align="left">'+self.type+'</TD>'
    html += '<td align="center">'+self.weight.to_s+'</TD>'
    html += '<TD align="center">&mdash;</TD>'
    html += '</TR>'
    html.html_safe
  end

  def complete(count, answer=nil)
    html = '<li><label for="responses_' +count.to_s+ '">' +self.txt+ '</label>'
  	alternatives = self.alternatives.split('|')
    html += '<input id="responses_' +count.to_s+ '_score" name="responses[' +count.to_s+ '][score]" type="hidden" value="">'
  	html += '<select id="responses_' +count.to_s+ '_comments" label=' +self.txt+ ' name="responses[' +count.to_s+ '][comment]">'
  	alternatives.each do |alternative|
  		html += '<option value="' +alternative.to_s+'"'
      html += ' selected' if !answer.nil? and answer.comments == alternative 
      html += '>' +alternative.to_s+ '</option>'
  	end
  	html += '</select></li>'
    html.html_safe
  end

  def view_completed_question(count, answer)
  	html = '<big><b>Question '+count.to_s+":</b> <I>"+self.txt+"</I></big>"
    html += answer.comments + '<BR/><BR/>'
    html.html_safe
  end
end
