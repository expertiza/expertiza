class SampleReviewsController < ApplicationController
	skip_before_action :authorize, only: [:update_visibility]

	def update_visibility
		begin
			@@response_id = params[:id]
			response_map_id = Response.find(@@response_id).map_id
			assignment_id = ResponseMap.find(response_map_id).reviewed_object_id
			course_id = Assignment.find(assignment_id).course_id
			instructor_id = Course.find(course_id).instructor_id
			ta_ids = []
			if current_user.role.name == 'Teaching Assistant'
				ta_ids = TaMapping.where(course_id).ids # do this query only if current user is ta
			end
			if not ([instructor_id] + ta_ids).include? current_user.id
			 	render json:{"success":false,"error":"Unathorized"}
			 	return
			end
			visibility = params[:visibility].to_i #response object consists of visibility in string format
			if not (0..3).include? visibility
				raise StandardError.new('Invalid visibility')
			end
			Response.update(@@response_id.to_i, :visibility => visibility)
			update_similar_assignment(assignment_id, visibility)
		rescue StandardError
			render json:{"success":false,"error":"Something went wrong"}
		else
			render json:{"success":true}
		end
	end

	private
	def update_similar_assignment(assignment_id, visibility)
		if visibility == 2 
			ids = SimilarAssignment.where(:is_similar_for => assignment_id, :association_intent => 'Review', 
				:assignment_id => assignment_id).ids
			if ids.empty?
				SimilarAssignment.create({:is_similar_for => assignment_id, :association_intent => 'Review', 
				:assignment_id => assignment_id})
			end
		end
		if visibility == 3 or visibility == 0
			response_map_ids = ResponseMap.where(:reviewed_object_id => assignment_id).ids
			response_ids = Response.where(:map_id => response_map_ids, :visibility => 2)
			if not response_ids.empty?
				SimilarAssignment.where(:assignment_id => assignment_id).destroy
			end
		end
	end
end