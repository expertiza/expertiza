class Message < ActiveRecord::Base
  belongs_to :chat
  belongs_to :user
  sync :all
  sync_scope :by_chat, ->(chat) { where(chat_id: chat.id) }
  validates_presence_of :body, :chat_id, :user_id
end
