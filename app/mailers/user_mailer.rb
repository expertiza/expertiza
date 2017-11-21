class UserMailer < ApplicationMailer
  def send_to_user(user,subject,partial_name,password)
    @user=user
    @message = partial_name
    @password = password
    mail(to:@user.email, subject:subject)
  end
end
