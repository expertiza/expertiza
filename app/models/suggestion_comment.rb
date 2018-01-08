class SuggestionComment < ActiveRecord::Base
  validates :comments, presence: true
  belongs_to :suggestion
end
