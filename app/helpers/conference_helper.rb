module ConferenceHelper
  def is_valid_conference_assignment?
    # if assignment id is present in url the check if it's a valid conference assignment.
    unless params[:assignment_id].nil?
      @assignment = Assignment.find_by_id(params[:assignment_id])
      if !@assignment.nil? && @assignment.is_conference_assignment
        true
      else
        false
      end
    end
  end

  def current_user_has_admin_rights
    ['Super-Administrator',
     'Administrator',
     'Instructor',
     'Teaching Assistant'].include? current_role_name
  end

  def add_conference_user_as_participant
    # Author added as participant, function written in Conference Helper
    add_participant_coauthor
    flash[:success] = 'You are added as an Author for assignment ' + @assignment.name
    redirect_to get_redirect_url_link
  end

  def get_redirect_url_link
    # if conference user is already logged in the redirect to Student_task list page
    # else redirect to login page.
    if current_user && current_role_name == 'Student'
      '/student_task/list'
    else
      '/'
    end
  end

  def create_author
    params[:user][:username] = params[:user][:email] unless !params[:user][:username].nil? && !params[:user][:username].empty?
    is_author = true
    # Assign all user params for creating author using assign_user_params function
    @user = assign_user_params(is_author)
    if @user.save
      User.set_callback(:create, :after, :email_welcome)
      password = @user.reset_password # the password is reset
      # Mail to be sent to Author once the user has been created. New partial is used as content for email is different from normal user
      prepared_mail = MailerHelper.send_mail_for_conference_user(@user, 'Your Expertiza account and password have been created.', 'author_conference_invitation', password, @assignment.name)
      prepared_mail.deliver_now
      flash[:success] = "A new password has been sent to new user's e-mail address."
    else
      raise 'Error occurred while creating expertiza account.'
    end
  end

  def create_coauthor
    check = User.find_by(username: params[:user][:name])
    params[:user][:name] = params[:user][:email] unless check.nil?
    User.skip_callback(:create, :after, :email_welcome)
    is_author = false
    # Assign all user params for creating co-author using assign_user_params function
    @new_user = assign_user_params(is_author)
    # creating user with the parameters provided
    if @new_user.save
      @user = User.find_by(email: @new_user.email)
      User.set_callback(:create, :after, :email_welcome)
      # password is regenerated so that we could provide it in a mail
      password = @user.reset_password
      # Mail to be sent to co-author once the user has been created. New partial is used as content for email is different from normal user
      MailerHelper.send_mail_for_conference_user(@user, 'Your Expertiza account has been created.', 'user_conference_invitation', password, current_user.username).deliver
      @user
    end
  end

  # Function to add Author/co-author as participant in conference type assignment
  def add_participant_coauthor
    # Check if Assignment Participant already exists
    @participant = AssignmentParticipant.where('user_id = ? and parent_id = ?', @user.id, @assignment.id).first
    if @participant.nil?
      new_participant = AssignmentParticipant.create(parent_id: @assignment.id,
                                                     user_id: @user.id,
                                                     permission_granted: @user.master_permission_granted,
                                                     can_submit: true,
                                                     can_review: false,
                                                     can_take_quiz: true)
      new_participant.set_handle
    end
  end

  def assign_user_params(is_author)
    @user = User.new(user_params)
    # Checks if its a co-author
    if !is_author
      @user.email = params[:user][:username]
      # parent_id denotes who created the co-author
      @user.parent_id = session[:user].id
      # co-author role is same as student hence role_id =1
      @user.role_id = Role.find_by(name: 'Student').id

    # If not a co-author, check if its a author or an user created by an instructor
    else
      # To check if its a author we need to check if the passed assignment is of conference type.
      if is_valid_conference_assignment?
        # set default value for institute
        @user.institution_id = nil
        # parent id for a conference user will be conference assignment instructor id
        @user.parent_id = Assignment.find(params[:user][:assignment]).instructor.id
        # set the user's timezone to its parent's
        @user.timezonepref = User.find(@user.parent_id).timezonepref

      else
        @user.institution_id = params[:user][:institution_id]
        # record the person who created this new user
        @user.parent_id = session[:user].id
        # set the user's timezone to its parent's
        @user.timezonepref = User.find(@user.parent_id).timezonepref
      end
    end
    @user
  end

  def user_params
    params.require(:user).permit(:username,
                                 :name,
                                 :role_id,
                                 :email,
                                 :parent_id,
                                 :institution_id)
  end
end
