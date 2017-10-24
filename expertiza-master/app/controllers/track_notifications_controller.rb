class TrackNotificationsController < ApplicationController
  # Give permission to manage notifications to appropriate roles
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator',
     'Student'].include? current_role_name
  end

  # GET /track_notifications *** Only used to add an individual exemption to showing notifications
  def index
    @track_notifications = TrackNotification.all
    # Add tuple to hide notifications from users
    @track_notification = TrackNotification.new(track_notification_params)
    @track_notification.user_id = current_user.id
    @track_notification.notification = params[:id]
    @track_notification.save
    redirect_back
  end

  private

  # Only allow a trusted parameter "white list" through.
  def track_notification_params
    params.permit(:notification, :user_id)
  end
end
