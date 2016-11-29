class ScoredQuestion < ChoiceQuestion
  include ActionView::Helpers
  validates_presence_of :weight # user must specify a weight for a question
  validates_numericality_of :weight # the weight must be numeric

  def edit
  end

  def view_question_text
  end

  def complete
  end

  def view_completed_question(count, answer, questionnaire_max)
    html = '<b>' + count.to_s + ". " + self.txt + ' [Max points: ' + questionnaire_max.to_s + "]</b>"
    score = !answer.answer.nil? ? answer.answer.to_s : "-"
    score_percent = if score != "-"
                      answer.answer * 1.0 / questionnaire_max
                    else
                      0
                    end

    score_color = if score_percent > 0.8
                    "c5"
                  elsif score_percent > 0.6
                    "c4"
                  elsif score_percent > 0.4
                    "c3"
                  elsif score_percent > 0.2
                    "c2"
                  else
                    "c1"
                  end

    html += '<table cellpadding="5">'
    html += '<tr>'
    html += '<td>'
    html += '<div class="' + score_color + '" style="width:30px; height:30px;' \
      ' border-radius:50%; font-size:15px; color:black; line-height:30px; text-align:center;">'
    html += score
    html += '</div>'
    html += '</td>'
    unless answer.comments.nil?
      html += '<td style="padding-left:10px">'
      html += answer.comments.gsub("<", "&lt;").gsub(">", "&gt;").gsub(/\n/, '<BR/>')
      html += '</td>'
    end
    html += '</tr></table>'
    safe_join(["".html_safe, "".html_safe], html.html_safe)
  end

  def self.compute_question_score(response_id)
    answer = Answer.where(question_id: self.id, response_id: response_id).first
    self.weight * answer.answer
  end
end
