class TextArea < TextResponse
  include ActionView::Helpers

  def complete(count, answer = nil)
    if self.size.nil?
      cols = '70'
      rows = '1'
    else
      cols = self.size.split(',')[0]
      rows = self.size.split(',')[1]
    end
    text_area_text = answer.comments unless answer.nil?
    capture do
      concat content_tag(:p, content_tag(:label, self.txt, {for: 'responses_' + count.to_s}, false), {}, false)
      concat tag(:input, {id: 'responses_' + count.to_s + '_score', name: 'responses[' + count.to_s + '][score]',
                          type: "hidden", value: ""}, true, false)
      concat content_tag(:p,
                          content_tag(:textarea, text_area_text, {cols: cols, rows: rows, id: 'responses_' + count.to_s + '_comments',
                                                                  name: 'responses[' + count.to_s + '][comment]', class: "tinymce"}, false),
                          {}, false)
    end
  end

  def view_completed_question(count, answer)
    # html = '<b>' + count.to_s + ". " + self.txt + "</b><BR/>"
    # html += '&nbsp;' * 8 + answer.comments.gsub('^p', '').gsub(/\n/, '<BR/>') + #'<BR/><BR/>'
    # html

    capture do
      concat content_tag(:b, count.ts_s + ". " + self.txt, {}, false)
      concat tag("br")
      concat '&nbsp;' * 8 + answer.comments.gsub('^p', '').gsub(/\n/, '<BR/>')
      concat tag("br")
      concat tag("br")
    end
  end
end
