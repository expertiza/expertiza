module SampleReviewsHelper
  def redirect_anonymous_user?
    session[:user].nil?
  end
end
