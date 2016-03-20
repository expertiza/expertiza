class ScoredQuestion < ChoiceQuestion
  validates_presence_of :weight # user must specify a weight for a question
  validates_numericality_of :weight # the weight must be numeric

  def edit
  end
  # edit in 03/29/2016, method are the same in two subclasses: scale.rb and criterion.rb
  # original method in super class scored_question.rb
  # def view_question_text
  # end
  # method rewritten in two subclasses
  #This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    html = '<TR><TD align="left"> '+self.txt+' </TD>'
    html += '<TD align="left">'+self.type+'</TD>'
    html += '<td align="center">'+self.weight.to_s+'</TD>'
    questionnaire = self.questionnaire
    if !self.max_label.nil? && !self.min_label.nil?
      html += '<TD align="center"> ('+self.min_label+') '+questionnaire.min_question_score.to_s+' to '+ questionnaire.max_question_score.to_s + ' ('+self.max_label+')</TD>'
    else
      html += '<TD align="center">'+questionnaire.min_question_score.to_s+' to '+ questionnaire.max_question_score.to_s + '</TD>'
    end
    html += '</TR>'
    html.html_safe
  end

  def complete
  end
# edit done
  def view_completed_question
  end



  def self.compute_question_score(response_id)
     answer = Answer.where(question_id: self.id, response_id: response_id).first
     return self.weight * answer.answer
  end


  # add the following functions to refactor duplicates.
  def complete_questionnaire_min_to_questionnaire_max(ob, html, answer, questionnaire_min, questionnaire_max)
    for j in questionnaire_min..questionnaire_max
      html += '<td width="10%"><input type="radio" id="' +j.to_s+ '" value="' +j.to_s+ '" name="Radio_' +ob.id.to_s+ '"'
      html += 'checked="checked"' if (!answer.nil? and answer.answer == j) or (answer.nil? and questionnaire_min == j)
      html += '></td>'
    end
    return html
  end

  def edit_end(ob, html)
    html+='<td> max_label <input size="4" value="'+ob.max_label.to_s+'" name="question['+ob.id.to_s+'][max_label]" id="question_'+ob.id.to_s+'_max_label" type="text">  min_label <input size="4" value="'+ob.min_label.to_s+'" name="question['+ob.id.to_s+'][min_label]" id="question_'+ob.id.to_s+'_min_label" type="text"></td>'
    html+='</tr>'
  end

  def complete_min_label(ob, html)
    if !ob.min_label.nil?
      html += '<td width="10%">' +ob.min_label+ '</td>'
    else
      html += '<td width="10%"></td>'
    end
  end

  def complete_max_label(ob, html)
    if !self.max_label.nil?
      html += '<td width="10%">' +self.max_label+ '</td>'
    else
      html += '<td width="10%"></td>'
    end
  end

end
