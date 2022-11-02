# frozen_string_literal: true

class Suggestion < ApplicationRecord
  validates :title, :description, presence: true
  has_many :suggestion_comments
end
