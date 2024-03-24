class NotificationsController < ApplicationController
  before_action :set_notification, only: %i[show edit update destroy]
  helper_method :validate_params

  include SecurityHelper
  include AuthorizationHelper

  # Give permission to manage notifications to appropriate roles
  def action_allowed?
    current_user_has_ta_privileges?
  end

  def run_get_notification
    if current_user.try(:student?)
      redirect_to controller: :student_task, action: :view
    end
  end

  # GET /notifications
  def list
    @notifications = Notification.all
  end

  # GET /notifications
  def index
    @notifications = Notification.all
  end

  # GET /notifications/1
  def show; end

  # GET /notifications/new
  def new
    @notification = Notification.new
  end

  # GET /notifications/1/edit
  def edit; end

  # POST /notifications
  def create
    if params[:notification]
      redirect_back fallback_location: root_path
      return
    end
    @notification = Notification.new(notification_params)

    if @notification.save
      redirect_to @notification
      flash[:success] = 'Notification was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /notifications/1
  def update
    if @notification.update(notification_params)
      redirect_to @notification
      flash[:success] = 'Notification was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /notifications/1
  def destroy
    # Remove any hidden notifications
    @individual_notification = TrackNotification.all
    @individual_notification.each do |notification|
      notification.destroy if notification.notification_id == @notification.id
    end
    @notification.destroy
    redirect_to notifications_url
    flash[:success] = 'Notification was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_notification
    @notification = Notification.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def notification_params
    params.require(:notification).permit(:course_id, :subject, :description, :expiration_date, :active_flag)
  end
end
