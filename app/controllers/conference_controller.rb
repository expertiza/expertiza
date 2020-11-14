include ConferenceHelper
class ConferenceController < ApplicationController
    include AuthorizationHelper

    autocomplete :user, :name
    # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
    verify method: :post, only: %i[destroy create update],
           redirect_to: {action: :list}
    def action_allowed?
      case params[:action]

      when 'new'
        is_valid_conference_assignment? or current_user_has_admin_rights
      when 'create'
        params[:assignment_id] = params[:user][:assignment]
        return is_valid_conference_assignment?
      else
        current_user_has_admin_rights
      end
    end

    def new
        if current_user && current_role_name == "Student" # current_user_has_student_privileges?
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
            # when a new user joins or an existing user updates his/her profile they will get to choose
            # from all the roles available
            #if user creation call is for conference user then only possible role is Student
            role = Role.find_by_name('Student')
            @all_roles = Role.where('id in (?) or id = ?', role.get_available_roles, role.id)
        end
    end
end
