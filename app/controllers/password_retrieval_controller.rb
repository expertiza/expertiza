class PasswordRetrievalController < ApplicationController
  def action_allowed?
    true
  end

  def forgotten
  end

  def send_password
    if params[:user][:email].nil? || params[:user][:email].strip.empty?
      flash[:error] = "Please enter an e-mail address."
    else
      user = User.find_by_email(params[:user][:email])
      if user
        #password = user.reset_password # the password is reset
        token = SecureRandom.urlsafe_base64

        #method to be in password reset, with Time.now to point to next day
        #New Approach --rather than adding new rows, replace token if exists
        password_reset = PasswordReset.find_by(:user_email => user.email)
        if password_reset
          password_reset.token = token
          password_reset.save!
        else
          PasswordReset.create(:user_email => user.email, :token => token)
        end
        #---------------------------------------------------------------------
        #generate url // To be in a new method
        url = self.request.base_url+"/password_edit/check_reset_url?token="+token

        MailerHelper.send_mail_to_user(user, "Your Expertiza password has been reset", "send_password", url).deliver
        flash[:success] = "A new password has been sent to your e-mail address."
      else
        flash[:error] = "No account is associated with the e-mail address: \"" + params[:user][:email] + "\". Please try again."
      end
    end
    redirect_to action: 'forgotten'
  end

  def check_reset_url
    @token = params[:token]
    password_reset=PasswordReset.find_by(:token => @token)
    if password_reset
      #method in password_reset model to determine if url expired or not
      # URL expires after 1 day
      if password_reset.updated_at + 1.days < Time.now
        expired_url = true
      else
        expired_url = false
      end
      #---------------------------------------------------------------------
      if !expired_url
        redirect_to action: 'reset_password', email: password_reset.user_email
      else
        flash[:error] = "Link expired . Please request to reset password again"
        redirect_to "/"
      end
    else
      flash[:error] = "Link either expired or wrong Token. Please request to reset password again"
      redirect_to "/"
    end
  end

  def reset_password
    @email = params[:email]
  end

  def update_password
    #method to be in user model
    if params[:reset][:password] == params[:reset][:repassword]
      user=User.find_by(:email => params[:reset][:email])
      #hash value to be saved not actual password
      user.password = params[:reset][:password]
      user.password_confirmation = params[:reset][:repassword]
      if user.save
        flash[:success] = "reset password success"
        redirect_to "/"
      else
        flash[:error] = "password cannot be updated. Please try again"
        redirect_to "/"
      end
    else
      flash[:error] = "password and re-password do not match. Try again"
      redirect_to action: 'reset_password', email: params[:reset][:email]
    end
  end

end
