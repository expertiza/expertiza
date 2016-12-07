class MessagesController < ApplicationController
  respond_to :html, :js


  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator',
     'Student'].include? current_role_name and ((%w(list).include? action_name) ? are_needed_authorizations_present? : true)
  end
  

  def index
    @chat = Chat.find(params[:chat_id])
    @messages = @chat.messages
    @new_message = @chat.messages.build
  end

  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.build(message_params)
    @message.user=session[:user]

    if @message.save
      sync_new @message , scope: Message.by_chat(@chat)
    end

    respond_with { @message }
  end

  private

  def message_params
    params.require(:message).permit(:body,:user)
  end
end