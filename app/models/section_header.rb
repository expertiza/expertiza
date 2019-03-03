# Code Climate mistakenly reports
# "Mass assignment is not restricted using attr_accessible"
# https://github.com/presidentbeef/brakeman/issues/579

class SectionHeader < QuestionnaireHeader

  # https://makandracards.com/makandra/2579-everything-you-know-about-html_safe-is-wrong
  def complete(_count, _answer = nil)
    html = ''.html_safe
    html << '<b style="color: #986633; font-size: x-large">'.html_safe
    html << self.txt
    html << '</b><br/><br/>'.html_safe
    html
  end

  def view_completed_question(_count, _answer)
    html = ''.html_safe
    html << '<b style="color: #986633; font-size: x-large">'.html_safe
    html << self.txt
    html << '</b>'.html_safe
    html
  end
end
