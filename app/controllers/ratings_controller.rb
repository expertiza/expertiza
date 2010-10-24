class RatingsController < ApplicationController
  
  include RatingsOptimizer
  
  def rate
    rateable = Bookmark.find(params[:id])
    # Delete the old ratings for current user
    Rating.delete_all(["rateable_type = ? AND rateable_id = ? AND user_id = ?", Bookmark.base_class.to_s, params[:id], params[:user_id]])    
    rateable.add_rating Rating.new(:rating => params[:rating], :user_id => session[:user].id)
    this_br = optimize_ratings(rateable)
    rateable.bayesian_rating = this_br
    rateable.save
    
    #if request.xhr?
    	render :partial => "rating/rating", :locals=> {:asset => rateable}  , :layout => false    	   
    #render :text => rateable.rating.to_s + " /5 stars"
    
    #render :update do |page|
     # page.replace_html( "rating_div_"+rateable.id.to_s, {:partial => "rating/rating", :locals=>{:asset => rateable}})
  end
end