class PasswordRetrievalController < ApplicationController

  def action_allowed?
    true
  end

  def forgotten
  end

  def send_link
    if params[:user][:email].nil? || params[:user][:email].strip.length == 0
      flash[:error] = "Please enter an e-mail address"
    else
      user = User.find_by_email(params[:user][:email])
      if user
        link = ExpiryLink.generate_link(params[:user][:email])
        MailerHelper::send_mail_to_user(user, "Reset your Expertiza Password", "send_link", link).deliver_later
        flash[:success] = "The reset link has been sent to your e-mail address."
      else
        flash[:error] = "No account is associated with the address, \""+params[:user][:email]+"\". Please try again."
      end
    end
    redirect_to :action => 'forgotten'
  end
  def reset_password
    @expiry_link = ExpiryLink.where(link:params[:link]).first
    if @expiry_link and @expiry_link.is_valid?
      @user = User.find_by_login(@expiry_link.email)
    else
      
      flash[:error] = "Link is expired or already used. Generate a new link."
      redirect_to action: 'forgotten'
    end
  end
 

end
