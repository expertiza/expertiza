class PasswordRetrievalController < ApplicationController

  def action_allowed?
    true
  end

  def forgotten
  end

  #send_link controller sends the reset link to the email provided in the params[]. It checks whether the email id exists or not.
  def send_link
    if params[:user][:email].nil? || params[:user][:email].strip.length == 0
      flash[:error] = "Please enter an e-mail address"
    else
      users = User.where(email:params[:user][:email])
      if users.empty?
        flash[:error] = "No account is associated with the address, \""+params[:user][:email]+"\". Please try again."
      else
        users.each do |user|
          if user
            password = nil
            link = ExpiryLink.generate_link(user)
            MailerHelper::send_mail_to_user(user,"Reset your Expertiza Password","send_link",password,link).deliver_later
            flash[:success] = "The reset link has been sent to your e-mail address."
          end  
        end
      end
    end
    redirect_to :action => 'forgotten'
  end
  
  #reset_password controller is invoked when the user clicks the reset link in the email and generates the form to reset the password.
  def reset_password
    @expiry_link = ExpiryLink.where(link:params[:link]).first
    if @expiry_link and @expiry_link.is_valid?
      @user = User.find(@expiry_link.uid)
    else
      flash[:error] = "Link is expired or already used. Generate a new link."
      redirect_to action: 'forgotten'
    end
  end
 

end
