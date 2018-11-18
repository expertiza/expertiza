module Api::V1
  class PasswordRetrievalController < BasicApiController
    skip_before_action :verify_authenticity_token 
    skip_before_action :authenticate
    include MailerHelper

    def forgottenPasswordSendLink 
      puts params
      flag = false
      if (!params[:user][:email].nil? )
        if(params[:user][:email].strip.empty?)
          flag = true
        end
      elsif(!params[:user][:username].nil?) 
        if(params[:user][:username].strip.empty?)
          flag = true
        end
      end

      if flag
        render json: {status: :ok , error: "Please enter an e-mail address." }
      else
        password_reset = true     
        if(params[:user][:email].nil?)
          user = User.find_by(name: params[:user][:username])
        else 
          user = User.find_by(email: params[:user][:email])
        end
        if user 
          url_format = "/password_edit/check_reset_url?token="
          token = SecureRandom.urlsafe_base64
          puts token
          PasswordReset.save_token(user, token)
          url = self.request.base_url + url_format + token
          puts url
          MailerHelper.send_mail_to_user(user, "Expertiza password reset", "send_password", url).deliver_now
          # ExpertizaLogger.info LoggerMessage.new(controller_name, user.name, 'A link to reset your password has been sent to users e-mail address.', request)
          render json: { status: :ok , token: token}
        else
          render json: { stauts: 406}
        end
      end
    end

    def forgottenPasswordUpdatePassword
      if params[:token].nil?
        render json:{status: 406,  error: "Password reset page can only be accessed with a generated link, sent to your email"}
      else
        puts params[:token].inspect
        @token = Digest::SHA1.hexdigest(params[:token])
        puts @token
        password_reset = PasswordReset.find_by(token: @token)
        if password_reset
          # URL expires after 1 day
          expired_url = password_reset.updated_at + 1.day
          if Time.now < expired_url
            # redirect_to action: 'reset_password', email: password_reset.user_email
            @email = password_reset.user_email
            validToken
          else
            ExpertizaLogger.error LoggerMessage.new(controller_name, '', 'User tried to access expired link!', request)
            render json: { status: 406, error: "Link expired . Please request to reset password again" }
          end
        else
          ExpertizaLogger.error LoggerMessage.new(controller_name, '', 'User tried to access either expired link or wrong token!', request)
          render json: { status: 406, error: "Link either expired or wrong Token. Please request to reset password again"}
        end
      end
    end

    def validToken
      if params[:reset][:password] == params[:reset][:repassword]
        user = User.find_by(email: params[:reset][:email])
        user.password = params[:reset][:password]
        user.password_confirmation = params[:reset][:repassword]
        if user.save
          PasswordReset.delete_all(user_email: user.email)
          ExpertizaLogger.info LoggerMessage.new(controller_name, user.name, 'Password was reset for the user', request)
          render json: {status: :ok}
        else
          ExpertizaLogger.error LoggerMessage.new(controller_name, user.name, 'Password reset operation failed for the user while saving record', request)
          render json: {status: 500, error: "Password cannot be updated. Please try again"}
        end
      else
        ExpertizaLogger.error LoggerMessage.new(controller_name, "", 'Password provided by the user did not match', request)
        render json: {status: 406, error: "Password and confirm-password do not match. Try again" }
      end
    end
  end
end



  
  # def send_password
  #   if params[:user][:email].nil? || params[:user][:email].strip.empty?
  #     flash[:error] = "Please enter an e-mail address."
  #   else
  #     user = User.find_by(email: params[:user][:email])
  #     if user
  #       url_format = "/password_edit/check_reset_url?token="
  #       token = SecureRandom.urlsafe_base64
  #       PasswordReset.save_token(user, token)
  #       url = self.request.base_url + url_format + token
  #       MailerHelper.send_mail_to_user(user, "Expertiza password reset", "send_password", url).deliver_now
  #       ExpertizaLogger.info LoggerMessage.new(controller_name, user.name, 'A link to reset your password has been sent to users e-mail address.', request)
  #       flash[:success] = "A link to reset your password has been sent to your e-mail address."
  #       redirect_to "/"
  #     else
  #       ExpertizaLogger.error LoggerMessage.new(controller_name, params[:user][:email], 'No user is registered with provided email id!', request)
  #       flash[:error] = "No account is associated with the e-mail address: \"" + params[:user][:email] + "\". Please try again."
  #       render template: "password_retrieval/forgotten"
  #     end
  #   end
  # end

  # # The token obtained from the reset url is first checked if it is valid ( if actually generated by the application), then checks if the token is active.
  # def check_reset_url
  #   if params[:token].nil?
  #     flash[:error] = 
  #     render json:{status: 406,  error: "Password reset page can only be accessed with a generated link, sent to your email"}
  #   else
  #     @token = Digest::SHA1.hexdigest(params[:token])
  #     password_reset = PasswordReset.find_by(token: @token)
  #     if password_reset
  #       # URL expires after 1 day
  #       expired_url = password_reset.updated_at + 1.day
  #       if Time.now < expired_url
  #         # redirect_to action: 'reset_password', email: password_reset.user_email
  #         @email = password_reset.user_email
  #         continue --->>>>
  #         render template: "password_retrieval/reset_password"
  #       else
  #         ExpertizaLogger.error LoggerMessage.new(controller_name, '', 'User tried to access expired link!', request)
  #         flash[:error] = 
  #         render json: { status: 406, error: "Link expired . Please request to reset password again" }
  #       end
  #     else
  #       ExpertizaLogger.error LoggerMessage.new(controller_name, '', 'User tried to access either expired link or wrong token!', request)
  #       render json: { status: 406, error: "Link either expired or wrong Token. Please request to reset password again"}
  #     end
  #   end
  # end

  # # avoid users to access this page without a valid token
  # def reset_password
  #   flash[:error] = "Password reset page can only be accessed with a generated link, sent to your email"
  #   render template: "password_retrieval/forgotten"
  # end

  # # called after entering password and repassword, checks for validation and updates the password of the email
  # def update_password
  #   if params[:reset][:password] == params[:reset][:repassword]
  #     user = User.find_by(email: params[:reset][:email])
  #     user.password = params[:reset][:password]
  #     user.password_confirmation = params[:reset][:repassword]
  #     if user.save
  #       PasswordReset.delete_all(user_email: user.email)
  #       ExpertizaLogger.info LoggerMessage.new(controller_name, user.name, 'Password was reset for the user', request)
  #       flash[:success] = "Password was successfully reset"
  #       redirect_to "/"
  #     else
  #       ExpertizaLogger.error LoggerMessage.new(controller_name, user.name, 'Password reset operation failed for the user while saving record', request)
  #       flash[:error] = "Password cannot be updated. Please try again"
  #       redirect_to "/"
  #     end
  #   else
  #     ExpertizaLogger.error LoggerMessage.new(controller_name, "", 'Password provided by the user did not match', request)
  #     flash[:error] = "Password and confirm-password do not match. Try again"
  #     @email = params[:reset][:email]
  #     render template: "password_retrieval/reset_password"
  #   end
  # end