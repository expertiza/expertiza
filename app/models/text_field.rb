class TextField < TextResponse
    include ActionView::Helpers
    def complete(count, answer = nil)
        html = if self.type == 'TextField' and self.break_before == true
        '<li>'
        else ''
    end
    html += combine(count, answer)
    safe_join([" ".html_safe, " ".html_safe], html.html_safe)
end

def combline(count, answer = nil)
    html = complete_helper_response_scores(count) + complete_helper_response_comments(count)
    html += complete_helper_text(answer) + complete_helper_response_comments
    html += complete_helper_final_judge
    html
end

def complete_helper_response_scores(count)
    html = '<label for="responses_' + count.to_s + '">' + self.txt + '</label>'
    html += '<input id="responses_' + count.to_s + '_score" name="responses[' + count.to_s + '][score]" type="hidden" value="">'
    html
end

def complete_helper_response_comments(count)
    html = '<input id="responses_' + count.to_s + '_comments" label=' + self.txt + ' name="responses[' + count.to_s + '][comment]"'
    html
end

def complete_helper_text(answer = nil)
    html = 'size=' + self.size.to_s + ' type="text" value="' + answer.comments unless answer.nil? + '">'
    html
end

def complete_helper_final_judge
    html = '</li><BR/><BR/>' if self.type == 'TextField' and self.break_before == false
    html
end

def view_completed_question(count, answer)
    if self.type == 'TextField' and self.break_before == true
        html = view_helper_true(count, answer)
        html += '<BR/><BR/>' if Question.exists?(answer.question_id + 1) && Question.find(answer.question_id + 1).break_before == true
        else
        html = view_helper_false(answer)
    end
    safe_join([" ".html_safe, " ".html_safe], html.html_safe)
end

def view_helper_true(count, answer)
    html = '<b>' + count.to_s
    html += ". " + self.txt + "</b>"
    html += '&nbsp;&nbsp;&nbsp;&nbsp;'
    html += answer.comments
    html
end

def view_helper_false(answer)
    html = self.text
    html += answer.comments
    html += '<BR/><BR/>'
    html
end
end
