class PasswordRetrievalController < ApplicationController

  def forgotten
  end
<<<<<<< HEAD
 
=======
<<<<<<< HEAD
<<<<<<< HEAD
 
=======

>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======

>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
  def send_password
    if params[:user][:email].nil? or params[:user][:email].strip.length == 0
      flash[:pwerr] = "Please enter an e-mail address"     
    else
      user = User.find_by_email(params[:user][:email])
      if user
<<<<<<< HEAD
        user.reset_and_mail_password
=======
<<<<<<< HEAD
<<<<<<< HEAD
        user.reset_and_mail_password
=======
        password = user.reset_password         # the password is reset
        MailerHelper::send_mail_to_user(user, "Your Expertiza password has been reset", "send_password", password)   # MailerHelper which sends the mail to user with the reset password.
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
        password = user.reset_password         # the password is reset
        MailerHelper::send_mail_to_user(user, "Your Expertiza password has been reset", "send_password", password)   # MailerHelper which sends the mail to user with the reset password.
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
        flash[:pwnote] = "A new password has been sent to your e-mail address."
      else
        flash[:pwerr] = "No account is associated with the address, \""+params[:user][:email]+"\". Please try again."
      end
    end
    redirect_to :action => 'forgotten'
   end 

end
