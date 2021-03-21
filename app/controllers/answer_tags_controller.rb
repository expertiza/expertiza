class AnswerTagsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def action_allowed?
    case params[:action]
    when 'index', 'create_edit'
      ['Instructor',
       'Teaching Assistant',
       'Student',
       'Administrator'].include? current_role_name
    when 'machine_tagging'
      ['Instructor',
       'Teaching Assistant',
       'Administrator'].include? current_role_name
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

  # GET /answer_tags/machine_tagging?assignment_id=xx&response_id=xx
  # When response_id is supplied, run the machine tagging on the corresponding response
  # Otherwise, return a list of available responses ids
  def machine_tagging
    assignment = Assignment.find(params[:assignment_id])
    if params[:response_id]
      TagPromptDeployment.where(assignment_id: assignment.id).each do |tag_dep|
        questions_ids = Question.where(questionnaire_id: tag_dep.questionnaire.id, type: tag_dep.question_type).map(&:id)
        answers = Answer.where(question_id: questions_ids, response_id: params[:response_id])
        ReviewMetricsQuery.cache_ws_results(answers, [tag_dep])
      end
      render json: {increment: 1}
    else
      rids = []
      assignment.teams.each do |team|
        if assignment.varying_rubrics_by_round?
          (1..assignment.rounds_of_reviews).each do |round|
            rids += ReviewResponseMap.get_responses_for_team_round(team, round).map(&:id)
          end
        else
          rids += ResponseMap.get_assessments_for(team).map(&:id)
        end
      end
      render json: rids
    end
  end
end
