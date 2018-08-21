class CourseBadgeController < ApplicationController
	def action_allowed?
	    current_role_name.eql?("Instructor")
	  end

	def create
		puts params

		@badge_id = params[:course_badge][:badge_id]
		@course_id = params[:course_badge][:course]

		CourseBadge.create(badge_id: @badge_id, course_id: @course_id)
	end
end
