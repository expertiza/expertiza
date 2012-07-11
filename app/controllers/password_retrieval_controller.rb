class PasswordRetrievalController < ApplicationController

  def forgotten
  end

  #####
  #   Reset the user's password and email it to the user
  #####
  def reset_password
    email_address = params[:user][:email]

    if missingEmailAddress?(email_address)
      flash[:pwerr] = "Please enter an e-mail address"     
    else
      resetUserPassword(email_address)
    end

    redirect_to :action => 'forgotten'
  end

  private

  ####
  #  Ensure an email address was submitted by the user
  ####
  def missingEmailAddress?(email_address)
    (email_address.nil?) or (email_address.strip.length == 0)
  end

  ####
  # Reset the user's password and email it to the user
  ####
  def resetUserPassword(email_address)
    #Find the user's record in the database
    user = User.find_by_email(email_address)

    #If the user exists, then reset the password and send it in an email to the user
    if user
      sendUserPassword(user, user.reset_password)
      flash[:pwnote] = "A new password has been sent to your e-mail address."
    else
      #The user was not found in the database under the submitted email address
      flash[:pwerr] = "No account is associated with the address, \"" + email_address + "\". Please try again."
    end
  end

  ####
  #    Send an email to the user containing the newly generated password.
  #    Note, you can configure config/environments/<environment>.rb
  #    so the application can actually send emails.
  ####
  def sendUserPassword(user, password)
    MailerHelper::send_mail_to_user(user, "Your Expertiza password has been reset", "send_password", password)
  end
end
