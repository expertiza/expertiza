class BookmarksController < ApplicationController

  def action_allowed?
    case params[:action]
    when 'list', 'new', 'create', 'bookmark_rating', 'save_bookmark_rating_score'
      current_role_name.eql? 'Student'
    when 'edit', 'update', 'destroy'
      #edit, update, delete bookmarks can only be done by owner
      current_role_name.eql? 'Student' and Bookmark.find(params[:id].to_i).user_id == session[:user].id
    end
  end

  def list
    @bookmarks = Bookmark.where(topic_id: params[:id])
    @topic = SignUpTopic.find(params[:id])
  end

  def new
    @topic = SignUpTopic.find(params[:id])
    @bookmark = Bookmark.new
  end

  
  def create
    params[:url] = params[:url].gsub!(/http:\/\//,"") if params[:url].start_with?('http://')
    params[:url] = params[:url].gsub!(/https:\/\//,"") if params[:url].start_with?('https://')
    begin
      Bookmark.create(url: params[:url], title: params[:title], description: params[:description], user_id: session[:user].id, topic_id: params[:topic_id] )
      flash[:success] = 'Bookmark has been created successfully!'
    rescue
      flash[:error] = $!
    end 
    redirect_to :action => 'list', :id => params[:topic_id]
  end

  def edit
    @bookmark = Bookmark.find(params[:id])
  end

  def update
    @bookmark = Bookmark.find(params[:id])
    @bookmark.update_attributes(url: params[:bookmark][:url], title: params[:bookmark][:title], description: params[:bookmark][:description])
    flash[:success] = 'Bookmark has been updated successfully!'
    redirect_to :action => 'list', :id => @bookmark.topic_id
  end

  def destroy
    @bookmark = Bookmark.find(params[:id])
    @bookmark.destroy
    flash[:success] = 'Bookmark has been deleted successfully!'
    redirect_to :action => 'list', :id => @bookmark.topic_id
  end

  def bookmark_rating
    @bookmark = Bookmark.find(params[:id])
  end

  def save_bookmark_rating_score
    @bookmark = Bookmark.find(params[:id])
    @bookmark_rating = BookmarkRating.where(bookmark_id: @bookmark.id, user_id: session[:user].id).first
    if @bookmark_rating.blank?
      BookmarkRating.create(bookmark_id: @bookmark.id, user_id: session[:user].id, rating: params[:rating])
    else
      @bookmark_rating.update_attribute('rating', params[:rating].to_i)
    end
    redirect_to :action => 'list', :id => @bookmark.topic_id
  end
end
