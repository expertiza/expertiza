# frozen_string_literal: true

class BookmarkRating < ApplicationRecord
  belongs_to :bookmark
  belongs_to :user
end
