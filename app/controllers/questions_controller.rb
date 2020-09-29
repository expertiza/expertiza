class QuestionsController < ApplicationController
  include AuthorizationHelper

  # A question is a single entry within a questionnaire
  # Questions provide a way of scoring an object
  # based on either a numeric value or a true/false
  # state.

  # Default action, same as list
  def index
    list
    render action: 'list'
  end

  def action_allowed?
    current_user_has_ta_privileges?
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: %i[destroy create update],
         redirect_to: {action: :list}

  # List all questions in paginated view
  def list
    @questions = Question.paginate(page: params[:page], per_page: 10)
  end

  # Display a given question
  def show
    @question = Question.find(params[:id])
  end

  # Provide the user with the ability to define
  # a new question
  def new
    @question = Question.new
  end

  # Save a question created by the user
  # follows from new
  def create
    @question = Question.new(params[:question])
    if @question.save
      flash[:notice] = 'The question was successfully created.'
      redirect_to action: 'list'
    else
      render action: 'new'
    end
  end

  # edit an existing question
  def edit
    @question = Question.find(params[:id])
  end

  # save the update to an existing question
  # follows from edit
  def update
    @question = Question.find(params[:id])
    if @question.update_attributes(params[:question])
      flash[:notice] = 'The question was successfully updated.'
      redirect_to action: 'show', id: @question
    else
      render action: 'edit'
    end
  end

  # Remove question from database and
  # return to list
  def destroy
    question = Question.find(params[:id])
    questionnaire_id = question.questionnaire_id
    begin
      question.destroy
      flash[:success] = "You have successfully deleted the question!"
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
    redirect_to edit_questionnaire_path(questionnaire_id.to_s.to_sym)
  end

  # required for answer tagging
  def types
    types = Question.distinct.pluck(:type)
    render json: types.to_a
  end
end
