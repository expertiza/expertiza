class TrueFalse < QuizQuestion
  def edit
    quiz_question_choices = QuizQuestionChoice.where(question_id: self.id)
    capture do
      concat content_tag(:tr,
                         content_tag(:td,
                                     content_tag(:textarea, self.txt, {cols: '100', name: 'question[' + self.id.to_s + '][txt]',
                                                                       id: 'question_' + self.id.to_s + '_txt'}, false), {}, false), {}, false)
      concat radio_content_tag(quiz_question_choices[0], 'True')
      concat radio_content_tag(quiz_question_choices[1], 'False')
    end
  end

  def complete
    quiz_question_choices = QuizQuestionChoice.where(question_id: self.id)
    capture do
      concat content_tag(:label, self.txt, {for: '"' + self.id.to_s + '"'}, false)
      concat input_tag(quiz_question_choices, 0)
      concat input_tag(quiz_question_choices, 1)
    end
  end

  def view_completed_question(user_answer)
    quiz_question_choices = QuizQuestionChoice.where(question_id: self.id)
    is_correct_text = quiz_question_choices[0].iscorrect ? 'True' : 'False'
    image_source = user_answer.first.answer == 1 ? '/assets/Check-icon.png' : '/assets/delete_icon.png'
    capture do
      concat 'Correct Answer is: '
      concat content_tag(:b, is_correct_text, {}, false)
      concat 'Your answer is: '
      concat content_tag(:b,
                         capture do
                           concat user_answer.first.comments.to_s
                           concat tag(:img, {src: image_source}, false, false)
                         end, {}, false)
      concat tag('br', {}, false, false)
      concat tag('br', {}, true, false)
      concat tag('br', {}, true, false)
      concat tag('hr', {}, true, false)
    end
  end

  def isvalid(choice_info)
    valid = self.txt == '' ? 'Please make sure all questions have text' : 'valid'
    correct_count = 0
    choice_info.each_value do |value|
      if value[:txt] == ''
        valid = 'Please make sure every question has text for all options'
        break
      end
      correct_count += 1 if value.key?(:iscorrect)
    end
    return('Please select a correct answer for all questions') if correct_count.zero?
    valid
  end

  private def radio_content_tag(quiz_question_choice, choice)
    input_hash = {type: 'radio', name: 'quiz_question_choices[' + self.id.to_s + '][TrueFalse][1][iscorrect]',
                  id: 'quiz_question_choices_' + self.id.to_s + '_TrueFalse_1_iscorrect_True', value: 'True'}
    input_hash[:checked] = 'checked' if quiz_question_choice.iscorrect
    content_tag(:tr,
                content_tag(:td,
                            capture do
                              concat tag(:input, input_hash, false, false)
                              concat choice
                            end, {}, false), {}, false)
  end

  private def input_tag(quiz_question_choices, i)
    text = %w[True False]
    content_tag(:br,
                capture do
                  concat tag(:input, {name: "\"#{self.id}\" ", id: "\"#{self.id}" + "_" + "#{i + 1}\" ",
                                      value: "\"#{quiz_question_choices[i].txt}\" ", type: 'radio'}, false, false)
                  concat text[i]
                end, {}, false)
  end
end
