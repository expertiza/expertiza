# constants used to maintain the visibility status of reviews(response objects)
module ResponseConstants
	def _private
		0
	end

	def in_review
		1
	end

	def approved_as_sample
		2
	end

	def rejected_as_sample
		3
	end
end