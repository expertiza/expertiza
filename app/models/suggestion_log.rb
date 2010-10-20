class SuggestionLog < ActiveRecord::Base
  belongs_to :suggestion
  belongs_to :user
  
  validates_presence_of :suggestion_id, :user_id
  
end
