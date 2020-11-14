module ConferenceHelper
    def is_valid_conference_assignment?
        #if assignment id is present in url the check if it's a valid conference assignment.
        if !params[:assignment_id].nil?
          @assignment = Assignment.find_by_id(params[:assignment_id])
          if !@assignment.nil? and @assignment.is_assignment_conference
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
          print("\\n Create author email "+@user.email)
          prepared_mail = MailerHelper.send_mail_for_conference_user(@user, "Your Expertiza account and password have been created.", "author_conference_invitation", password, @assignment.name)
          prepared_mail.deliver_now
          print('\n ----------------passwored is---------]\n')
          print(password)
          print('\n ----------------passwored is---------\n')
          flash[:success] = "A new password has been sent to new user's e-mail address."
        else
          raise "Error occurred while creating expertiza account."
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
