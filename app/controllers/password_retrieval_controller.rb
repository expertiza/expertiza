class PasswordRetrievalController < ApplicationController

  def forgotten
  end
 
  def send_password
    if params[:user][:email].nil? or params[:user][:email].strip.length == 0
      flash[:pwerr] = "Please enter an e-mail address"     
    else
      user = User.find_by_email(params[:user][:email])
      if user != nil
        clear_password = ParticipantsHelper.assign_password(8)
        user.send_password(clear_password)    
        flash[:pwnote] = "A new password has been sent to your e-mail address."
      else
        flash[:pwerr] = "No account is associated with the address, \""+params[:user][:email]+"\". Please try again."
      end
    end
    redirect_to :action => 'forgotten'
   end 

end
