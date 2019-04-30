class QuestionsController < ApplicationController
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
    ['Super-Administrator',
     'Administrator',
     'Instructor',
     'Teaching Assistant'].include? current_role_name
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

  def delete_answers(response_id)
    response = Answer.where(response_id: response_id)
    response.each do |answer|
      begin
        answer.destroy
        flash[:success] = "You have successfully deleted the answer!"
      rescue StandardError
        flash[:error] = $ERROR_INFO
      end
    end
  end
  
  # Remove question from database and
  # return to list
  def destroy
    question = Question.find(params[:id])
    questionnaire_id = question.questionnaire_id
    question_ids=Question.where(questionnaire_id: questionnaire_id).ids
    get_answers(questionnaire_id,question_ids)
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

# Beginning of new method for OODD project 4
  def get_answers(questionnaire_id,question_ids)
    response_ids=[]
    question_ids.each do |question|
      response_ids=response_ids+Answer.where(question_id: question).pluck("response_id")
    end
    response_ids=response_ids.uniq
    user_id_to_answers={}
    response_ids.each do |response|
      response_map_id = Response.where(id: response).pluck("map_id")
      reviewer_id = ResponseMap.where(id: response_map_id).pluck("reviewer_id", "reviewed_object_id")
      assignment_name = Assignment.where(id: reviewer_id[1]).pluck("name")
      user_details = User.where(id: reviewer_id[0]).pluck("email", "name")
      answers_per_user = Answer.where(response_id: response).pluck("comments")
      user_id_to_answers[user_details[0]] = [answers_per_user, response, user_details[1], assignment_name]
    end

    # Mail the answers to each user and if successfull, delete the answers
    user_id_to_answers.each do |email, answers|
      if review_mailer(email, answers[0], answers[2])
        delete_answers(answers[1])
      end
    end
  end

  def review_mailer(email, answers, name, assignment_name)
    begin
      Mailer.notify_review_rubric_change(
        to: email,
        subject: 'Expertiza Notification: The review rubric has been changed, please re-attempt the review',
        body: {
          name: name,
          assignment_name: assignment_name,
          answers: answers
        }
        ).deliver_now
      true
    rescue StandardError
      flash[:error] = $ERROR_INFO
      false
    end
  end

end
