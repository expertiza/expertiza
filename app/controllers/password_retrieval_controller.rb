class PasswordRetrievalController < ApplicationController

  def action_allowed?
    true
  end

  def forgotten
  end

  def send_password
    if params[:user][:email].nil? || params[:user][:email].strip.length == 0
      flash[:error] = "Please enter an e-mail address"
    else
      user = User.find_by_email(params[:user][:email])
      if user
        password = user.reset_password         # the password is reset
        MailerHelper::send_mail_to_user(user, "Your Expertiza password has been reset", "send_password", password).deliver
        flash[:success] = "A new password has been sent to your e-mail address."
      else
        flash[:error] = "No account is associated with the address, \""+params[:user][:email]+"\". Please try again."
      end
    end
    redirect_to :action => 'forgotten'
  end
end
