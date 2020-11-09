module ConferenceHelper
    def is_valid_conference_assignment?
        #if assignment id is present in url the check if it's a valid conference assignment.
        if !params[:assignment_id].nil?
          @assignment = Assignment.find_by_id(params[:assignment_id])
          if !@assignment.nil? and @assignment.is_conference
            true
          else
            false
          end
       end
    end
    
    def check_role
        ['Super-Administrator',
            'Administrator',
            'Instructor',
            'Teaching Assistant'].include? current_role_name
    end

    def foreign
        # stores all the roles that are possible 
        # when a new user joins or an existing user updates his/her profile they will get to choose
        # from all the roles available
        # role = Role.find(session[:user].role_id)
         #if user creation call is for conference user then only possible role is Student
        # else  get all the roles types which logged in user can create as new user.
        if params[:assignment_id].nil?
          role = Role.find(session[:user].role_id)
        else
          role = Role.find_by_name('Student')
        end
        @all_roles = Role.where('id in (?) or id = ?', role.get_available_roles, role.id)
      
    end
    def add_conference_user_as_participant
        print("\n In add conference participant\n")
        # Author added as participant, function written in Conference Helper
        add_participant_coauthor
        flash[:success] = "You are added as an Author for assignment " + @assignment.name
        redirect_to get_redirect_url_link
    end
    
    def get_redirect_url_link
        #if conference user is already logged in the redirect to Student_task list page
        # else redirect to login page.
        if current_user && current_role_name == "Student"
            print('\n Going to student')
            return '/student_task/list'
        else
            print('\n Going to root')
            flash[:error] = "Going to root"
            return '/'
        end
    end

    def send_mail_to_new_user
        password = @user.reset_password # the password is reset
        prepared_mail = MailerHelper.send_mail_to_user(@user, "Your Expertiza account and password have been created.", "user_welcome", password)
        prepared_mail.deliver
        flash[:success] = "A new password has been sent to new user's e-mail address. "
    end

    def create_author
        print("/n In create Author/n")
        params[:user][:name] = params[:user][:email] unless !params[:user][:name].nil? and !params[:user][:name].empty?
        @user = User.new(user_params)
        # parent id for a conference user will be conference assignment instructor id
        @user.parent_id = Assignment.find(params[:user][:assignment]).instructor.id
        @assignment = Assignment.find(params[:user][:assignment])
        # set the user's timezone to its parent's
        @user.timezonepref = User.find(@user.parent_id).timezonepref
        # set default value for institute
        @user.institution_id = nil
        if @user.save
          password = @user.reset_password # the password is reset
          #Mail to be sent to Author once the user has been created. New partial is used as content for email is different from normal user
        #   prepared_mail = MailerHelper.send_mail_for_conference_user(@user, "Your Expertiza account and password have been created.", "author_conference_invitation", password, @assignment.name)
        #   prepared_mail.deliver_now
          print('\n ----------------passwored is---------]\n')
          print(password)
          print('\n ----------------passwored is---------\n')
          flash[:success] = "A new password has been sent to new user's e-mail address."
        else
          raise "Error occurred while creating expertiza account."
        end
    end

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
          MailerHelper.send_mail_for_conference_user(@user, "Your Expertiza account has been created.", "user_conference_invitation", password,current_user.name).deliver
          return @user
        end
      end
    
    #Function to add Author/co-author as participant in conference type assignment
    def add_participant_coauthor
        # Check if Assignment Participant already exists
        @participant = AssignmentParticipant.where('user_id = ? and parent_id = ?', @user.id, @assignment.id).first
        if @participant.nil?
            new_participant = AssignmentParticipant.create(parent_id: @assignment.id,
                                                    user_id: @user.id,
                                                    permission_granted: @user.master_permission_granted,
                                                    can_submit: 1,
                                                    can_review: 0,
                                                    can_take_quiz: 1)
            new_participant.set_handle
        end
    end


    def user_params
        params.require(:user).permit(:name,
                                     :role_id,
                                     :email,
                                     :parent_id,
                                     :institution_id)
    end
end
