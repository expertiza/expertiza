class FeedbackSettingsController < ApplicationController
  before_action :set_feedback_setting, only: [:show, :edit, :update, :destroy]
  before_action :set_file_types, only:[:show, :edit]
  # GET /feedback_settings
  def index
    @feedback_settings = FeedbackSetting.all
    @feedback_statuses = FeedbackStatus.all
  end
  def action_allowed?
    @settings = FeedbackSetting.find(1)
    #if params[:action] == 'edit' or params[:action] == 'update'


    if @current_user.present?
      return true if @settings.support_team.include? @current_user.email
      return false
    end

  end
  # GET /feedback_settings/1
  def show
  end

  # GET /feedback_settings/new
  def new
    @feedback_setting = FeedbackSetting.new
  end

  # GET /feedback_settings/1/edit
  def edit
  end
  def add_attachment_type
    @feedback_setting = FeedbackAttachmentSetting.new(feedback_attachment_params)
    @feedback_setting.save
    redirect_to :back, notice: 'Added File Type'
  end
  def add_status
    @feedback_status = FeedbackStatus.new(feedback_status_params)
    @feedback_status.save
    redirect_to :back, notice: 'Added File Type'
  end
  # POST /feedback_settings
  def create
    @feedback_setting = FeedbackSetting.new(feedback_setting_params)

    if @feedback_setting.save
      redirect_to @feedback_setting, notice: 'Feedback setting was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /feedback_settings/1
  def update
    if @feedback_setting.update(feedback_setting_params)
      redirect_to @feedback_setting, notice: 'Feedback setting was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /feedback_settings/1
  def destroy
    @feedback_setting.destroy
    redirect_to feedback_settings_url, notice: 'Feedback setting was successfully destroyed.'
  end

  def delete_attachment_type
    @file_type= FeedbackAttachmentSetting.find(params[:id])
    @file_type.destroy
    redirect_to :back, notice: 'Attachment type successfully deleted.'

  end
  def delete_status
    @status= FeedbackStatus.find(params[:id])
    @status.destroy
    redirect_to :back, notice: 'Attachment type successfully deleted.'

  end

  def set_file_types
    @file_types = FeedbackAttachmentSetting.all
    @file_type=FeedbackAttachmentSetting.new
    @feedback_statuses = FeedbackStatus.all
    @feedback_status = FeedbackStatus.new
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_feedback_setting
    @feedback_setting = FeedbackSetting.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def feedback_setting_params
    params.require(:feedback_setting).permit(:support_mail, :max_attachments, :max_attachment_size, :wrong_retries, :wait_duration, :wait_duration_increment, :support_team)
  end

  def feedback_attachment_params
    params.require(:feedback_attachment_setting).permit(:file_type)
  end
  def feedback_status_params
    params.require(:feedback_status).permit(:status)
  end
end
