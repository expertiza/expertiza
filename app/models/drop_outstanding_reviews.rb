class drop_outstanding_reviews  < DeadlineType

	def email_list(assignment_id)
	        emails =[]
	        reviews = ResponseMap.where(reviewed_object_id: assignment_id)
            for review in reviews
              review_has_began = Response.where(map_id: review.id)
              if review_has_began.size.zero?
                review_to_drop = ResponseMap.where(id: review.id)
                review_to_drop.first.destroy
              end
            end
            emails
	end

end