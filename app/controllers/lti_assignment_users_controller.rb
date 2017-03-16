class LtiAssignmentUsersController < InheritedResources::Base

  def create
    pre_process_tenant
    assignment_id = params['custom_assignment_id']
    assignment_participant = AssignmentParticipant.find_by_user_id_and_assignment_id(current_user.id,assignment_id);
    if assignment_participant
      lis_result_sourcedid = params["lis_result_sourcedid"];
      @tenant.lis_outcome_service_url = params['lis_outcome_service_url'];
      user_assignment = LtiAssignmentUser.new
      user_assignment.assignment_id = assignment_id;
      user_assignment.user_id=current_user.id;
      user_assignment.participant_id=assignment_participant.id;
      user_assignment.lis_result_source_did=lis_result_sourcedid;
      user_assignment.tenant_id=@tenant.id;
      user_assignment.save;
    redirect_to "/student_task/view?id=#{assignment_participant.id}"
    end
  end

  private
    def lti_assignment_user_params
      params.require(:lti_assignment_user).permit(:user_id, :assignment_id, :participant_id, :lis_result_source_did, :tenant_id, :grade)
    end
end

