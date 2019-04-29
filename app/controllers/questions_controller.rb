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

  def delete_answers(a,b)
    for i in b do
      sql = "DELETE FROM answers WHERE question_id="+i.to_s
      temp=ActiveRecord::Base.connection.execute(sql)
    end
  end
  
  # Remove question from database and
  # return to list
  def destroy
    question = Question.find(params[:id])
    questionnaire_id = question.questionnaire_id
    question_ids=Question.where(questionnaire_id: questionnaire_id).ids
    delete_answers2(questionnaire_id,question_ids)
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
  def  delete_answers2(questionnaire_id,question_ids)
    # i=0
    response_ids=[]
    question_ids.each do |question|
      response_ids=response_ids+Answer.where(question_id: question).select("response_id")
    end
    # while i<question_ids.length()
    #   response_ids=response_ids+Answer.where(question_id: question_ids[i]).select("response_id")
    #   i=i+1
    # end
    response_ids=response_ids.uniq
    # i=0
    user_id_to_answers={}
    response_ids.each do |response|
      response_map_id=Response.where(id: response).select("map_id")
      reviewer_id=Response_map.where(id: response_map_id).select("reviewer_id")
      user_email = User.where(id: reviewer_id).select("email")
      answers_per_user=Answer.where(response_id: response).ids
      user_id_to_answers[user_email]=answers_per_user
    end
    # while i<response_ids.length()
    #   response_map_id=Response.where(id: response_ids[i]).select("map_id")
    #   reviewer_id=Response_map.where(id: response_map_id).select("reviewer_id")
    #   answers_per_user=Answer.where(response_id: response_ids[i]).ids
    #   user_id_to_answers[reviewer_id]=answers_per_user
    #   i=i+1
    # end
    return user_id_to_answers
# call mailing function
# delete_and_mail(user_id_to_answers)	
  end
  
end
