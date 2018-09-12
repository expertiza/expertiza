class TagPrompt < ActiveRecord::Base
  include ActionView::Helpers

  validates :prompt, presence: true
  validates :desc, presence: true
  validates :control_type, presence: true

  def html_control(tag_prompt_deployment, answer, user_id)
    html = ''
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
        when 'slider'
          html = slider_control(answer, tag_prompt_deployment, stored_tags)
        when 'checkbox'
          html = checkbox_control(answer, tag_prompt_deployment, stored_tags)
        end
      end
    end
    html
  end

  def checkbox_control(answer, tag_prompt_deployment, stored_tags)
    value = stored_tags.count > 0 ? stored_tags.first.value.to_s : '0'
    element_id = answer.id.to_s + '_' + self.id.to_s
    control_id = 'tag_prompt_' + element_id

    html = safe_join([check_box_tag('tag_checkboxes[]', value, nil, id: control_id, onLoad: 'toggleLabel(this)', onChange: 'toggleLabel(this); save_tag(' + answer.id.to_s + ', ' + tag_prompt_deployment.id.to_s + ', ' + control_id + ');'),
                      label_tag(control_id, self.prompt.to_s)])
    content_tag(:div, html, class: 'toggle-container tag_prompt_container', title: self.desc.to_s)
  end

  def slider_control(answer, tag_prompt_deployment, stored_tags)
    value = stored_tags.count > 0 ? stored_tags.first.value.to_s : '0'
    element_id = answer.id.to_s + '_' + self.id.to_s
    control_id = 'tag_prompt_' + element_id
    no_text_class = 'toggle-false-msg'
    yes_text_class = 'toggle-true-msg'

    # change the color of the label based on its value
    if value.to_i < 0
      no_text_class += ' textActive'
    elsif value.to_i > 0
      yes_text_class += ' textActive'
    end

    slider = range_field_tag('tag_checkboxes[]', value, id: control_id, min: '-1', class: 'rangeAll', max: '1', onLoad: 'toggleLabel(this)', onChange: 'toggleLabel(this); save_tag(' + answer.id.to_s + ', ' + tag_prompt_deployment.id.to_s + ', ' + control_id + ');')
    html = safe_join([content_tag(:div, 'No', class: no_text_class, id: 'no_text_' + element_id),
                      content_tag(:div, slider, class: 'range-field', style: 'width:60px'),
                      content_tag(:div, 'Yes', class: yes_text_class, id: 'yes_text_' + element_id),
                      content_tag(:div, self.prompt, class: 'toggle-caption')])
    content_tag(:div, html, class: 'toggle-container tag_prompt_container', title: self.desc.to_s)
  end
end
