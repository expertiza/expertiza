# frozen_string_literal: true

class SuggestionComment < ApplicationRecord
  validates :comments, presence: true
  belongs_to :suggestion
end
