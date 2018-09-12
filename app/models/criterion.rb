class Criterion < ScoredQuestion
  include ActionView::Helpers
  validates :size, presence: true

  attr_accessible :id, :seq, :txt, :type, :weight, :size, :max_label, :min_label, :questionnaire

  # This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
  def edit
    html = safe_join([content_tag(:td, link_to('Remove', '/questions/' + self.id.to_s, method: :delete), align: 'center'),
                      content_tag(:td, text_field_tag('question[' + self.id.to_s + '][seq]', self.seq, size: 6)),
                      content_tag(:td, text_area_tag('question[' + self.id.to_s + '][txt]', self.txt,
                                                     cols: 50, rows: 1, placeholder: 'Edit question content here')),
                      content_tag(:td, text_field_tag('question[' + self.id.to_s + '][type]', self.type, size: 10, disabled: 'disabled')),
                      content_tag(:td, text_field_tag('question[' + self.id.to_s + '][weight]', self.weight, size: 2)),
                      content_tag(:td, safe_join(['text area size ', text_field_tag('question[' + self.id.to_s + '][size]', self.size, size: 3)])),
                      content_tag(:td, safe_join([' max_label ', text_field_tag('question[' + self.id.to_s + '][max_label]', self.max_label, size: 10),
                                                  ' min_label ', text_field_tag('question[' + self.id.to_s + '][min_label]', self.min_label, size: 12)]))])

    content_tag(:tr, html)
  end

  # This method returns what to display if an instructor (etc.) is viewing a questionnaire
  def view_question_text
    score_range = self.questionnaire.min_question_score.to_s + ' to ' + self.questionnaire.max_question_score.to_s
    score_txt = (self.max_label.empty? || self.min_label.empty?) ? score_range : '(' + self.min_label + ') ' + score_range + ' (' + self.max_label + ')'

    content_tag(:tr, safe_join([content_tag(:td, self.txt, align: 'left'),
                                content_tag(:td, self.type, align: 'left'),
                                content_tag(:td, self.weight, align: 'center'),
                                content_tag(:td, score_txt, align: 'center')]))
  end

  def complete(count, questionnaire_min, questionnaire_max, dropdown_or_scale, answer = nil)
    html = content_tag(:div, label_tag('responses_' + count.to_s, self.txt))
    html << view_question_advices(count)
    html << view_dropdown_section(count, questionnaire_min, questionnaire_max, answer) if dropdown_or_scale == 'dropdown'
    html << view_scale_section(count, questionnaire_min, questionnaire_max, answer) if dropdown_or_scale == 'scale'
    html
  end

  # called by "complete" --> returns html code to show advice for each criterion question
  def view_question_advices(count)
    question_advices = QuestionAdvice.where(question_id: self.id).sort_by(&:id)

    if !question_advices.empty? and advice_total_length(question_advices) > 0
      function_advice = 'function showAdvice(i){'\
                        'var element = document.getElementById("showAdivce_" + i.toString());'\
                        'var show = element.innerHTML == "Hide advice";'\
                        'if (show){'\
                        'element.innerHTML="Show advice";'\
                        '}else{'\
                        'element.innerHTML="Hide advice";}'\
                        'toggleAdvice(i);}'\
                        'function toggleAdvice(i) {'\
                        'var elem = document.getElementById(i.toString() + "_myDiv");'\
                        'if (elem.style.display == "none") {'\
                        'elem.style.display = "";'\
                        '} else {'\
                        'elem.style.display = "none";}}'

      return safe_join([link_to('Show advice', '#', id: 'showAdivce_' + self.id.to_s, onclick: 'showAdvice(' + self.id.to_s + ')'),
                        javascript_tag(function_advice),
                        content_tag(:div, question_advices_links(count, question_advices), id: self.id.to_s + '_myDiv', style: 'display: none;')])
    end
  end

  # returns total length of all question advices
  def advice_total_length(question_advices)
    length = 0
    question_advices.each do |question_advice|
      length += question_advice.advice.length if question_advice.advice && question_advice.advice != ""
    end
    length
  end

  # returns the html code for links, script for all the question advices in reverse order
  def question_advices_links(count, question_advices)
    # [2015-10-26] Zhewei:
    # best to order advices high to low, e.g., 5 to 1
    # each level used to be a link;
    # clicking on the link caused the dropbox to be filled in with the corresponding number
    advice_links = ''
    function_changescore = 'function changeScore(i, j) {' \
                            'var elem = jQuery("#responses_" + i.toString() + "_score");'\
                            'var opts = elem.children("option").length;'\
                            'elem.val((' + self.questionnaire.max_question_score.to_s + ' - j).toString());}'
    question_advices.reverse.each_with_index do |question_advice, index|
      link_name = (self.questionnaire.max_question_score - index).to_s + ' - ' + question_advice.advice
      advice_links = safe_join([advice_links,
                                link_to(link_name, '#', id: 'changeScore_' + self.id.to_s, onclick: 'changeScore(' + count.to_s + ',' + index.to_s + ')'),
                                tag(:br),
                                javascript_tag(function_changescore)])
    end
    advice_links
  end

  # called by "complete" --> returns html code for the dropdown section
  def view_dropdown_section(count, questionnaire_min, questionnaire_max, answer)
    # TODO: Figure out how to put 'data-current-rating' attribute in select tag
    # value in option tags are in double quotes instead of none
    # current_value = ''
    # current_value += 'data-current-rating=' + answer.answer.to_s unless answer.nil?
    container = container_for_options(questionnaire_min, questionnaire_max)
    selected = answer.nil? ? nil : answer.answer
    safe_join([content_tag(:div, select_tag('responses[' + count.to_s + '][score]', options_for_select(container, selected), class: 'review-rating')),
               tag(:br), tag(:br),
               text_area_tag('responses[' + count.to_s + '][comment]', answer.nil? ? '' : answer.comments, class: 'tinymce')])
  end

  # get the container (txt, value) for all the option tags in dropdown section
  def container_for_options(questionnaire_min, questionnaire_max)
    container = [['--', '']]
    questionnaire_min.upto(questionnaire_max).each do |j|
      txt = j.to_s
      if j == questionnaire_min && self.min_label.present?
        txt << '-' + self.min_label
      elsif j == questionnaire_max && self.max_label.present?
        txt << '-' + self.max_label
      end
      container << [txt, j]
    end
    container
  end

  # called by "complete" --> returns html code for the scale section
  def view_scale_section(count, questionnaire_min, questionnaire_max, answer)
    if self.size.empty?
      cols = '70'
      rows = '1'
    else
      cols = self.size.split(',')[0]
      rows = self.size.split(',')[1]
    end

    td1 = view_labels_row(questionnaire_min, questionnaire_max)
    td2 = view_radio_buttons_row(count, questionnaire_min, questionnaire_max, answer)

    safe_join([hidden_field_tag('responses[' + count.to_s + '][score]', answer.nil? ? nil : answer.answer),
               content_tag(:table, safe_join([content_tag(:tr, td1), content_tag(:tr, td2)])),
               text_area_tag('responses[' + count.to_s + '][comment]', answer.nil? ? '' : answer.comments, class: 'tinymce', cols: cols, rows: rows)])
  end

  # retuns html code for the first table row in scale section
  def view_labels_row(questionnaire_min, questionnaire_max)
    td = content_tag(:td, '', width: '10%')
    (questionnaire_min..questionnaire_max).each do |j|
      td = safe_join([td, content_tag(:td, label_tag(nil, j), width: '10%')])
    end
    safe_join([td, content_tag(:td, '', width: '10%')])
  end

  # return html code for the second table row in scale section
  def view_radio_buttons_row(count, questionnaire_min, questionnaire_max, answer)
    td = content_tag(:td, self.min_label.nil? ? '' : self.min_label, width: '10%')
    (questionnaire_min..questionnaire_max).each do |j|
      checked = (!answer.nil? and answer.answer == j) or (answer.nil? and questionnaire_min == j)
      td = safe_join([td, content_tag(:td, radio_button_tag('Radio_' + self.id.to_s, j, checked, id: j), width: '10%')])
    end

    jquery_script = 'jQuery("input[name=Radio_' + self.id.to_s + ']:radio").change(function() {'\
                    'var response_score = jQuery("#responses_' + count.to_s + '_score");'\
                    'var checked_value = jQuery("input[name=Radio_' + self.id.to_s + ']:checked").val();'\
                    'response_score.val(checked_value);});'
    safe_join([td,
               javascript_tag(jquery_script),
               content_tag(:td, self.max_label.nil? ? '' : self.max_label, width: '10%'),
               content_tag(:td, '', width: '10%')])
  end

  # This method returns what to display if a student is viewing a filled-out questionnaire
  def view_completed_question(count, answer, questionnaire_max, tag_prompt_deployments = nil, current_user = nil)
    td = score_cell(answer, questionnaire_max)
    td << comments_cell(answer, tag_prompt_deployments, current_user) if answer && !answer.comments.nil?

    safe_join([content_tag(:b, safe_join([count.to_s, '. ', self.txt, ' [Max points: ', questionnaire_max.to_s, ']'])),
               content_tag(:table, content_tag(:tr, td), cellpadding: '5')])
  end

  # chooses class for html tag based on score_percent
  def score_class(score_percent)
    if score_percent > 0.8 then 'c5'
    elsif score_percent > 0.6 then 'c4'
    elsif score_percent > 0.4 then 'c3'
    elsif score_percent > 0.2 then 'c2'
    else 'c1'
    end
  end

  # returns the html code for the table cell displaying the scores in the questionnaire
  def score_cell(answer, questionnaire_max)
    if answer && !answer.answer.nil?
      score = answer.answer.to_s
      score_percent = answer.answer * 1.0 / questionnaire_max
    else
      score = '-'
      score_percent = 0
    end
    div_style = 'width:30px; height:30px; border-radius:50%; font-size:15px; color:black; line-height:30px; text-align:center;'
    content_tag(:td, content_tag(:div, score, class: score_class(score_percent), style: div_style))
  end

  # returns the html code for the table cell displaying the comments in the questionnaire
  def comments_cell(answer, tag_prompt_deployments, current_user)
    td = content_tag(:td, safe_join([tag(:br), answer.comments]), style: 'padding-left:10px')
    td << view_tag_prompts(answer, tag_prompt_deployments, current_user) if !tag_prompt_deployments.nil? && tag_prompt_deployments.count > 0
    td
  end

  # returns the html code for the all the tag prompts for the comments
  def view_tag_prompts(answer, tag_prompt_deployments, current_user)
    # show check boxes for answer tagging
    question = Question.find(answer.question_id)
    tag_html = ''
    tag_prompt_deployments.each do |tag_dep|
      tag_prompt = TagPrompt.find(tag_dep.tag_prompt_id)
      if tag_dep.question_type == question.type and answer.comments.length > tag_dep.answer_length_threshold.to_i
        tag_html = safe_join([tag_html, tag_prompt.html_control(tag_dep, answer, current_user)])
      end
    end
    content_tag(:tr, content_tag(:td, tag_html, colspan: '2'))
  end
end
