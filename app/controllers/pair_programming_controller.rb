class PairProgrammingController < ApplicationController
    include AuthorizationHelper
  
    def action_allowed?
        current_user_has_student_privileges?
    end

    def send_invitations
        puts "INNNNNNNNNNNNNNNNNNNNNNN"
        puts params[:team_id]

        users = TeamsUser.where(team_id: params[:team_id])
        users.each { |user| user.update_attributes(pair_programming_status: "W")}
        #ExpertizaLogger.info "Accepting Invitation #{params[:inv_id]}: #{accepted}"
        flash[:success] = "Invitations have been sent successfully!"
        redirect_to view_student_teams_path student_id: params[:student_id]
    end
end
