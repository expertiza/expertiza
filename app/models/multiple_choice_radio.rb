class MultipleChoiceRadio < QuizQuestion
  def edit(count)
    html = '<tr>'
    html += '<td align="center"><a rel="nofollow" data-method="delete" href="/questions/' + self.id.to_s + '">Remove</a></td>'
    html += '<td><input size="6" value="' + self.seq.to_s + '" name="question[' + self.id.to_s + '][seq]" id="question_' + self.id.to_s + '_seq" type="text"></td>'
    html += '<td><textarea cols="50" rows="1" name="question[' + self.id.to_s + '][txt]" id="question_' + self.id.to_s + '_txt" placeholder="Edit question content here">' + self.txt + '</textarea></td>'
    html += '<td><input size="20" disabled="disabled" value="' + self.type + '" name="question[' + self.id.to_s + '][type]" id="question_' + self.id.to_s + '_type" type="text">''</td>'
    html += '</tr>'

    questionnum=self.id
    @quiz_question_choices = QuizQuestionChoice.where(question_id: self.id)

    for @quiz_question_choice in @quiz_question_choices
      html = '<tr>'
      html += '<td>'
      radio_button_tag("quiz_question_choices[#{questionnum}][MultipleChoiceRadio][correctindex]", "#{count}", @quiz_question_choice.iscorrect)
      html = '&nbsp;'
      text_field_tag "quiz_question_choices[#{questionnum}][MultipleChoiceRadio][#{count}][txt]", @quiz_question_choice.txt, :size=>40

      html += '</td>'
      html += '</tr>'
    end

    html.html_safe
  end

  def complete(count, answer = nil)
    @question = self
    html = ""
    html += label_tag("#{question.id}", question.txt) +""
    quiz_question_choices = QuizQuestionChoice.where(question_id: @question.id)
    quiz_question_choices.each do |choice|
      if answer=="view"
        html += radio_tag("#{question.id}[]", "#{choice.txt}", choice.iscorrect)
        html += label_tag("#{choice.txt}", choice.txt) + ""
      end
      if answer=="take"
        html += radio_tag("#{question.id}[]", "#{choice.txt}")
        html += label_tag("#{choice.txt}", choice.txt) + ""
      end

      html.html_safe
    end
  end

  def view_completed_question(count, answer)
    @question = self
    html=""
    html+= "Correct Answer is: "
    html+= QuizQuestionChoice.where(question_id: @question.id,iscorrect: 1).first.txt
    html+= ""
    html+= "Your answer is: "
    html+= answer.first.comments + ""
    if(answer.first.answer == 1)
      html+= "<img src=/assets/Check-icon.png/>"
    else
      html+= "<img src=/assets/delete_icon.png/>"
    end
    html+= ""
  end


  def view_question_text
    html = "<b>" + self.txt + '</b><br />'
    html += "Question Type: " + self.type + '<br />'
    if self.quiz_question_choices
      self.quiz_question_choices.each do |choices|
        html += if choices.iscorrect?
                  "  - <b>" + choices.txt + "</b><br /> "
                else
                  "  - " + choices.txt + "<br /> "
                end
      end
      html += '<br />'
    end

    html.html_safe
  end

end
