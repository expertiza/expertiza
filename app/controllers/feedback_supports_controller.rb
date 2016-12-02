
class FeedbackSupportsController < ApplicationController
  before_action :set_feedback_support, only: [:show, :edit, :update, :destroy]
 # before_action :verify_captcha, only: [:create]

  def verify_captcha
    if !verify_captcha
      redirect_to :back, notice: 'wrong captcha'
    end
  end
  # GET /feedback_supports
  def index
    @feedback_supports = FeedbackSupport.all
  end

  def action_allowed?
    return true
  end

  def set_feedback_support
    @feedback_supports = FeedbackSupport.find(params[:id])
  end
  # GET /feedback_supports/1
  def show
  end
def feedback_support_params
  params.require(:feedback_supports).permit(:user_id, :title, :description)
end

  # GET /feedback_supports/new
  def new
    user = session[:user]
    if user.present?
      @user_email = user.email
    else
      @user_email = nil
    end
    @feedback_supports = FeedbackSupport.new
  end

  # GET /feedback_supports/1/edit
  def edit
  end

  # POST /feedback_supports
  def create
    @feedback_supports = FeedbackSupport.new(feedback_support_params)
    user = params[:feedback_support][:user_id]
    if user.present?
      @user_email = user.email
    else
      redirect_to :back, notice: 'Please enter your registered email to Expertiza'
    end
=begin
    @feedback_support = FeedbackSupport.new(feedback_support_params)
    user = params[:feedback][:user_id]

    puts "line 2"
    puts user
    if user.present?
      @user_email = user.email
    else
      redirect_to :back, notice: 'Please enter your registered email to Expertiza'
    end

    if @user.present?
     # prepared_mail = MailerHelper.send_mail_to_user()
=end
      Mailer.sync_message(
          recipients: params[:feedback][:user_id],
          subject: params[:feedback_support][:title],
          from: @user_email,
          body: {
              body_text: params[:feedback_support][:description],
              partial_name: "feedback_support"
          }
      ).deliver

      flash[:notice] = "Your feedback has been sent to Expertiza Support. We will try to help you as soon as possible"

      #send email
=begin
    else
      redirect_to :back, notice: 'Please enter your registered email to Expertiza'
    end
=end
=begin
    if @feedback_support.save
      redirect_to @feedback_support, notice: 'Feedback support was successfully created.'
    else
      render :new
    end
=end
  end

  # PATCH/PUT /feedback_supports/1
  def update
    if @feedback_support.update(feedback_support_params)
      redirect_to @feedback_support, notice: 'Feedback support was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /feedback_supports/1
  def destroy
    @feedback_support.destroy
    redirect_to feedback_supports_url, notice: 'Feedback support was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feedback_support
      @feedback_supports = FeedbackSupport.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def feedback_support_params
      params[:feedback_supports]
    end
end
