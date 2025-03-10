class TagPrompt < ApplicationRecord
  validates :prompt, presence: true
  validates :desc, presence: true
  validates :control_type, presence: true

  def html_control(tag_prompt_deployment, answer, user_id)
    html = ''
    unless answer.nil?
      stored_tags = AnswerTag.where(tag_prompt_deployment_id: tag_prompt_deployment.id, answer_id: answer.id, user_id: user_id)

      length_valid = false
      if tag_prompt_deployment.answer_length_threshold.nil?
        length_valid = true
      else
        length_valid = true unless answer.comments.nil? || answer.comments.length <= tag_prompt_deployment.answer_length_threshold
      end

      if length_valid && answer.question.type.eql?(tag_prompt_deployment.question_type)
        case control_type.downcase
        when 'slider'
          html = slider_control(answer, tag_prompt_deployment, stored_tags)
        when 'checkbox'
          html = checkbox_control(answer, tag_prompt_deployment, stored_tags)
        end
      end
    end
    html.html_safe
  end

  def checkbox_control(answer, tag_prompt_deployment, stored_tags)
    html = ''
    value = '0'

    if stored_tags.count > 0
      tag = stored_tags.first
      value = tag.value.to_s
    end

    element_id = answer.id.to_s + '_' + id.to_s
    control_id = 'tag_prompt_' + element_id

    html += '<div class="toggle-container tag_prompt_container" title="' + desc.to_s + '">'
    html += '<input type="checkbox" name="tag_checkboxes[]" id="' + control_id + '" value="' + value + '" onLoad="toggleLabel(this)" onChange="toggleLabel(this); save_tag(' + answer.id.to_s + ', ' + tag_prompt_deployment.id.to_s + ', ' + control_id + ');" />'
    html += '<label for="' + control_id + '">&nbsp;'
    html += prompt.to_s + '</label>'
    html += '</div>'
    html
  end

  def slider_control(answer, tag_prompt_deployment, stored_tags)
    html = ''
    value = '0'
    if stored_tags.count > 0
      tag = stored_tags.first
      value = tag.value.to_s
    end
    element_id = answer.id.to_s + '_' + id.to_s
    control_id = 'tag_prompt_' + element_id
    no_text_class = 'toggle-false-msg'
    yes_text_class = 'toggle-true-msg'

    # change the color of the label based on its value
    if value.to_i < 0
      no_text_class += ' textActive'
    elsif value.to_i > 0
      yes_text_class += ' textActive'
    end

    html += '<div class="toggle-container tag_prompt_container" title="' + desc.to_s + '">'
    html += ' <div class="' + no_text_class + '" id="no_text_' + element_id + '">No</div>'
    html += ' <div class="range-field" style=" width:60px">'
    html += '   <input type="range" name="tag_checkboxes[]" id="' + control_id + '" min="-1" class="rangeAll" max="1" value="' + value + '" onLoad="toggleLabel(this)" onChange="toggleLabel(this); save_tag(' + answer.id.to_s + ', ' + tag_prompt_deployment.id.to_s + ', ' + control_id + ');"></input>'
    html += ' </div>'
    html += ' <div class="' + yes_text_class + '" id="yes_text_' + element_id + '">Yes</div>'
    html += ' <div class="toggle-caption">' + prompt.to_s + '</div>'
    html += '</div>'

    html
  end
end
