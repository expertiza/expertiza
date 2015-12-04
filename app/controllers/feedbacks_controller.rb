class FeedbacksController < ApplicationController
  before_action :set_feedback, only: [:show, :edit, :update, :destroy]
  before_action :verify_captcha, only: [:create]

  def verify_captcha
    if !verify_recaptcha
      redirect_to :back, notice: 'Wrong captcha'
    else
      @settings = FeedbackSetting.find(1)
    end
  end

  # GET /feedbacks
  def index
    @feedbacks = Feedback.all
  end

  # GET /feedbacks/1
  def show
    @attachment = FeedbackAttachment.find_by_feedback_id(@feedback.id)
  end

  def download_feedback_attachment

    @attachment = FeedbackAttachment.find_by_feedback_id(params[:id])
    send_data @attachment.data, :filename => @attachment.filename, :type => @attachment.content_type,  :disposition => 'attachment; filename=' + @attachment.filename
  end

  # GET /feedbacks/new
  def new
    user = session[:user]
    if user.present?
      @user_email = user.email
    else
      @user_email = nil
    end
    @feedback = Feedback.new
  end

  # GET /feedbacks/1/edit
  def edit
    @statuses= FeedbackStatus.select(:status)

  end

  # POST /feedbacks
  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.status = "New"

    user = session[:user]
    if user.present?
      @user_email = user.email
    else
      @user_email = nil
    end

    if @user_email.nil?
      @user = User.find_by_email(params[:feedback][:user_id])
    else
      @user = User.find_by_email(@user_email)
    end

    if @user.present?
      @feedback.user_id = @user.id

      if @feedback.save
        if params[:feedback][:attachment]
          create_attachment
        else
          redirect_to @feedback, notice: 'Feedback was successfully created.'
        end
      else
        redirect_to @feedback, notice: 'Feedback not created.'
      end
    else
      wrong_retries_calculator
      redirect_to :back, notice: 'Please enter your registered email to Expertiza'
    end

  end
  def wrong_retries_calculator
    if session[:wrong_email_attempts]==nil
      session[:wrong_email_attempts]={:value => 0}
    else if session[:wrong_email_attempts][:value] < @settings.wrong_retries
           session[:wrong_email_attempts][:value] += 1
         else
           wrong_retries_incrementer = session[:wrong_email_attempts][:value] - @settings.wrong_retries + 1
           session[:wrong_email_attempts][:value] += 1
           session[:wrong_email_attempts][:expires] =  (@settings.wait_duration * wrong_retries_incrementer).minutes.from_now
         end
    end

  end
  def create_attachment

    if params[:feedback][:attachment].size > @settings.max_attachment_size.kilobytes
      redirect_to :back, notice: 'Attachment size exceeds the permitted limit'
    else
      @attachment = FeedbackAttachment.new
      @attachment.uploaded_file = params[:feedback][:attachment]
      @attachment.feedback_id = @feedback.id
      if @attachment.save
        redirect_to @feedback, notice: 'Feedback was successfully created.'
      else
        @feedback.destroy
        redirect_to :back, notice: @attachment.errors[:content_type]
      end
    end

  end

  # PATCH/PUT /feedbacks/1
  def update
    if @feedback.update(feedback_params)
      redirect_to @feedback, notice: 'Feedback was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /feedbacks/1
  def destroy
    @feedback.destroy
    redirect_to feedbacks_url, notice: 'Feedback was successfully destroyed.'
  end

  def action_allowed?
    @settings = FeedbackSetting.find(1)
    #if params[:action] == 'edit' or params[:action] == 'update'

    if ["edit", "update", "index", "destroy"].include? params[:action]
    if @current_user.present?
      return true if @settings.support_team.include? @current_user.email
      return false
      end
    else
      return true
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_feedback
    @feedback = Feedback.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def feedback_params
    params.require(:feedback).permit(:user_id, :title, :description, :status)
  end
end