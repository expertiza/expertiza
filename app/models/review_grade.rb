class ReviewGrade < ActiveRecord::Base
	belongs_to :participant

	include PublicActivity::Model
	tracked owner: ->(controller, model) { controller && controller.current_user }
  
end