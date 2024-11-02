class BookmarksController < ApplicationController
  include AuthorizationHelper
  include Scoring
  helper_method :specific_average_score
  helper_method :total_average_score

  def action_allowed?
    case params[:action]
    when 'list'
      current_role_name =~ /^(Student|Instructor|Teaching Assistant)$/
    when 'new', 'create', 'bookmark_rating', 'save_bookmark_rating_score'
      current_role_name.eql? 'Student'
    when 'edit', 'update', 'destroy'
      # edit, update, delete bookmarks can only be done by owner
      current_user_has_student_privileges? && current_user_created_bookmark_id?(params[:id])
    end
    @current_role_name = current_role_name
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
    params[:url] = params[:url].gsub!(%r{http://}, '') if params[:url].start_with?('http://')
    params[:url] = params[:url].gsub!(%r{https://}, '') if params[:url].start_with?('https://')
    begin
      Bookmark.create(url: create_bookmark_params[:url], title: create_bookmark_params[:title], description: create_bookmark_params[:description], user_id: session[:user].id, topic_id: create_bookmark_params[:topic_id])
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].username, 'Your bookmark has been successfully created!', request)
      flash[:success] = 'Your bookmark has been successfully created!'
    rescue StandardError
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].username, $ERROR_INFO, request)
      flash[:error] = $ERROR_INFO
    end
    redirect_to action: 'list', id: params[:topic_id]
  end

  def edit
    @bookmark = Bookmark.find(params[:id])
  end

  def update
    @bookmark = Bookmark.find(params[:id])
    @bookmark.update_attributes(url: update_bookmark_params[:bookmark][:url], title: update_bookmark_params[:bookmark][:title], description: update_bookmark_params[:bookmark][:description])
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].username, 'Your bookmark has been successfully updated!', request)
    flash[:success] = 'Your bookmark has been successfully updated!'
    redirect_to action: 'list', id: @bookmark.topic_id
  end

  def destroy
    @bookmark = Bookmark.find(params[:id])
    @bookmark.destroy
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].username, 'Your bookmark has been successfully deleted!', request)
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
      BookmarkRating.create(bookmark_id: @bookmark.id, user_id: session[:user].id, rating: create_bookmark_params[:rating])
    else
      @bookmark_rating.update_attribute('rating', create_bookmark_params[:rating].to_i)
    end
    redirect_to action: 'list', id: @bookmark.topic_id
  end

  # calculate average questionnaire score for 'Your rating' for specific bookmark
  def specific_average_score(bookmark)
    if bookmark.nil?
      '-'
    else
      assessment = SignUpTopic.find(bookmark.topic_id).assignment
      questions = assessment.questionnaires.where(type: 'BookmarkRatingQuestionnaire').flat_map(&:questions)
      responses = BookmarkRatingResponseMap.where(
        reviewed_object_id: assessment.id,
        reviewee_id: bookmark.id,
        reviewer_id: AssignmentParticipant.find_by(user_id: current_user.id).id
      ).flat_map { |r| Response.where(map_id: r.id) }
      score = assessment_score(response: responses, questions: questions)
      if score.nil?
        return '-'
      else
        (score * 5.0 / 100.0).round(2)
      end
    end
  end

  # calculate average questionnaire score for 'Avg. rating' for specific bookmark
  def total_average_score(bookmark)
    if bookmark.nil?
      '-'
    else
      assessment = SignUpTopic.find(bookmark.topic_id).assignment
      questions = assessment.questionnaires.where(type: 'BookmarkRatingQuestionnaire').flat_map(&:questions)
      responses = BookmarkRatingResponseMap.where(
        reviewed_object_id: assessment.id,
        reviewee_id: bookmark.id
      ).flat_map { |r| Response.where(map_id: r.id) }
      totalScore = aggregate_assessment_scores(responses, questions)
      if totalScore[:avg].nil?
        return '-'
      else
        (totalScore[:avg] * 5.0 / 100.0).round(2)
      end
    end
  end

  private

  # TODO: Create a common definition for both create and update to reduce it to single params method
  # Change create method to take bookmark param as required.
  def create_bookmark_params
    params.permit(:url, :title, :description, :topic_id, :rating, :id)
  end

  def update_bookmark_params
    params.require(:bookmark).permit(:url, :title, :description)
  end
end
