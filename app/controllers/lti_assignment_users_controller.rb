class LtiAssignmentUsersController < InheritedResources::Base

  def create
    (@error_code, @message) = pre_process_tenant
    if @error_code == 200
      (user,@error_code,@message) = lti_login();
      if(user)
        assignment_id = params['custom_assignment_id']
        assignment_participant = AssignmentParticipant.find_by_user_id_and_assignment_id(user.id,assignment_id);
        if assignment_participant
          lis_result_sourcedid = params["lis_result_sourcedid"];
          @tenant.lis_outcome_service_url = params['lis_outcome_service_url'];
          user_assignment = LtiAssignmentUser.new
          user_assignment.assignment_id = assignment_id;
          user_assignment.user_id=user.id;
          user_assignment.participant_id=assignment_participant.id;
          user_assignment.lis_result_source_did=lis_result_sourcedid;
          user_assignment.tenant_id=@tenant.id;
          user_assignment.save;
          redirect_to "/student_task/view?id=#{assignment_participant.id}"
        end
      end
    end
    if(@error_code != 200)
      @url = params['launch_presentation_return_url'];
      flash[:error] = @message;
    end
  end

  def back_to_lms
    (redirect_to (params['url']))
  end

  def lti_login
    error_code = nil;
    message = nil;
    user = User.find_by_login(params['lis_person_contact_email_primary'])
    if user
      if(current_user!=nil && current_user.id!=user.id) #Clear session if different user's session is going on
        AuthController.clear_session(session)
      end
      if(session[:user] == nil) #Create new session with new user if no current session exists
        session[:user] = user
      end
      AuthController.set_current_role(user.role_id, session)
      return [user,error_code,message];
    else
      if(session[:user]!=nil) #If new user is not found, then clear existing session
        AuthController.clear_session(session)
      end
      error_code = "LTI_USER_NOT_FOUND"
      message = "User not registered on Expertiza. Please contact Expertiza administrators for registration details"
      return [user,error_code,message]
    end
    return [user,error_code,message]
  end # def login

  private
    def lti_assignment_user_params
      params.require(:lti_assignment_user).permit(:user_id, :assignment_id, :participant_id, :lis_result_source_did, :tenant_id, :grade)
    end
end

