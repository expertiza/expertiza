class Criterion < ScoredQuestion
  validates_presence_of :size

  # This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit(_count)
    html = edit_1(_count) + edit_2(_count) + edit_3(_count) + edit_4(_count)
    html += edit_5(_count) + edit_6(_count) + edit_7(_count) + edit_8(_count)
    html.html_safe
  end

  def edit_1(_count)
    html = '<tr>' + '<td align="center"><a rel="nofollow" data-method="delete" href="/questions/'
    html += self.id.to_s + '">Remove</a></td>'
    html += '<td><input size="6" value="'
    html += self.seq.to_s
    html += '" name="question[' + self.id.to_s
    html
  end

  def edit_2(count)
    html = '][seq]" id="question_' + self.id.to_s
    html += '_seq" type="text"></td>'
    html += '<td><textarea cols="50" rows="1" name="question['
    html += self.id.to_s + '][txt]" id="question_'
    html += self.id.to_s
    html
  end

  def edit_3(_count)
    html = '_txt" placeholder="Edit question content here">'
    html += self.txt + '</textarea></td>'
    html += '<td><input size="10" disabled="disabled" value="'
    html += self.type + '" name="question[' + self.id.to_s
    html += '][type]" id="question_' + self.id.to_s
    html
  end

  def edit_4(_count)
    html = '_type" type="text">''</td>'
    html += '<td><input size="2" value="'
    html += self.weight.to_s + '" name="question['
    html += self.id.to_s + '][weight]" id="question_'
    html += self.id.to_s + '_weight" type="text">''</td>'
    html
  end

  def edit_5(_count)
    html = '<td>text area size <input size="3" value="'
    html += self.size.to_s + '" name="question['
    html += self.id.to_s + '][size]" id="question_'
    html += self.id.to_s + '_size" type="text"></td>'
    html += '<td> max_label <input size="10" value="'
    html

  def edit_6(_count)
    html += self.max_label.to_s + '" name="question['
    html += self.id.to_s
    html += '][max_label]" id="question_'
    html += self.id.to_s
    html += '][max_label]" id="question_'
    html
  end

  def edit_7(_count)
    html = self.id.to_s
    html += '_max_label" type="text">  min_label <input size="12" value="'
    html += self.min_label.to_s
    html += '" name="question['
    html += self.id.to_s
    html
  end

  def edit_8(_count)
    html = '][min_label]" id="question_'
    html += self.id.to_s
    html += '_min_label" type="text"></td>'
    html += '</tr>'
    html
  end
 
  
  # This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    html = '<TR><TD align="left"> ' + self.txt + ' </TD>'
    html += '<TD align="left">' + self.type + '</TD>'
    html += '<td align="center">' + self.weight.to_s + '</TD>'
    questionnaire = self.questionnaire
    if !self.max_label.nil? && !self.min_label.nil?
      html += '<TD align="center"> (' + self.min_label + ') ' + questionnaire.min_question_score.to_s + ' to ' + questionnaire.max_question_score.to_s + ' (' + self.max_label + ')</TD>'
    else
      html += '<TD align="center">' + questionnaire.min_question_score.to_s + ' to ' + questionnaire.max_question_score.to_s + '</TD>'
    end

    html += '</TR>'
    html.html_safe
  end

  def complete(count, answer = nil, questionnaire_min, questionnaire_max, dropdown_or_scale)
    if self.size.nil?
      cols = '70'
      rows = '1'
    else
      cols = self.size.split(',')[0]
      rows = self.size.split(',')[1]
    end

    html = '<li><div><label for="responses_' + count.to_s + '">' + self.txt + '</label></div>'
    # show advice for each criterion question
    question_advices = QuestionAdvice.where(question_id: self.id).sort_by(&:id)
    advice_total_length = 0

    question_advices.each do |question_advice|
      if question_advice.advice && question_advice.advice != ""
        advice_total_length += question_advice.advice.length
      end
    end

    if !question_advices.empty? and advice_total_length > 0
      html += '<a id="showAdivce_' + self.id.to_s + '" onclick="showAdvice(' + self.id.to_s + ')">Show advice</a>'
      html += '<script>'
      html += 'function showAdvice(i){'
      html += 'var element = document.getElementById("showAdivce_" + i.toString());'
      html += 'var show = element.innerHTML == "Hide advice";'
      html += 'if (show){'
      html += 'element.innerHTML="Show advice";'
      html += '}else{'
      html += 'element.innerHTML="Hide advice";}'
      html += 'toggleAdvice(i);}'

      html += 'function toggleAdvice(i) {'
      html += 'var elem = document.getElementById(i.toString() + "_myDiv");'
      html += 'if (elem.style.display == "none") {'
      html += 'elem.style.display = "";'
      html += '} else {'
      html += 'elem.style.display = "none";}}'
      html += '</script>'

      html += '<div id="' + self.id.to_s + '_myDiv" style="display: none;">'
      # [2015-10-26] Zhewei:
      # best to order advices high to low, e.g., 5 to 1
      # each level used to be a link;
      # clicking on the link caused the dropbox to be filled in with the corresponding number
      question_advices.reverse.each_with_index do |question_advice, index|
        html += '<a id="changeScore_>' + self.id.to_s + '" onclick="changeScore(' + count.to_s + ',' + index.to_s + ')">'
        html += (self.questionnaire.max_question_score - index).to_s + ' - ' + question_advice.advice + '</a><br/>'
        html += '<script>'
        html += 'function changeScore(i, j) {'
        html += 'var elem = jQuery("#responses_" + i.toString() + "_score");'
        html += 'var opts = elem.children("option").length;'
        html += 'elem.val((' + self.questionnaire.max_question_score.to_s + ' - j).toString());}'
        html += '</script>'
      end
      html += '</div>'
    end

    if dropdown_or_scale == 'dropdown'
      html += '<div><select id="responses_' + count.to_s + '_score" name="responses[' + count.to_s + '][score]">'
      html += '<option value=''>--</option>'
      (questionnaire_min..questionnaire_max).each do |j|
        html += if !answer.nil? and j == answer.answer
                  '<option value=' + j.to_s + ' selected="selected">'
                else
                  '<option value=' + j.to_s + '>'
                end
        if j == questionnaire_min
          html += j.to_s
          html += "-" + self.min_label if self.min_label && !self.min_label.empty?
          html += "</option>"
        elsif j == questionnaire_max
          html += j.to_s
          html += "-" + self.max_label if self.max_label && !self.max_label.empty?
          html += "</option>"
        else
          html += j.to_s + "</option>"
        end
      end
      html += "</select></div>"
      html += '<textarea cols=' + cols + ' rows=' + rows + ' id="responses_' + count.to_s + '_comments" name="responses[' + count.to_s + '][comment]" style="overflow:hidden;">'
      html += answer.comments unless answer.nil?
      html += '</textarea></td></br><br/>'
    elsif dropdown_or_scale == 'scale'
      html += '<input id="responses_' + count.to_s + '_score" name="responses[' + count.to_s + '][score]" type="hidden"'
      html += 'value="' + answer.answer.to_s + '"' unless answer.nil?
      html += '>'

      html += '<table>'
      html += '<tr><td width="10%"></td>'

      (questionnaire_min..questionnaire_max).each do |j|
        html += '<td width="10%"><label>' + j.to_s + '</label></td>'
      end

      html += '<td width="10%"></td></tr><tr>'

      html += if !self.min_label.nil?
                '<td width="10%">' + self.min_label + '</td>'
              else
                '<td width="10%"></td>'
              end
      (questionnaire_min..questionnaire_max).each do |j|

        html += '<td width="10%"><input type="radio" id="' + j.to_s + '" value="' + j.to_s + '" name="Radio_' + self.id.to_s + '"'
        html += 'checked="checked"' if (!answer.nil? and answer.answer == j) or (answer.nil? and questionnaire_min == j)
        html += '></td>'
      end
      html += '<script>jQuery("input[name=Radio_' + self.id.to_s + ']:radio").change(function() {'
      html += 'var response_score = jQuery("#responses_' + count.to_s + '_score");'
      html += 'var checked_value = jQuery("input[name=Radio_' + self.id.to_s + ']:checked").val();'
      html += 'response_score.val(checked_value);});</script>'

      html += if !self.max_label.nil?
                '<td width="10%">' + self.max_label + '</td>'
              else
                '<td width="10%"></td>'
              end

      html += '<td width="10%"></td></tr></table>'
      html += '<textarea cols=' + cols + ' rows=' + rows + ' id="responses_' + count.to_s + '_comments" name="responses[' + count.to_s + '][comment]" style="overflow:hidden;">'
      html += answer.comments unless answer.nil?
      html += '</textarea><br/><br/>'

    end
    html.html_safe
  end

  # This method returns what to display if a student is viewing a filled-out questionnaire
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
    html += '<div class="' + score_color + '" style="width:30px; height:30px; border-radius:50%; font-size:15px; color:black; line-height:30px; text-align:center;">'
    html += score
    html += '</div>'
    html += '</td>'
    unless answer.comments.nil?
      html += '<td style="padding-left:10px">'
      html += answer.comments.gsub("<", "&lt;").gsub(">", "&gt;").gsub(/\n/, '<BR/>')
      html += '</td>'
    end
    html += '</tr></table>'
    html.html_safe
  end
end
