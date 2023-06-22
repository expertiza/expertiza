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
         redirect_to: { action: :list }

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
    @question = Question.new(question_params[:question])
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
    @question = Question.find(question_params[:id])
    if @question.update_attributes(question_params[:question])
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

    if AnswerHelper.check_and_delete_responses(questionnaire_id)
      flash[:success] = 'You have successfully deleted the question. Any existing reviews for the questionnaire have been deleted!'
    else
      flash[:success] = 'You have successfully deleted the question!'
    end

    begin
      question.destroy
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

  # save all questions that have been added to a questionnaire
  # uses the params new_question
  # if the questionnaire is a quizquestionnaire then use weights given
  def save_new_questions(questionnaire_id, questionnaire_type)
    if params[:new_question]
      # The new_question array contains all the new questions
      # that should be saved to the database
      params[:new_question].keys.each_with_index do |question_key, index|
        q = Question.new
        q.txt = params[:new_question][question_key]
        q.questionnaire_id = questionnaire_id
        q.type = params[:question_type][question_key][:type]
        q.seq = question_key.to_i
        if questionnaire_type == 'QuizQuestionnaire'
          weight_key = "question_#{index + 1}"
          q.weight = params[:question_weights][weight_key.to_sym]
        end
        q.save unless q.txt.strip.empty?
      end
    end
    return
  end
  # delete questions from a questionnaire
  # uses params questionnaire_id
  # checks if the questions passed in params belongs to this questionnaire or not
  # if yes then it is deleted
  def delete_questions(questionnaire_id)
    # Deletes any questions that, as a result of the edit, are no longer in the questionnaire
    questions = Question.where('questionnaire_id = ?', questionnaire_id)
    @deleted_questions = []
    questions.each do |question|
      should_delete = true
      unless question_params.nil?
        params[:question].each_key do |question_key|
          should_delete = false if question_key.to_s == question.id.to_s
        end
      end

      next unless should_delete

      question.question_advices.each(&:destroy)
      # keep track of the deleted questions
      @deleted_questions.push(question)
      question.destroy
    end
    return
  end
  # Handles questions whose wording changed as a result of the edit
  # uses params questionnaire_id
  # uses params questionnaire_type
  # if the question text is empty then it is deleted
  # else it is updated
  def save_questions
    questionnaire_id = params[:questionnaire_id]
    questionnaire_type = params[:questionnaire_type]
    delete_questions questionnaire_id
    save_new_questions(questionnaire_id, questionnaire_type)
    if params[:question]
      params[:question].keys.each do |question_key|
        if params[:question][question_key][:txt].strip.empty?
          Question.delete(question_key)
        else
          question = Question.find(question_key)
          Rails.logger.info(question.errors.messages.inspect) unless question.update_attributes(params[:question][question_key])
        end
      end
    end
    return
  end
  private

  def question_params
    params.require(:question).permit(:txt, :weight, :questionnaire_id, :seq, :type, :size,
                                     :alternatives, :break_before, :max_label, :min_label, :id, :question)
  end
end

