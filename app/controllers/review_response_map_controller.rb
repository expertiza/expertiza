class ReviewMappingController < ApplicationController
  autocomplete :user, :name
  def add_calibration
    participant = AssignmentParticipant.where(parent_id: params[:id], user_id: session[:user].id).first rescue nil
    if participant.nil?
      participant = AssignmentParticipant.create(parent_id: params[:id], user_id: session[:user].id, can_submit: 1, can_review: 1, can_take_quiz: 1, handle: 'handle')
    end
    map = ReviewResponseMap.where(reviewed_object_id: params[:id], reviewer_id: participant.id, reviewee_id: params[:team_id], calibrate_to: true).first rescue nil
    map = ReviewResponseMap.create(reviewed_object_id: params[:id], reviewer_id: participant.id, reviewee_id: params[:team_id], calibrate_to: true) if map.nil?
    redirect_to controller: 'response', action: 'new', id: map.id, assignment_id: params[:id], return: 'assignment_edit'
  end
end
