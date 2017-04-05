class NotificationsController < ApplicationController
  before_action :set_notification, only: [:show, :edit, :update, :destroy]

  # Give permission to manage notifications to appropriate roles
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  def run_get_notification
    redirect_to controller: :student_task, action: :view if current_user.try(:student?)
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
    @notification = Notification.new(notification_params)

    if @notification.save
      redirect_to @notification, notice: 'Notification was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /notifications/1
  def update
    respond_to do |format|
      if @notification.update(notification_params)
        format.html { redirect_to @notification, notice: 'Notification was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /notifications/1
  def destroy
    # Remove any hidden notifications
    @individual_notification = TrackNotification.all
    @individual_notification.each do |notification|
      notification.destroy if notification.notification == @notification.id
    end
    @notification.destroy
    redirect_to notifications_url, notice: 'Notification was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_notification
    @notification = Notification.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def notification_params
    params.require(:notification).permit(:subject, :description, :expiration_date, :active_flag)
  end
end
