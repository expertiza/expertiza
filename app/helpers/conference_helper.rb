module ConferenceHelper

  #Function to create co-author for conference type assignment
  def create_coauthor
    check = User.find_by(name: params[:user][:name])
    params[:user][:name] = params[:user][:email] unless check.nil?
    @new_user = User.new(user_params)
    @new_user.institution_id =nil
    @new_user.email = params[:user][:name]

    #parent_id denotes who created the co-author
    @new_user.parent_id = session[:user].id

    #co-author role is same as student hence role_id =1
    @new_user.role_id = 1

    #creating user with the parameters provided
    if @new_user.save
      @user = User.find_by(email: @new_user.email)

      #password is regenerated so that we could provide it in a mail
      password = @user.reset_password

      #Mail to be sent to co-author once the user has been created. New partial is used as content for email is different from normal user
      MailerHelper.send_mail_to_coauthor(@user, "Your Expertiza account has been created.", "user_conference_invitation", password,current_user.name).deliver
      return @user
    end
  end

  #Function to add co-author as participant in conference type assignment
  def add_participant_coauthor
    new_part = AssignmentParticipant.create(parent_id: @assignment.id,
                                            user_id: @user.id,
                                            permission_granted: @user.master_permission_granted,
                                            can_submit: 1,
                                            can_review: 1,
                                            can_take_quiz: 1)

    #set_handle from assignment controller is called
    new_part.set_handle
  end

  #User parameters for creating co-author, we require only minimum set of parameters.
  def user_params
    params.require(:user).permit(:name,
                                 :role_id,
                                 :email,
                                 :parent_id,
                                 :institution_id)
  end
end
