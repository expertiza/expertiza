class Cake < ScoredQuestion
  include ActionView::Helpers
  validates :size, presence: true
  #method is called during creation of questionnaire --> when cake type is added to the questionnaire.
  def edit(_count)
    html = '<td align="center"><a rel="nofollow" data-method="delete" href="/questions/' + self.id.to_s + '">Remove</a></td>'
    html += '<td><input size="6" value="' + self.seq.to_s + '" name="question[' + self.id.to_s + '][seq]"'
    html += ' id="question_' + self.id.to_s + '_seq" type="text"></td>'
    html += '<td><textarea cols="50" rows="1" name="question[' + self.id.to_s + '][txt]"'
    html += ' id="question_' + self.id.to_s + '_txt" placeholder="Edit question content here">' + self.txt + '</textarea></td>'
    html += '<td><input size="10" disabled="disabled" value="' + self.type + '" name="question[' + self.id.to_s + '][type]"'
    html += ' id="question_' + self.id.to_s + '_type" type="text"></td>'
    html += '<td><input size="2" value="' + self.weight.to_s
    html += '" name="question[' + self.id.to_s + '][weight]" id="question_' + self.id.to_s + '_weight" type="text"></td>'
    html += '<td>text area size <input size="3" value="' + self.size.to_s
    html += '" name="question[' + self.id.to_s + '][size]" id="question_' + self.id.to_s + '_size" type="text"></td>'
    safe_join(["<tr>".html_safe, "</tr>".html_safe], html.html_safe)
  end

  # Method called after clicking on View Questionnaire option
  def view_question_text
    html = '<TD align="left"> ' + self.txt + ' </TD>'
    html += '<TD align="left">' + self.type + '</TD>'
    html += '<td align="center">' + self.weight.to_s + '</TD>'
    questionnaire = self.questionnaire
    html += '<TD align="center">' + questionnaire.min_question_score.to_s + ' to ' + questionnaire.max_question_score.to_s + '</TD>'
    safe_join(["<TR>".html_safe, "</TR>".html_safe], html.html_safe)
  end

  def complete(count, answer = nil)
    if self.size.nil?
      cols = '70'
      rows = '1'
    else
      cols = self.size.split(',')[0]
      rows = self.size.split(',')[1]
    end
    current_score = Answer.get_total_score_for_question(answer[:id])
    if(!current_score.nil?)
      current_score = current_score.to_s
    else
      current_score = 0.to_s
    end
    html = '<table> <tbody> <tr><td>'
    html += '<label for="responses_' + count.to_s + '"">' + self.txt + '&nbsp;&nbsp;</label>'
    html += '<input class="form-control" id="responses_'+count.to_s+'" min="0" name="responses['+count.to_s+'][score]"'
    html += 'value="'+answer.answer.to_s+'"' unless answer.nil?
    html += 'type="number" size = 30> '
    html += '</td></tr></tbody></table>'
    html += '<td width="10%"></td></tr></table>'
    html += '<p>Total contribution so far: ' + current_score + '% </p>'  #display total
      html += '<textarea cols=' + cols + ' rows=' + rows + ' id="responses_' + count.to_s + '_comments"' \
        ' name="responses[' + count.to_s + '][comment]" class="tinymce">'
      html += answer.comments unless answer.nil?
      html += '</textarea>'
    safe_join(["".html_safe, "".html_safe], html.html_safe)
  end

  # This method returns what to display if a student is viewing a filled-out questionnaire
  def view_completed_question(count, answer)
    score = answer && !answer.answer.nil? ? answer.answer.to_s : "-"
    html = '<b>' + count.to_s + ". " + self.txt + "</b>"
    html += '<div class="c5" style="width:30px; height:30px;' \
      ' border-radius:50%; font-size:15px; color:black; line-height:30px; text-align:center;">'
    html += score
    html += '</div>'
    html += '<b>Comments:</b>' + answer.comments.to_s
    safe_join(["".html_safe, "".html_safe], html.html_safe)
  end

end
