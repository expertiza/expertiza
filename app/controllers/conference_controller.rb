
class ConferenceController < ApplicationController
    include AuthorizationHelper
    autocomplete :user, :name
    # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
    verify method: :post, only: %i[destroy create update],
           redirect_to: {action: :list}
    def action_allowed?
      case params[:action]
      when 'list_pending_requested'
        ['Super-Administrator',
         'Administrator'].include? current_role_name
      when 'request_new'
        true
      #added new and create method to support user creation
      # via conference url or by instructor based on valid params & roles
      when 'new'
        is_valid_conference_assignment? or check_role
      when 'create'
        if params[:user][:assignment].nil?
          check_role
        else
          params[:assignment_id] = params[:user][:assignment]
          return is_valid_conference_assignment?
        end
      when 'create_requested_user_record'
        true
      when 'keys'
        current_role_name.eql? 'Student'
      else
        check_role
      end
    end
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
    def new
        if current_user && current_role_name == "Student"
            @user = current_user
            params[:user] = current_user
            add_conference_user_as_participant and return
        elsif current_user && is_valid_conference_assignment?
            flash[:error] = "Your current role does not allow you to join this assignment. Please log in as Student and retry to join."
            redirect_to get_redirect_url_link and return
        else
            print('\n Going to user new')
            @user = User.new
            @rolename = Role.find_by(name: params[:role])
            foreign
        end
    end

    # def role_assignment
    #     #if user creation call is for conference user then only possible role is Student
    #     # else  get all the roles types which logged in user can create as new user.
    #     role = Role.find_by_name('Student')
    #     @all_roles = Role.where('id in (?) or id = ?', role.get_available_roles, role.id)
    # end
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

    def create
        print('In conference create')
        if params[:user][:assignment].nil?
          create_normal_user
        else
          # Check if user needs to be created as author for conference type assignment and add author to assignment
          if create_conference_user
            add_conference_user_as_participant
          end
        end
    end

    def create_conference_user
        # check if user is already present with given username in system
        existing_user = User.find_by(name: params[:user][:name])
        # existing_user = User.where('name = ? and email = ?', params[:user][:name], params[:user][:email]).first
        # if user exist then add user as participant to assignment else create account and then add as participant
        if existing_user.nil?
          if (params[:user][:name].nil? or params[:user][:name].empty?)and !User.find_by(name: params[:user][:email]).nil?
            flash[:error] = "A user with username of this email already exists, Please provide a unique username to continue."
            redirect_to request.referrer
            return false
          end
          # Create author called from Conference Helper
          create_author
        else
            print("\nIn else of create conf\n")
          @user = existing_user
        end
    end
    
    def create_normal_user
        # if the user name already exists, register the user by email address
        check = User.find_by(name: params[:user][:name])
        params[:user][:name] = params[:user][:email] unless check.nil?
        @user = User.new(user_params)
        @user.institution_id = params[:user][:institution_id]
        # record the person who created this new user
        @user.parent_id = session[:user].id
        # set the user's timezone to its parent's
        @user.timezonepref = User.find(@user.parent_id).timezonepref
        if @user.save
            send_mail_to_new_user
            # Instructor and Administrator users need to have a default set for their notifications
            # the creation of an AssignmentQuestionnaire object with only the User ID field populated
            # ensures that these users have a default value of 15% for notifications.
            # TAs and Students do not need a default. TAs inherit the default from the instructor,
            # Students do not have any checks for this information.
            AssignmentQuestionnaire.create(user_id: @user.id) if @user.role.name == "Instructor" or @user.role.name == "Administrator"
            undo_link("The user \"#{@user.name}\" has been successfully created. ")
            redirect_to action: 'list'
        else
            foreign
            render action: 'new'
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

    def user_params
        params.require(:user).permit(:name,
                                     :role_id,
                                     :email,
                                     :parent_id,
                                     :institution_id)
    end
end
