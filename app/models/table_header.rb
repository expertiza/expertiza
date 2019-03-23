class TableHeader < QuestionnaireHeader
  def complete(_count, _answer = nil)
    html = '<br/><big><b>' + self.txt + '</b></big><br/>'
    html += '<table class="general" style="border: 2; text-align: left; width: 100%">'
    html
  end

  def view_completed_question(_count, _answer)
    html = '<br/><big><b>' + self.txt + '</b></big><br/>'
    html += '<table class="general" style="border: 2; text-align: left; width: 100%">'
    html
  end
end
