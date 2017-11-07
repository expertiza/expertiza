class BookmarkRating < ActiveRecord::Base
  belongs_to :bookmark
  belongs_to :user
  attr_accessible
end
