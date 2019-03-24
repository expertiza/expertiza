class SectionHeader < QuestionnaireHeader
  include ActionView::Helpers

  def complete(_count, _answer = nil)
    capture do
      concat make_header
      concat tag("br")
      concat tag("br")
    end
  end

  def view_completed_question(_count, _answer)
    make_header
  end

  private def make_header
    content_tag(:b, self.txt, {style: "color: #986633", 'font-size': "x-large"}, false)
  end
end
