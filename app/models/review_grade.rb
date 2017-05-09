class ReviewGrade < ActiveRecord::Base
	belongs_to :participant

  include PublicActivity::Model
  tracked owner: ->(controller, _model) { controller && controller.current_user }
end