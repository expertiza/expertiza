class StudentReviewController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator',
     'Student'].include? current_role_name and
    ((%w(list).include? action_name) ? are_needed_authorizations_present?(params[:id], "submitter") : true)
  end

  def list
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment
    @response_map = ReviewResponseMap.where(reviewer_id: params[:id]).first
    @reviewer_is_team_member = false

    # E17A0 If an assignment is to be reviewed by a team, get a list of team members and allow them access
    if !@assignment.nil?
      if @assignment.reviewer_is_team?
        reviewer_team_members = TeamsUser.joins("
          LEFT JOIN teams ON teams_users.team_id = teams.id
          LEFT JOIN participants ON teams_users.user_id = participants.user_id").select("
          participants.user_id").where("
          teams.parent_id = ? AND participants.parent_id = ?
          AND teams_users.team_id = ?", @assignment.id, @assignment.id, @response_map.team_id)
        @reviewer_is_team_member = reviewer_team_members.all.any? { |m| m.user_id == current_user.id}
      end
    end

    return unless current_user_id?(@participant.user_id) || @reviewer_is_team_member

    #E17A0 We unlock a response_map if it was locked by another team member.
    if(params.has_key?(:response_id))
      unlock_response_map params[:response_id] if @response_map.type == 'ReviewResponseMap'
    end

    @assignment = @participant.assignment
    # Find the current phase that the assignment is in.
    @topic_id = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id)
    @review_phase = @assignment.get_current_stage(@topic_id)
    # ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments

    # E17A0 If an assignment is to be reviewed by a team, select it by team_id otherwise by reviewer_id
    if @reviewer_is_team_member
      @review_mappings = ReviewResponseMap.where(team_id: @response_map.team_id)
    else
      @review_mappings = ReviewResponseMap.where(reviewer_id: @participant.id)
    end
    # if it is an calibrated assignment, change the response_map order in a certain way
    @review_mappings = @review_mappings.sort_by {|mapping| mapping.id % 5 } if @assignment.is_calibrated == true
    @metareview_mappings = MetareviewResponseMap.where(reviewer_id: @participant.id)
    # Calculate the number of reviews that the user has completed so far.

    @num_reviews_total = @review_mappings.size
    # Add the reviews which are requested and not began.
    @num_reviews_completed = 0
    @review_mappings.each do |map|
      @num_reviews_completed += 1 if !map.response.empty? && map.response.last.is_submitted
    end

    @num_reviews_in_progress = @num_reviews_total - @num_reviews_completed
    # Calculate the number of metareviews that the user has completed so far.
    @num_metareviews_total       = @metareview_mappings.size
    @num_metareviews_completed   = 0

    @metareview_mappings.each do |map|
      @num_metareviews_completed += 1 unless map.response.empty?
    end

    @num_metareviews_in_progress = @num_metareviews_total - @num_metareviews_completed
    @topic_id = SignedUpTeam.topic_id(@assignment.id, @participant.user_id)
  end

  private
  def unlock_response_map response_id
    review_response_map = ReviewResponseMap.find(Response.find(response_id).map_id)

    if !review_response_map.nil?
      ReviewResponseMap.update(review_response_map.id, :is_locked => false, :locked_by => current_user.id)
      flash[:note] = "Artifact (ID: #{review_response_map.id}) has been successfully unlocked and can now be editted."
    end
  end
end
