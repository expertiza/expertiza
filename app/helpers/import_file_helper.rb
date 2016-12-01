require 'csv'

module ImportFileHelper
  def self.define_attributes(row)
    attributes = {}
    attributes["role_id"] = Role.student.id
    attributes["name"] = row[0].strip
    attributes["fullname"] = row[1]
    attributes["email"] = row[2].strip
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
    prepared_mail = MailerHelper.send_mail_to_user(user, "Your Expertiza account and password have been created.", "user_welcome", user.password)
    prepared_mail.deliver
    user
    end
end
