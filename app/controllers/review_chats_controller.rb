class ReviewChatsController < ApplicationController
  helper :review_chats
  before_action :set_review_chat, only: [:show, :edit, :update, :destroy]

  # GET /review_chats
  # check the access to that interaction. 
  #Only the author and the particular reviewer should be able to see and interact.
  def action_allowed?
    review_chat = ReviewChat.find(params[:id])
    allowed_users=Array.new
    response_map = ReviewChat.get_response_map(review_chat)
    team_id = response_map.reviewee_id
    teams_users = TeamsUser.where(team_id: team_id)
    teams_users.each do |teams_user|
      allowed_users << User.find(teams_user.user_id).id
    end
    allowed_users << Participant.find(response_map.reviewer_id).user_id
    current_role_name.eql? 'Student' and allowed_users.include?(session[:user].id)
  end

  def index
    @review_chats = ReviewChat.all
  end

  # GET /review_chats/1
  # show the chat log
  def show
    @review_chat = ReviewChat.find(params[:id])
    @map_id=@review_chat.response_map_id
    @chat_log=ReviewChat.get_chat_log(@map_id)
  end

 # submit a followup query or a response
  def submitted_response
    @review_chat = ReviewChat.find(params[:id])
    response_map = ReviewResponseMap.find(@review_chat.response_map_id)
    @chat_reviewer=Participant.find(response_map.reviewer_id).user_id
    if(@chat_reviewer==session[:user].id) then
    	ReviewChat.create(:response_map_id => @review_chat.response_map_id, :type_flag => 'Q' , :content => params[:response_area])
    	ReviewChatsHelper::chat_email_query(params[:id])
    	flash[:notice]="Query has been submitted"	
    else	
      	ReviewChat.create(:response_map_id => @review_chat.response_map_id, :type_flag => 'A' , :content => params[:response_area])
      	ReviewChatsHelper::chat_email_response(@review_chat.id,@chat_reviewer)
      flash[:notice]="Response has been submitted"
    end	
    redirect_to action: 'show', id: params[:id]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review_chat
      @review_chat = ReviewChat.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def review_chat_params
      params.require(:review_chat).permit(:response_map_id, :type_flag, :content)
    end
end
