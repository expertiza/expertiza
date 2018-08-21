class Nomination < ActiveRecord::Base
	belongs_to :course_badge

	def is_auto_awarded?
		self.auto_awarded == 1
	end
end
