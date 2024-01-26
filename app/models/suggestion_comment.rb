class SuggestionComment < ApplicationRecord
  validates :comments, presence: true
  belongs_to :suggestion
end
