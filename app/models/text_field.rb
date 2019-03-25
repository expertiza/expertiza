class TextField < TextResponse
  def complete(count, answer = nil)
    answer_comments = answer.comments.to_s unless answer.nil?
    capture do
      concat tag(:p, {style: "width: 80%;"}, true, false)
      concat content_tag(:label, self.txt + '&nbsp;&nbsp;', {for: 'responses_' + count.to_s}, false)
      concat tag(:input, {id: 'responses_' + count.to_s + '_score',
                          name: 'responses[' + count.to_s + '][score]', type: "hidden", value: ""}, true, false)
      concat tag(:input, {id: 'responses_' + count.to_s + '_comments', label: self.txt,
                          name: 'responses[' + count.to_s + '][comment]', style: "width: 40%;",
                          size: self.size.to_s, type: "text", value: answer_comments}, true, false)
      concat tag("br") if self.type == 'TextField' and !self.break_before
      concat tag("br") if self.type == 'TextField' and !self.break_before
    end
  end

  def view_completed_question(count, answer)
    if self.type == 'TextField' and self.break_before
      capture do
        concat content_tag(:b, count.to_s + ". " + self.txt, {}, false)
        concat raw("&nbsp;" * 4 + answer.comments.to_s)
        concat tag('br') if Question.exists?(answer.question_id + 1) && Question.find(answer.question_id + 1).break_before
        concat tag('br') if Question.exists?(answer.question_id + 1) && Question.find(answer.question_id + 1).break_before
      end
    else
      capture do
        concat self.txt + raw(answer.comments)
        concat tag("br")
        concat tag("br")
      end
    end
  end
end
