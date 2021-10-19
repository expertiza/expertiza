class Dropdown < UnscoredQuestion
  include ActionView::Helpers
  validates :alternatives, presence: true

  def edit(_count)
    html = '<td align="center"><a rel="nofollow" data-method="delete" href="/questions/' + self.id.to_s + '">Remove</a></td>'

    html += '<td><input size="6" value="' + self.seq.to_s
    html += '" name="question[' + self.id.to_s + '][seq]" id="question_' + self.id.to_s + '_seq" type="text"></td>'

    html += '<td><textarea cols="50" rows="1" name="question[' + self.id.to_s + '][txt]"'
    html += ' id="question_' + self.id.to_s + '_txt" placeholder="Edit question content here">' + self.txt + '</textarea></td>'

    html += '<td><input size="10" disabled="disabled" value="' + self.type
    html += '" name="question[' + self.id.to_s + '][type]" id="question_' + self.id.to_s + '_type" type="text"></td>'

    html += '<td><!--placeholder (UnscoredQuestion does not need weight)--></td>'
    html += '<td> alternatives <input size="8" value="' + self.alternatives
    html += '" name="question[' + self.id.to_s + '][alternatives]" id="question_' + self.id.to_s + '_alternatives" type="text"></td>'

    safe_join(["<tr>".html_safe, "</tr>".html_safe], html.html_safe)
  end

  def view_question_text
    html = '<TD align="left"> ' + self.txt + ' </TD>'
    html += '<TD align="left">' + self.type + '</TD>'
    html += '<td align="center">' + self.weight.to_s + '</TD><TD align="center">&mdash;</TD>'

    safe_join(["<TR>".html_safe, "</TR>".html_safe], html.html_safe)
  end

  def complete(count, answer = nil)
    html = '<p style="width: 80%;"><label for="responses_' + count.to_s + '"">' + self.txt + '&nbsp;&nbsp;</label>'
    html += '<input id="responses_' + count.to_s + '_score" name="responses[' + count.to_s + '][score]" type="hidden" value="" style="min-width: 100px;">'
    html += '<select id="responses_' + count.to_s + '_comments" label=' + self.txt + ' name="responses[' + count.to_s + '][comment]">'

    alternatives = self.alternatives.split('|')
    html += complete_for_alternatives(alternatives, answer)
    html += '</select></p>'
    html.html_safe
  end

  def complete_for_alternatives(alternatives, answer)
    html = ''
    alternatives.each do |alternative|
      html += '<option value="' + alternative.to_s + '"'
      html += ' selected' if !answer.nil? and answer.comments == alternative
      html += '>' + alternative.to_s + '</option>'
    end
    html
  end

  def view_completed_question(count, answer)
    html = '<b>' + count.to_s + ". " + self.txt + "</b>"
    html += '<BR>&nbsp&nbsp&nbsp&nbsp' + answer.comments.to_s

    safe_join(["".html_safe, "".html_safe], html.html_safe)
  end
end
