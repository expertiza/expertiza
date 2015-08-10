class TableHeader < QuestionnaireHeader
  def complete(count, answer=nil)
  	html = '<br/><big><b>' +self.txt+ '</b></big><br/>'
  	html += '<table class="general" style="border: 2; text-align: left; width: 100%">'
    html.html_safe
  end
  def view_completed_question(count, answer)
  	html = '<br/><big><b>' +self.txt+ '</b></big><br/>'
  	html += '<table class="general" style="border: 2; text-align: left; width: 100%">'
    html.html_safe 
  end
end