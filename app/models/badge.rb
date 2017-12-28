class Badge < ActiveRecord::Base
	def self.get_id_from_name(badge_name)
  		badge = Badge.where(:name => badge_name)[0]
	  	badge.id
	end
end