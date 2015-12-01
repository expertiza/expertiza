class ReviewChatsController < ApplicationController
  before_action :set_review_chat, only: [:show, :edit, :update, :destroy]

  # GET /review_chats
  def action_allowed?
    current_user
  end

  def index
    @review_chats = ReviewChat.all
    #@review_chats = ReviewChat.where
  end

  # GET /review_chats/1
  def show
    @review_chat = ReviewChat.find(params[:id])
    @assignment_id=@review_chat.assignment_id
    @reviewer_id=@review_chat.reviewer_id
    @team_id=@review_chat.team_id
    @chat_log=ReviewChat.where(:reviewer_id => @reviewer_id).where(:team_id => @team_id)
  end


  def submitted_response
    @review_chat = ReviewChat.find(params[:id])
    @chat_reviewer=Participant.find(@review_chat.reviewer_id).user_id
    if(@chat_reviewer==session[:user].id) then
    	ReviewChat.create(:assignment_id => @review_chat.assignment_id,:reviewer_id => @review_chat.reviewer_id, :team_id=>@review_chat.team_id, :type_flag => 'Q' , :content => params[:response_area])
    else	
      	ReviewChat.create(:assignment_id => @review_chat.assignment_id,:reviewer_id => @review_chat.reviewer_id, :team_id=>@review_chat.team_id, :type_flag => 'A' , :content => params[:response_area])
    end	
    flash[:notice]="Response has been submitted"
    ReviewChat.chat_email_response(@review_chat.id,@chat_reviewer)
    redirect_to action: 'show', id: params[:id]
  end

  # GET /review_chats/new
  def new
    @review_chat = ReviewChat.new
  end

  # GET /review_chats/1/edit
  def edit
  end

  # POST /review_chats
  def create
    @review_chat = ReviewChat.new(review_chat_params)

    if @review_chat.save
      redirect_to @review_chat, notice: 'Review chat was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /review_chats/1
  def update
    if @review_chat.update(review_chat_params)
      redirect_to @review_chat, notice: 'Review chat was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /review_chats/1
  def destroy
    @review_chat.destroy
    redirect_to review_chats_url, notice: 'Review chat was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review_chat
      @review_chat = ReviewChat.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def review_chat_params
      params.require(:review_chat).permit(:assignment_id, :reviewer_id, :team_id, :type_flag, :content)
    end
end
