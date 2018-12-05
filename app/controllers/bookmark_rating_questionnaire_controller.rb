# Author: Rahul Iyer
# Email: rsiyer2@ncsu.edu

class BookmarkRatingQuestionnaireController < ApplicationController
  def create
    return unless validate_request

    @topic = topic
    return if @topic.nil?

    @questionnaire = questionnaire
    return if @questionnaire.nil?

    @bookmark_rating_questionnaire = BookmarkRatingQuestionnaire.new(create_params)
    @bookmark_rating_questionnaire.save

    respond_to do |format|
      format.json { render json: @bookmark_rating_questionnaire }
    end
  end

  private

  def validate_request
    if params[:assignment_id].nil?
      flash[:error] = "Missing Assignment: #{params[:topic_id]}"
      return false
    elsif params[:questionnaire_id].nil?
      flash[:error] = "Missing questionnaire: #{params[:questionnaire_id]}"
      return false
    end
    true
  end

  def topic
    topic = Assignment.find(params[:assignment_id])
    flash[:error] = "Assignment \##{topic.id} does not currently exist." if topic.nil?
    topic
  end

  def questionnaire
    questionnaire = Questionnaire.find(params[:questionnaire_id])
    flash[:error] = "Questionaire \##{questionnaire.id} does not currently exist." if questionnaire.nil?
    questionnaire
  end

  def create_params
    params.require(:questionnaire).permit(:id, :name, :instructor_id, :private, :min_question_score,
                                          :max_question_score, :created_at, :updated_at, :type,
                                          :display_type, :instruction_loc)
  end
end
