class QuizQuestion < Question
  has_many :quiz_question_choices, :class_name => 'QuizQuestionChoice', :foreign_key => 'question_id'
  
  def edit(count)
    common_html = "<tr>"
    @question = self

    #Display the text (common for all questions)
    if $disp_flag != 1
      common_html += "<td>" + text_area("question[]", 'txt', cols: 100) + "</td>"
    end

    common_html += "</tr>"

    #Delegate specific functionality to type of question
    yield common_html
  end

  def view_question_text
    html = '<TR><TD align="left"> '+self.txt+' <br>'
    if self.quiz_question_choices
      self.quiz_question_choices.each do |choices|
        if choices.iscorrect?
          html += "  - <b>"+choices.txt+"</b><br> "
        else
          html += "  - "+choices.txt+"<br> "
        end
      end
    end

    html += ' </TD>'
    html += '<TD align="left">'+self.type+'</TD>'
    html += '<td align="center">'+self.weight.to_s+'</TD>'
    html += '<td align="center">0-1</td>'

    html += '</TR>'
    html.html_safe
  end

  def complete
  end

  def view_completed_question
  end

end
