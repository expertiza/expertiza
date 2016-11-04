class TextResponse < Question
    validates :size, presence: true
    include ActionView::Helpers
    # This method returns what to display if an instructor (etc.) is creating or editing a questionnaire (questionnaires_controller.rb)
    def edit(_count)
        html = edit_link + edit_question_lable
        html += edit_question_textarea + edit_question_textarea_size
        safe_join(["<tr>".html_safe, "</tr>".html_safe], html.html_safe)
    end
    
    def edit_link(_count)
        html = '<td align="center"><a rel="nofollow" data-method="delete" href="/questions/' + self.id.to_s + '">Remove</a></td>'
        html += '<td><input size="6" value="' + self.seq.to_s + '" name="question[' + self.id.to_s + '][seq]"'
        html
    end
    
    def edit_question_lable(_count)
        html = 'id="question_' + self.id.to_s + '_seq" type="text"></td>'
        html += '<td><textarea cols="50" rows="1" name="question[' + self.id.to_s + '][txt]"'
        html += 'id="question_' + self.id.to_s + '_txt" placeholder="Edit question content here">' + self.txt + '</textarea></td>'
        html
    end
    
    def edit_question_textarea(_count)
        html = '<td><input size="10" disabled="disabled" value="' + self.type + '" name="question[' + self.id.to_s + '][type]"'
        html += 'id="question_' + self.id.to_s + '_type" type="text">''</td>'
        html += '<td><!--placeholder (TextResponse does not need weight)--></td>'
        html
    end
    
    def edit_question_textarea_size(_count)
        html = '<td>text area size <input size="6" value="' + self.size.to_s + '" name="question[' + self.id.to_s + '][size]"'
        html += 'id="question_' + self.id.to_s + '_size" type="text"></td>'
        html
    end
    
    # This method returns what to display if an instructor (etc.) is viewing a questionnaire
    def view_question_text
        html = view_selftext + view_weight
        safe_join(["<tr>".html_safe, "</tr>".html_safe], html.html_safe)
    end
    
    def view_selftxt
        html = '<TD align="left"> ' + self.txt + ' </TD>'
        html += '<TD align="left">' + self.type + '</TD>'
        html
    end
    
    def view_weight
        html = '<td align="center">' + self.weight.to_s + '</TD>'
        html += '<TD align="center">&mdash;</TD>'
        html
    end
    
    def complete
    end
    
    def view_completed_question
    end
end
