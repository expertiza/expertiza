class TagPrompt < ActiveRecord::Base
  validates :prompt, presence: true
  validates :desc, presence: true
  validates :control_type, presence: true

  def self.show_tag_prompts(tag_prompt_deployments, answer, user_id = nil)
    html = ''
    #### start code to show tag prompts ####
    unless tag_prompt_deployments.blank?
      question = Question.find(answer.question_id)
      html += '<tr><td colspan="2">'
      tag_prompt_deployments.each do |tag_dep|
        if tag_dep.question_type == question.type and answer.comments.length > tag_dep.answer_length_threshold.to_i
          tag_prompt = TagPrompt.find(tag_dep.tag_prompt_id)
          html += tag_prompt.html_control(tag_dep, answer, user_id)
        end
      end
      html += '</td></tr>'
    end
    #### end code to show tag prompts ####
    html
  end

  def html_control(tag_prompt_deployment, answer, user_id)
    html = ""
    unless answer.nil?
      stored_tags = AnswerTag.where(tag_prompt_deployment_id: tag_prompt_deployment.id, answer_id: answer.id, user_id: user_id)

      length_valid = false
      if !tag_prompt_deployment.answer_length_threshold.nil?
        length_valid = true if !answer.comments.nil? and (answer.comments.length > tag_prompt_deployment.answer_length_threshold)
      else
        length_valid = true
      end

      if length_valid and answer.question.type.eql?(tag_prompt_deployment.question_type)
        case self.control_type.downcase
        when "slider"
          html = slider_control(answer, tag_prompt_deployment, stored_tags)
        when "checkbox"
          html = checkbox_control(answer, tag_prompt_deployment, stored_tags)
        end
      end
    end

    html.html_safe
  end

  def checkbox_control(answer, tag_prompt_deployment, stored_tags)
    html = ""
    value = "0"

    if stored_tags.count > 0
      tag = stored_tags.first
      value = tag.value.to_s
    end

    element_id = answer.id.to_s + '_' + self.id.to_s
    control_id = "tag_prompt_" + element_id

    html += '<div class="toggle-container tag_prompt_container" title="' + self.desc.to_s + '">'
    html += '<input type="checkbox" name="tag_checkboxes[]" id="' + control_id + '" value="' + value + '" onLoad="toggleLabel(this)" onChange="toggleLabel(this); save_tag(' + answer.id.to_s + ', ' + tag_prompt_deployment.id.to_s + ', ' + control_id + ');" />'
    html += '<label for="' + control_id + '">&nbsp;'
    html += self.prompt.to_s + '</label>'
    html += '</div>'
    html
  end

  def slider_control(answer, tag_prompt_deployment, stored_tags)
    html = ""
    value = "0"
    text_style = ""
    toggle_style = ""
    if ReviewMetricsQuery.confident?(tag_prompt_deployment.tag_prompt.prompt, answer.id)
      if stored_tags.count > 0
        toggle_style = "changed-toggle"
        tag = stored_tags.first
        value = tag.value.to_s
      else
        text_style = "grey-out-text"
        toggle_style = "grey-out-toggle"
        value = ReviewMetricsQuery.has(tag_prompt_deployment.tag_prompt.prompt, answer.id) ? 1 : -1
      end
    elsif stored_tags.count > 0
      tag = stored_tags.first
      value = tag.value.to_s
    end

    element_id = answer.id.to_s + '_' + self.id.to_s
    control_id = "tag_prompt_" + element_id
    no_text_class = "toggle-false-msg"
    yes_text_class = "toggle-true-msg"

    # change the color of the label based on its value
    if value.to_i < 0
      no_text_class += " textActive"
    elsif value.to_i > 0
      yes_text_class += " textActive"
    end

    html += '<div class="toggle-container tag_prompt_container" title="' + self.desc.to_s + '">'
    html += ' <div class="' + no_text_class + ' ' + text_style + '" id="no_text_' + element_id + '">No</div>'
    html += ' <div class="range-field" style=" width:60px">'
    html += '   <input type="range" name="tag_checkboxes[]" id="' + control_id.to_s + '" min="-1" class="rangeAll ' + toggle_style + '" max="1" value="' + value.to_s + '" onLoad="toggleLabel(this)" onChange="toggleLabel(this); save_tag(' + answer.id.to_s + ', ' + tag_prompt_deployment.id.to_s + ', ' + control_id + ');"></input>'
    html += ' </div>'
    html += ' <div class="' + yes_text_class + ' ' + text_style + '" id="yes_text_' + element_id + '">Yes</div>'
    html += ' <div class="toggle-caption ' + text_style + '">' + self.prompt.to_s + '</div>'
    html += '</div>'

    html
  end
end
