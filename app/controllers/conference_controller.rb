
class ConferenceController < ApplicationController

    
    def new
        if current_user && current_role_name == "Student"
            @user = current_user
            params[:user] = current_user
            add_conference_user_as_participant and return
        elsif current_user && is_valid_conference_assignment?
            flash[:error] = "Your current role does not allow you to join this assignment. Please log in as Student and retry to join."
            redirect_to get_redirect_url_link and return
        else
            redirect_to '/user/new'
        end
    end

    # def role_assignment
    #     #if user creation call is for conference user then only possible role is Student
    #     # else  get all the roles types which logged in user can create as new user.
    #     role = Role.find_by_name('Student')
    #     @all_roles = Role.where('id in (?) or id = ?', role.get_available_roles, role.id)
    # end

    def add_conference_user_as_participant
        # Author added as participant, function written in Conference Helper
        add_participant_coauthor
        flash[:success] = "You are added as an Author for assignment " + @assignment.name
        redirect_to get_redirect_url_link
      end
    
    def get_redirect_url_link
        #if conference user is already logged in the redirect to Student_task list page
        # else redirect to login page.
        if current_user && current_role_name == "Student"
            return '/student_task/list'
        else
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
end
