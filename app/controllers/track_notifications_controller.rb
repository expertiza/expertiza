class TrackNotificationsController < ApplicationController
  include AuthorizationHelper

  # Give permission to manage notifications to appropriate roles
  def action_allowed?
    current_user_has_student_privileges?
  end

  # GET /track_notifications *** Only used to add an individual exemption to showing notifications
  def index
    # Add tuple to hide notifications from users
    track_notification = TrackNotification.new(track_notification_params)
    track_notification.user_id = current_user.id
    track_notification.notification_id = params[:id]
    track_notification.save
    redirect_back fallback_location: root_path
  end

  private

  def track_notification_params
    params.permit(:notification_id, :user_id)
  end
end
