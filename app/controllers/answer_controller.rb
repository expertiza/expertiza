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
  def index
    response_id = params[:response_id] if params.key?(:response_id)
    questionnaire_id = params[:questionnaire_id] if params.key?(:questionnaire_id)
    # get all answers given the questionaire and response id
    question_answers = Question.joins("LEFT JOIN answers ON answers.question_id = questions.id AND answers.response_id = '#{response_id}'")
                           .select('answers.*, questions.txt as qtxt, questions.type as qtype, questions.seq as qseq')
                           .where("questions.questionnaire_id = '#{questionnaire_id}'")
                           .order("seq asc")
    render :json => question_answers
  end
end