module Api::V1
class ProfileController < BasicApiController
  #  skip_before_action :authenticate, only: [:index]
   
  def action_allowed?
    current_user
  end

  def index
    @user = current_user
    @assignment_questionnaire = AssignmentQuestionnaire.where('user_id = ? and assignment_id is null and questionnaire_id is null', @user.id).first
     render json: { status: :ok, user: @user.as_json(except: [:crypted_password, :password_salt]), aq: @assignment_questionnaire}
    # render json: @user.as_json(except: [:id])
  end   

   def update
    params.permit!
    @user = current_user
    @aq = AssignmentQuestionnaire.where(['user_id = ? and assignment_id is null and questionnaire_id is null', @user.id]).first
    unless (params[:user][:password].nil? or params[:user][:password].blank?)
      puts Digest::SHA1.hexdigest(@user.password_salt+params[:user][:password])
      @user.update_attribute('crypted_password', Digest::SHA1.hexdigest(@user.password_salt+params[:user][:password]))
    end
    if( @user.update_attributes(params[:user].except!(:password)))
        ExpertizaLogger.info LoggerMessage.new(controller_name, @user.name, "Your profile was successfully updated.", request)
        render json: { status: :ok, user: @user.as_json(except: [:crypted_password, :password_salt]), aq: @aq}
        flash[:success] = 'Your profile was successfully updated.'
    else
       ExpertizaLogger.error LoggerMessage.new(controller_name, @user.name, "An error occurred and your profile could not updated.", request)
        render json: @user.errors, status: :unprocessable_entity
       flash[:error] = 'An error occurred and your profile could not updated.'
    end
   end

  private
  def user_params
    params.require(:user).permit(:name,
                                 :crypted_password,
                                 :role_id,
                                 :password_salt,
                                 :fullname,
                                 :email,
                                 :parent_id,
                                 :private_by_default,
                                 :mru_directory_path,
                                 :email_on_review,
                                 :email_on_submission,
                                 :email_on_review_of_review,
                                 :is_new_user,
                                 :master_permission_granted,
                                 :handle,
                                 :digital_certificate,
                                 :persistence_token,
                                 :timezonepref,
                                 :public_key,
                                 :copy_of_emails,
                                 :institution_id)
  end
  end
end
