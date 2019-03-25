class TagPrompt < ActiveRecord::Base
  include ActionView::Helpers
  include ActionView::Context

  validates :prompt, presence: true
  validates :desc, presence: true
  validates :control_type, presence: true

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
    html
  end

  def checkbox_control(answer, tag_prompt_deployment, stored_tags)
    value = "0"

    if stored_tags.count > 0
      tag = stored_tags.first
      value = tag.value.to_s
    end

    element_id = answer.id.to_s + '_' + self.id.to_s
    control_id = "tag_prompt_" + element_id
    on_change_value = 'toggleLabel(this); save_tag(' + answer.id.to_s + ', ' +
        tag_prompt_deployment.id.to_s + ', ' + control_id + ');'

    content_tag(:div,
                capture do
                   concat tag(:input, {type: "checkbox", name: "tag_checkboxes[]", id: control_id, value: value,
                                      onLoad: "toggleLabel(this)", onChange: on_change_value}, false, false)
                   concat content_tag(:label, '&nbsp;' + self.prompt.to_s, {for: " " + control_id}, false)
                end, {class: "toggle-container tag_prompt_container", title: self.desc.to_s}, false)
  end

  def slider_control(answer, tag_prompt_deployment, stored_tags)
    value = "0"
    if stored_tags.count > 0
      tag = stored_tags.first
      value = tag.value.to_s
    end
    element_id = answer.id.to_s + '_' + self.id.to_s
    control_id = "tag_prompt_" + element_id
    on_change_value = 'toggleLabel(this); save_tag(' + answer.id.to_s + ', ' +
        tag_prompt_deployment.id.to_s + ', ' + control_id + ');'

    no_text_class = "toggle-false-msg"
    yes_text_class = "toggle-true-msg"
    # change the color of the label based on its value
    if value.to_i < 0
      no_text_class += " textActive"
    elsif value.to_i > 0
      yes_text_class += " textActive"
    end

    content_tag(:div,
                capture do
                  concat content_tag(:div, "No", {class: no_text_class, id: "no_text_" + element_id}, false)
                  concat content_tag(:div,
                                     content_tag(:input, nil, {type: "range", name: "tag_checkboxes[]",
                                                               id: control_id, min: "-1", class: "rangeAll", max: "1",
                                                               value: value, onLoad: "toggleLabel(this)",
                                                               onChange: on_change_value}, false),
                                     {class: "range-field", style: " width:60px"}, false)
                  concat content_tag(:div, "Yes", {class: yes_text_class, id: "yes_text_" + element_id}, false)
                  concat content_tag(:div, self.prompt.to_s, {class: "toggle-caption"}, false)
                end, {class: "toggle-container tag_prompt_container", title: self.desc.to_s}, false)
  end
end
