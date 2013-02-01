require 'csv'

module ImportFileHelper
 
  def self.define_attributes(row)   
    attributes = {}
    attributes["role_id"] = Role.student.id
    attributes["name"] = row[0].strip
    attributes["fullname"] = row[1]
    attributes["email"] = row[2].strip
    attributes["clear_password"] = row[3].strip
    attributes["clear_password_confirmation"] = attributes["clear_password"]
    attributes["email_on_submission"] = 1
    attributes["email_on_review"] = 1
    attributes["email_on_review_of_review"] = 1
    attributes
  end

  def self.create_new_user(attributes, session)
    user = User.new(attributes)
    user.parent_id = (session[:user]).id
    user.save!
   
    user 
  end
end


