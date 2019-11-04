class BookmarksController < ApplicationController
  def action_allowed?
    case params[:action]
    when 'list', 'new', 'create', 'bookmark_rating', 'new_bookmark_review', 'save_bookmark_rating_score'
      current_role_name.eql? 'Student'
    when 'edit', 'update', 'destroy'
      # edit, update, delete bookmarks can only be done by owner
      current_role_name.eql? 'Student' and Bookmark.find(params[:id]).user_id == session[:user].id
    end
  end

  def list
    @participant = Participant.where(user_id: session[:user].id).first
    @bookmarks = Bookmark.where(topic_id: params[:id])
    @topic = SignUpTopic.find(params[:id])
    bookmark_rating_questionnaire = @topic.assignment.questionnaires.where(type: 'BookmarkRatingQuestionnaire')
    if bookmark_rating_questionnaire[0].nil?
      @has_dropdown = true
    else
      @has_dropdown = false
    end
  end

  def new
    @participant = Participant.where(user_id: session[:user].id).first
    @topic = SignUpTopic.find(params[:id])
    @bookmark = Bookmark.new
  end

  def create
    params[:url] = params[:url].gsub!(/http:\/\//, "") if params[:url].start_with?('http://')
    params[:url] = params[:url].gsub!(/https:\/\//, "") if params[:url].start_with?('https://')
    begin
      Bookmark.create!(url: params[:url], title: params[:title], description: params[:description], user_id: session[:user].id, topic_id: params[:topic_id])
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, 'Your bookmark has been successfully created!', request)
      flash[:success] = 'Your bookmark has been successfully created!'
    rescue StandardError
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, $ERROR_INFO.to_s, request)
      flash[:error] = 'Bookmark could not be created: ' + $ERROR_INFO.to_s
    end
    redirect_to action: 'list', id: params[:topic_id]
  end

  def edit
    @bookmark = Bookmark.find(params[:id])
  end

  def update
    @bookmark = Bookmark.find(params[:id])
    begin
      @bookmark.update_attributes!(url: params[:bookmark][:url], title: params[:bookmark][:title], description: params[:bookmark][:description])
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, 'Your bookmark has been successfully updated!', request)
      flash[:success] = 'Your bookmark has been successfully updated!'
    rescue StandardError
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, $ERROR_INFO.to_s, request)
      flash[:error] = 'Bookmark could not be updated: ' + $ERROR_INFO.to_s
    end
    redirect_to action: 'list', id: @bookmark.topic_id
  end

  def destroy
    @bookmark = Bookmark.find(params[:id])
    @bookmark.destroy
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, 'Your bookmark has been successfully deleted!', request)
    flash[:success] = 'Your bookmark has been successfully deleted!'
    redirect_to action: 'list', id: @bookmark.topic_id
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
    redirect_to action: 'list', id: @bookmark.topic_id
  end

  def new_bookmark_review
    bookmark = Bookmark.find(params[:id])
    topic = SignUpTopic.find(bookmark.topic_id)
    assignment_participant = AssignmentParticipant.find_by(user_id: current_user.id)
    response_map = BookmarkRatingResponseMap.where(
      reviewed_object_id: topic.assignment.id,
      reviewer_id: assignment_participant.id,
      reviewee_id: bookmark.id
    ).first
    if response_map.nil?
      response_map = BookmarkRatingResponseMap.create(
        reviewed_object_id: topic.assignment.id,
        reviewer_id: assignment_participant.id,
        reviewee_id: bookmark.id
      )
    end
    redirect_to new_response_url(id: response_map.id, return: 'bookmark')
  end
end
