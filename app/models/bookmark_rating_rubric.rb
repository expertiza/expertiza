class BookmarkRatingRubric < ActiveRecord::Base
  validates_presence_of(:display_text, :minimum_rating, :maximum_rating)
  validates_uniqueness_of(:display_text, :allow_nil => true)
  validates_numericality_of(:minimum_rating, :maximum_rating, :allow_nil => true)
end

