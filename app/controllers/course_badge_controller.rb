class CourseBadgeController < ApplicationController
	def action_allowed?
	    current_role_name.eql?("Instructor")
	end

	def create
		@badge_id = params[:course_badge][:badge_id]
		@course_id = params[:course_badge][:course_id]

		CourseBadge.create(badge_id: @badge_id, course_id: @course_id)

		render status: 200, json: {status: 200, message: "Course badge created"}
	end

	def delete_badge_from_course
		puts params
		@badge_id = params[:course_badge][:badge_id]
		@course_id = params[:course_badge][:course_id]

		CourseBadge.where(badge_id: @badge_id, course_id: @course_id).destroy_all

		render status: 200, json: {status: 200, message: "Course badge destroyed"}
	end
end
