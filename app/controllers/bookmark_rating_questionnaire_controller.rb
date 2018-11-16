# Author: Rahul Iyer
# Email: rsiyer2@ncsu.edu

class BookmarkRatingQuestionnaireController < ApplicationController
  def create
    if params[:assignment_id].nil?
      flash[:error] = "Missing Assignment:" + params[:topic_id]
      return
    elsif params[:questionnaire_id].nil?
      flash[:error] = "Missing questionnaire:" + params[:questionnaire_id]
      return
    end

    topic = Assignment.find(params[:assignment_id])
    if topic.nil?
      flash[:error] = "Assignment \##{opic.id} does not currently exist."
      return
    end

    questionnaire = Questionnaire.find(params[:questionnaire_id])
    if questionnaire.nil?
      flash[:error] = "Questionaire \##{questionnaire.id} does not currently exist."
      return
    end

    @bookmark_rating_questionnaire = BookmarkRatingQuestionnaire.new(params)
    @bookmark_rating_questionnaire.save

    respond_to do |format|
      format.json { render json: @bookmark_rating_questionnaire }
    end
  end
end
