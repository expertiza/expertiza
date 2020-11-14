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
end
