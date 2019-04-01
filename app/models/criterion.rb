class Criterion < ScoredQuestion
  include ActionView::Helpers
  validates :size, presence: true

  #E1911:The edit method from here has been moved to the views/questionnaires/_criterion_edit.html.erb partial

  #E1911:The view_question_text method from here has been moved to the views/questionnaires/_criterion_view.html.erb partial


  #E1911:The complete method from here has been moved to the views/responses/_criterion_complete.html.erb partial

  #E1911:This method cannot be refactored without refactoring entire response.rb
  # This method returns what to display if a student is viewing a filled-out questionnaire
  def view_completed_question(count, answer, questionnaire_max, tag_prompt_deployments = nil, current_user = nil)
    html = '<b>' + count.to_s + ". " + self.txt + ' [Max points: ' + questionnaire_max.to_s + "]</b>"

    score = answer && !answer.answer.nil? ? answer.answer.to_s : "-"
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
    if answer && !answer.comments.nil?
      html += '<td style="padding-left:10px">'
      html += '<br>' + answer.comments.html_safe
      html += '</td>'
      #### start code to show tag prompts ####
      unless tag_prompt_deployments.nil?
        # show check boxes for answer tagging
        resp = Response.find(answer.response_id)
        question = Question.find(answer.question_id)
        if tag_prompt_deployments.count > 0
          html += '<tr><td colspan="2">'
          tag_prompt_deployments.each do |tag_dep|
            tag_prompt = TagPrompt.find(tag_dep.tag_prompt_id)
            if tag_dep.question_type == question.type and answer.comments.length > tag_dep.answer_length_threshold.to_i
              html += tag_prompt.html_control(tag_dep, answer, current_user)
            end
          end
          html += '</td></tr>'
        end
      end
      #### end code to show tag prompts ####
    end
    html += '</tr></table>'
    safe_join(["".html_safe, "".html_safe], html.html_safe)
  end
end
