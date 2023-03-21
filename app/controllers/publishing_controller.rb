class PublishingController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    current_user_has_student_privileges?
  end

  def view
    @user = User.find(session[:user].id) # Find again, because the user's certificate may have changed since login
    @participants = AssignmentParticipant.where(user_id: session[:user].id)
  end

  def set_publish_permission
    participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(participant.user_id)

    if params[:allow] == '1'
      redirect_to action: 'grant'
    else
      participant.update_attribute('permission_granted', params[:allow])
      redirect_to action: 'view'
    end
  end

  def update_publish_permissions
    if params[:allow] == '1'
      redirect_to action: 'grant'
    else
      participants = AssignmentParticipant.where(user_id: session[:user].id)
      participants.each do |participant|
        participant.update_attribute('permission_granted', params[:allow])
        participant.digital_signature = nil
        participant.time_stamp = nil
        participant.save
      end
      redirect_to action: 'view'
    end
  end

  # Put up the page where the user can supply their private key and grant publishing rights
  def grant
    id = params[:id]
    @participant = AssignmentParticipant.find(id) unless id.nil?
    @user = User.find(session[:user].id)
  end

  # Grant publishing rights using the private key supplied by the student
  def grant_with_private_key
    id = params[:id]
    participants = if id
                     [AssignmentParticipant.find(id)]
                   else
                     AssignmentParticipant.where(user_id: session[:user].id)
                   end
    private_key = params[:private_key]

    begin
      participants.each do |participant|
        participant.assign_copyright(private_key)
      end
      redirect_to action: 'view'
    rescue StandardError
      flash[:notice] = 'The private key you inputted was invalid.'
      if id
        redirect_to action: 'grant', id: participants[0].id
      else
        redirect_to action: 'grant'
      end
    end
  end
end
