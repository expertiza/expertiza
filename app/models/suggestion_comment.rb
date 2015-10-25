class SuggestionComment < ActiveRecord::Base
  validates_presence_of :comments
  belongs_to :suggestion
end
