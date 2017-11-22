class UserMailer < ApplicationMailer
  def send_to_user(user,subject,partial_name,password)
    @user=user
    @message = partial_name
    @password = password
    mail(to:@user.email, subject:subject)
  end

  def send_to_request_user(user,subject,partial_name)
    @user=user
    @message = partial_name
    mail(to:@user.email, subject:subject)
  end
end
