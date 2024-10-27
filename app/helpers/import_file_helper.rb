require 'csv'

module ImportFileHelper
  def self.define_attributes(row_hash)
    attributes = {}
    attributes['role_id'] = Role.student.id
    attributes['username'] = row_hash[:username]
    attributes['fullname'] = row_hash[:fullname]
    attributes['email'] = row_hash[:email]
    attributes['email_on_submission'] = 1
    attributes['email_on_review'] = 1
    attributes['email_on_review_of_review'] = 1
    # Handle is set to the users' name by default; when a new user is created
    attributes['handle'] = row_hash[:username]
    attributes
  end

  def self.create_new_user(attributes, session)
    @user = User.new(attributes)
    @user.parent_id = (session[:user]).id
    @user.timezonepref = User.find(@user.parent_id).timezonepref
    if @user.save!
      password = @user.reset_password # the password is reset
      prepared_mail = MailerHelper.send_mail_to_user(@user, 'Your Expertiza account and password have been created.', 'user_welcome', password)
      prepared_mail.deliver
    end
    @user
  end
end
