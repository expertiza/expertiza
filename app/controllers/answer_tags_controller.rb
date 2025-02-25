class AnswerTagsController < ApplicationController
  include AuthorizationHelper

  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def action_allowed?
    case params[:action]
    when 'index', 'create_edit'
      current_user_has_student_privileges?
    end
  end

  # GET /answer_tags?assignment_id=xx&user_id=xx&questionnaire_id=xx
  def index
    @tag_prompts = []

    tag_deployments = TagPromptDeployment.all
    tag_deployments = tag_deployments.where(assignment_id: params[:assignment_id]) if params.key?(:assignment_id)
    tag_deployments = tag_deployments.where(questionnaire_id: params[:questionnaire_id]) if params.key?(:questionnaire_id)

    tag_deployments.each do |tag_dep|
      stored_tags_records = AnswerTag.where(tag_prompt_deployment_id: tag_dep.id)
      stored_tags_records = stored_tags_records.where(user_id: params[:user_id]) if params.key?(:user_id)
      stored_tags_records.each do |stored_tag|
        @tag_prompts.append stored_tag
      end
    end

    render json: @tag_prompts
  end

  # POST /answer_tags/create_edit
  def create_edit
    @tag = AnswerTag.where(user_id: current_user,
                           answer_id: params[:answer_id],
                           tag_prompt_deployment_id: params[:tag_prompt_deployment_id]).first_or_create
                    .update_attributes!(value: params[:value])

    render json: @tag
  end

  # DELETE /answer_tags/1
  def destroy; end
end
