class CallGoogledocController < ApplicationController
  def action_allowed?
    ['Student',
     'Instructor',
     'Teaching Assistant'].include? current_user.role.name
  end

  def make_doc
    g = GoogledocController.new()
    doc = g.insert_file('My file_1', 'File stuff', nil, 'application/vnd.google-apps.document', "#{Rails.root}/config/test.txt")
    #render :text => "webllink -->>>>> #{doc.webViewLink} ------"
  end
end