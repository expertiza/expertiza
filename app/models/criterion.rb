# Initial commit
class Criterion < ScoredQuestion
  include ActionView::Helpers
  validates :size, presence: true

  # This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
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

    html += '<td> max_label <input size="10" value="' + self.max_label.to_s + '" name="question[' + self.id.to_s
    html += '][max_label]" id="question_' + self.id.to_s + '_max_label" type="text">  min_label <input size="12" value="' + self.min_label.to_s
    html += '" name="question[' + self.id.to_s + '][min_label]" id="question_' + self.id.to_s + '_min_label" type="text"></td>'

    safe_join(["<tr>".html_safe, "</tr>".html_safe], html.html_safe)
  end

  # This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    html = '<TD align="left"> ' + self.txt + ' </TD>'
    html += '<TD align="left">' + self.type + '</TD>'
    html += '<td align="center">' + self.weight.to_s + '</TD>'
    questionnaire = self.questionnaire
    if !self.max_label.nil? && !self.min_label.nil?
      html += '<TD align="center"> (' + self.min_label + ') ' + questionnaire.min_question_score.to_s
      html += ' to ' + questionnaire.max_question_score.to_s + ' (' + self.max_label + ')</TD>'
    else
      html += '<TD align="center">' + questionnaire.min_question_score.to_s + ' to ' + questionnaire.max_question_score.to_s + '</TD>'
    end
    safe_join(["<TR>".html_safe, "</TR>".html_safe], html.html_safe)
  end

  # Reduced the number of lines. Removed some redundant if-else statements, and combined some HTML concatenations.
  # Display for the students when they are filling the questionnaire
  def complete(count, answer = nil, questionnaire_min, questionnaire_max, dropdown_or_scale)
    html = '<div><label for="responses_' + count.to_s + '">' + self.txt + '</label></div>'
    question_advices = QuestionAdvice.where(question_id: self.id).sort_by(&:id)
    advice_total_length = 0
    question_advices.each do |question_advice|
      advice_total_length += question_advice.advice.length if question_advice.advice && question_advice.advice != ""
    end
    # show advice given for different questions
    html += advices_criterion_question(count, question_advices) if !question_advices.empty? and advice_total_length > 0
    # dropdown options to rate a project based on the question
    html += dropdown_criterion_question(count, answer, questionnaire_min, questionnaire_max) if dropdown_or_scale == 'dropdown'
    # scale options to rate a project based on the question
    html += scale_criterion_question(count, answer, questionnaire_min, questionnaire_max) if dropdown_or_scale == 'scale'
    safe_join(["".html_safe, "".html_safe], html.html_safe)
  end

  # show advice for each criterion question
  def advices_criterion_question(count, question_advices)
    html = '<a id="showAdvice_' + self.id.to_s + '" onclick="showAdvice(' + self.id.to_s + ')">Show advice</a><script>'
    html += 'function showAdvice(i){var element = document.getElementById("showAdivce_" + i.toString());'
    html += 'var show = element.innerHTML == "Hide advice";'
    html += 'if (show){element.innerHTML="Show advice";} else{element.innerHTML="Hide advice";}toggleAdvice(i);}'
    html += 'function toggleAdvice(i) {var elem = document.getElementById(i.toString() + "_myDiv");'
    html += 'if (elem.style.display == "none") {elem.style.display = "";} else {elem.style.display = "none";}}</script>'
    html += '<div id="' + self.id.to_s + '_myDiv" style="display: none;">'
    # [2015-10-26] Zhewei:
    # best to order advices high to low, e.g., 5 to 1
    # each level used to be a link;
    # clicking on the link caused the dropbox to be filled in with the corresponding number
    question_advices.reverse.each_with_index do |question_advice, index|
      html += '<a id="changeScore_>' + self.id.to_s + '" onclick="changeScore(' + count.to_s + ',' + index.to_s + ')">'
      html += (self.questionnaire.max_question_score - index).to_s + ' - ' + question_advice.advice + '</a><br/><script>'
      html += 'function changeScore(i, j) {var elem = jQuery("#responses_" + i.toString() + "_score");'
      html += 'var opts = elem.children("option").length;'
      html += 'elem.val((' + self.questionnaire.max_question_score.to_s + ' - j).toString());}</script>'
    end
    html += '</div>'
  end

  # dropdown options to rate a project based on the question
  def dropdown_criterion_question(count, answer = nil, questionnaire_min, questionnaire_max)
    current_value = ""
    current_value += 'data-current-rating =' + answer.answer.to_s unless answer.nil?
    html = '<div><select id="responses_' + count.to_s + '_score" name="responses[' + count.to_s + '][score]" class="review-rating" ' + current_value + '>'
    html += "<option value = ''>--</option>"
    questionnaire_min.upto(questionnaire_max).each do |j|
      html += '<option value=' + j.to_s
      html += ' selected="selected"' if !answer.nil? && j == answer.answer
      html += '>' + j.to_s
      html += "-" + self.min_label if self.min_label.present? && j == questionnaire_min
      html += "-" + self.max_label if self.max_label.present? && j == questionnaire_max
      html += "</option>"
    end

    html += '</select></div><br><br><textarea' + ' id="responses_' + count.to_s + '_comments"'
    html += ' name="responses[' + count.to_s + '][comment]" class="tinymce">'
    html += answer.comments if !answer.nil? && !answer.comments.nil?
    html += '</textarea></td>'
  end

  # scale options to rate a project based on the question
  def scale_criterion_question(count, answer = nil, questionnaire_min, questionnaire_max)
    if self.size.nil? || self.size.blank?
      cols = '70'
      rows = '1'
    else
      cols = self.size.split(',')[0]
      rows = self.size.split(',')[1]
    end
    html = '<input id="responses_' + count.to_s + '_score" name="responses[' + count.to_s + '][score]" type="hidden"'
    html += 'value="' + answer.answer.to_s + '"' unless answer.nil?
    html += '><table><tr><td width="10%"></td>'

    (questionnaire_min..questionnaire_max).each do |j|
      html += '<td width="10%"><label>' + j.to_s + '</label></td>'
    end

    html += '<td width="10%"></td></tr><tr><td width="10%">'
    html += self.min_label unless self.min_label.nil?
    html += '</td>'

    (questionnaire_min..questionnaire_max).each do |j|
      html += '<td width="10%"><input type="radio" id="' + j.to_s + '" value="' + j.to_s + '" name="Radio_' + self.id.to_s + '"'
      html += 'checked="checked"' if (!answer.nil? && answer.answer == j) or (answer.nil? && questionnaire_min == j)
      html += '></td>'
    end
    html += '<script>jQuery("input[name=Radio_' + self.id.to_s + ']:radio").change(function() {'
    html += 'var response_score = jQuery("#responses_' + count.to_s + '_score");'
    html += 'var checked_value = jQuery("input[name=Radio_' + self.id.to_s + ']:checked").val();'
    html += 'response_score.val(checked_value);});</script><td width="10%">'
    html += self.max_label unless self.max_label.nil?
    html += '</td><td width="10%"></td></tr></table>'
    html += '<textarea cols=' + cols + ' rows=' + rows + ' id="responses_' + count.to_s + '_comments"' \
      ' name="responses[' + count.to_s + '][comment]" class="tinymce">'
    html += answer.comments if !answer.nil? && !answer.comments.nil?
    html += '</textarea>'
  end

  # This method returns what to display if a student is viewing a filled-out questionnaire
  def view_completed_question(count, answer, questionnaire_max, tag_prompt_deployments = nil, current_user = nil)
    html = '<b>' + count.to_s + ". " + self.txt + ' [Max points: ' + questionnaire_max.to_s + "]</b>"
    score = answer && !answer.answer.nil? ? answer.answer.to_s : "-"
    score_percent = score != "-" ? answer.answer * 1.0 / questionnaire_max : 0
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

    html += '<table cellpadding="5"><tr><td>'
    html += '<div class="' + score_color + '" style="width:30px; height:30px;' \
      ' border-radius:50%; font-size:15px; color:black; line-height:30px; text-align:center;">'
    html += score + '</div></td>'

    if answer && !answer.comments.nil?
      html += '<td style="padding-left:10px"><br>' + answer.comments.html_safe + '</td>'
      #### start code to show tag prompts ####
      if !tag_prompt_deployments.nil? && tag_prompt_deployments.count > 0
        # show check boxes for answer tagging
        question = Question.find(answer.question_id)
        html += '<tr><td colspan="2">'
        tag_prompt_deployments.each do |tag_dep|
          tag_prompt = TagPrompt.find(tag_dep.tag_prompt_id)
          if tag_dep.question_type == question.type && answer.comments.length > tag_dep.answer_length_threshold.to_i
            html += tag_prompt.html_control(tag_dep, answer, current_user)
          end
        end
        html += '</td></tr>'
      end
      #### end code to show tag prompts ####
    end
    html += '</tr></table>'
    safe_join(["".html_safe, "".html_safe], html.html_safe)
  end
end
