module SampleReviewsHelper
	def redirect_anonymous_user
		current_user = session[:user]
		if current_user.nil?
			redirect_to "/"
		end
	end
end
