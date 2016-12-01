class CallGoogledocController < ApplicationController
  def action_allowed?
    ['Student',
     'Instructor',
     'Teaching Assistant'].include? current_user.role.name
  end

  def make_doc
    g = GoogledocController.new()
    g.insert_file('My file', 'File stuff', nil, 'text', "#{Rails.root}/config/test.txt")
  end
end