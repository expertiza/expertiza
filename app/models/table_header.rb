include ActionView::Helpers

class TableHeader < QuestionnaireHeader
  def complete(_count, _answer = nil)
    make_html
  end

  def view_completed_question(_count, _answer)
    make_html
  end

  def make_html
    capture do
      concat tag("br", nil, false, false)
      concat content_tag(:big, content_tag(:b, self.txt, {}, false), {}, false)
      concat tag("br", nil, false, false)
      concat tag("table", {:class => "general", :style => "border: 2; text-align: left; width: 100%"}, true, false)
    end
    # html = '<br/><big><b>' + self.txt + '</b></big><br/>'
    # html += '<table class="general" style="border: 2; text-align: left; width: 100%">'
  end
end
