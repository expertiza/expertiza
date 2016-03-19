class ScoredQuestion < ChoiceQuestion
  validates_presence_of :weight # user must specify a weight for a question
  validates_numericality_of :weight # the weight must be numeric

  def edit
  end

  def view_question_text
  end

  def complete
  end

  def view_completed_question
  end

  def self.compute_question_score(response_id)
     answer = Answer.where(question_id: self.id, response_id: response_id).first
     return self.weight * answer.answer
  end
<<<<<<< HEAD

  # method added to remove duplicated code from subclasses

  def complete_questionnaire_min_to_questionnaire_max(html, answer, questionnaire_min, questionnaire_max)
    for j in questionnaire_min..questionnaire_max
      html += '<td width="10%"><input type="radio" id="' +j.to_s+ '" value="' +j.to_s+ '" name="Radio_' +self.id.to_s+ '"'
      html += 'checked="checked"' if (!answer.nil? and answer.answer == j) or (answer.nil? and questionnaire_min == j)
      html += '></td>'
    end
    return html
  end

  def edit_plus_html(html)
    html+='<td> max_label <input size="10" value="'+self.max_label.to_s+'" name="question['+self.id.to_s+'][max_label]" id="question_'+self.id.to_s+'_max_label" type="text">  min_label <input size="12" value="'+self.min_label.to_s+'" name="question['+self.id.to_s+'][min_label]" id="question_'+self.id.to_s+'_min_label" type="text"></td>'
    html+='</tr>'
  end

  def complete_max_label_condition(html)
    if !self.max_label.nil?
      html += '<td width="10%">' +self.max_label+ '</td>'
    else
      html += '<td width="10%"></td>'
    end
  end

  def complete_min_label_condition(html)
    if !self.min_label.nil?
      html += '<td width="10%">' +self.min_label+ '</td>'
    else
      html += '<td width="10%"></td>'
    end
  end

=======
>>>>>>> 9c41bf084330f887070eaf3a9f7aa2481f07daa8
end
