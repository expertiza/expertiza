class Bmapping < ActiveRecord::Base
	belongs_to :user
	belongs_to :bookmark
	has_many :bmappings_tags
	has_and_belongs_to_many :sign_up_topics
	has_many :ratings, :class_name => "BmappingRatings", :foreign_key => "bmapping_id"

	def cumulative_rating
	  rating = 0.0
	  count = 0
	  self.ratings.each do |br|
	    rating = rating + br.rating
	    count = count + 1
    end
    if count > 0
      return rating/count
    else
      return nil
    end
  end

end

