class SuggestionComment < ActiveRecord::Base
  validates_presence_of :comments
  belongs_to :suggestion
  attr_accessible
end
