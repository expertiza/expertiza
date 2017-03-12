class LtiAssignmentsController < ApplicationController
  def create
    assignment_id = params['custom_assignment_id']
    assignment_participant = AssignmentParticipant.find_by_user_id_and_assignment_id(current_user.id,assignment_id);
    if assignment_participant
    redirect_to "/student_task/view?id=#{assignment_participant.id}"
    end
  end
end
