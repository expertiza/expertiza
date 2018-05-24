class AnswerController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def action_allowed?
    case params[:action]
      when 'index'
        ['Instructor',
         'Teaching Assistant',
         'Student',
         'Administrator'].include? current_role_name
    end
  end

  # GET /answer?response_id=xx&questionnaire_id=xx
  # reference: https://stackoverflow.com/questions/35639507/parametrized-join-in-rails-4
  def index
    if params.key?(:response_id)
        join_query = sanitize_sql_array(["LEFT JOIN answers ON answers.question_id = questions.id AND answers.response_id = '?'", params[:response_id]])
    end
    where_query = sanitize_sql_array(["questions.questionnaire_id = '?'", params[:questionnaire_id]]) if params.key?(:questionnaire_id)
    # get all answers given the questionaire and response id
    question_answers = Question.joins(join_query)
                           .select('answers.*, questions.txt as qtxt, questions.type as qtype, questions.seq as qseq')
                           .where(where_query)
                           .order("seq asc")
    render :json => question_answers
  end
end