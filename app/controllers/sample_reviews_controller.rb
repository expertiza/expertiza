class SampleReviewsController < ApplicationController
	include ResponseConstants
	include SimilarAssignmentsConstants
	skip_before_action :authorize, only: [:update_visibility]

	def update_visibility
		begin
			visibility = params[:visibility] #response object consists of visibility in string format
			if(visibility.nil?)
				raise StandardError.new("Missing parameter 'visibility'")
			end
			visibility = visibility.to_i
			if not (_private..rejected_as_sample).include? visibility
				raise StandardError.new("Invalid value for parameter 'visibility'")
			end
			@@response_id = params[:id]
			response_map_id = Response.find(@@response_id).map_id
			response_map = ResponseMap.find(response_map_id)
			assignment_id = response_map.reviewed_object_id
			course_id = Assignment.find(assignment_id).course_id
			instructor_id = Course.find(course_id).instructor_id
			ta_ids = []
			if current_user.role.id == Role.ta.id
				ta_ids = TaMapping.where(course_id).ids # do this query only if current user is ta
			elsif current_user.role.id == Role.student.id
				# find if this student id is the same as the response reviewer id
				# and that visiblity is 0 or 1 and nothing else.
				# if anything fails, return failure
				if visibility > in_review
					render json:{"success" => false, "error"=>"Invalid value for parameter 'visibility'"}
					return
				end
				reviewer_user_id = AssignmentParticipant.find(response_map.reviewer_id).user_id
				if reviewer_user_id != current_user.id
					render json:{"success" => false,"error" => "Unathorized"}
			 		return
				end
			elsif not ([instructor_id] + ta_ids).include? current_user.id
			 	render json:{"success" => false,"error" => "Unathorized"}
			 	return
			end
			Response.update(@@response_id.to_i, :visibility => visibility)
			update_similar_assignment(assignment_id, visibility)
		rescue StandardError => e
			render json:{"success" => false,"error" => e.message}
		else
			render json:{"success" => true}
		end
	end

	private
	def update_similar_assignment(assignment_id, visibility)
		if visibility == approved_as_sample
			ids = SimilarAssignment.where(:is_similar_for => assignment_id, :association_intent => intent_review, 
				:assignment_id => assignment_id).ids
			if ids.empty?
				SimilarAssignment.create({:is_similar_for => assignment_id, :association_intent => intent_review, 
				:assignment_id => assignment_id})
			end
		end
		if visibility == rejected_as_sample or visibility == _private
			response_map_ids = ResponseMap.where(:reviewed_object_id => assignment_id).ids
			response_ids = Response.where(:map_id => response_map_ids, :visibility => approved_as_sample)
			if response_ids.empty?
				SimilarAssignment.where(:assignment_id => assignment_id).destroy_all
			end
		end
	end
end