require 'csv'

module ImportFileHelper
 
  def self.define_attributes(row)   
    attributes = {}
    attributes["role_id"] = Fixtures.identify(:Student_role)
    attributes["name"] = row[0].strip
    attributes["fullname"] = row[1]
    attributes["email"] = row[2].strip
    attributes["clear_password"] = row[3].strip
    attributes["email_on_submission"] = 1
    attributes["email_on_review"] = 1
    attributes["email_on_review_of_review"] = 1

    attributes

  end

  def self.create_new_user(attributes, session)
    user = User.new
    user.name = attributes.fetch("name")
    user.handle = attributes.fetch("name")
    user.parent_id = (session[:user]).id    
    user.fullname = attributes.fetch("fullname")
    user.email = attributes.fetch("email")
    user.role_id = attributes.fetch("role_id")
    user.email_on_review = attributes.fetch("email_on_review")
    user.email_on_submission = attributes.fetch("email_on_submission")
    user.email_on_review = attributes.fetch("email_on_review")
    
    user.save
   
    user     

   end
end


