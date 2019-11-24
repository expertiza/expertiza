module SampleReviewsHelper
  #Checks if the user is an anonymous user.
  def redirect_anonymous_user?
    session[:user].nil?
  end
end
