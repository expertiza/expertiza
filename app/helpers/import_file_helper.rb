require 'csv'

module ImportFileHelper

  def self.define_attributes(row_hash)
    attributes = {}
    attributes["role_id"] = Role.student.id
    attributes["name"] = row_hash[:name]
    attributes["fullname"] = row_hash[:fullname]
    attributes["email"] = row_hash[:email]
    attributes["email_on_submission"] = 1
    attributes["email_on_review"] = 1
    attributes["email_on_review_of_review"] = 1
    attributes
  end

  def self.create_new_user(attributes, session)
    user = User.new(attributes)
    user.parent_id = (session[:user]).id
    user.timezonepref = User.find(user.parent_id).timezonepref
    user.save!
    user
  end

end
