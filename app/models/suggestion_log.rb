# OSS project_Team1 (jmfoste2) CSC517 Fall 2010
# Created model to add suggestion logging functionality

class SuggestionLog < ActiveRecord::Base
  belongs_to :suggestion
  belongs_to :user
  
  validates_presence_of :suggestion_id, :user_id
  
end
