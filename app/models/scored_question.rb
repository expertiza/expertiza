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

  def complete_questionnaire_min_to_questionnaire_max(html, answer, questionnaire_min, questionnaire_max)
    for j in questionnaire_min..questionnaire_max
      html += '<td width="10%"><input type="radio" id="' +j.to_s+ '" value="' +j.to_s+ '" name="Radio_' +self.id.to_s+ '"'
      html += 'checked="checked"' if (!answer.nil? and answer.answer == j) or (answer.nil? and questionnaire_min == j)
      html += '></td>'
    end
    return html
  end
end
