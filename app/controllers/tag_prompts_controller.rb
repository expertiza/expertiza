class TagPromptsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def action_allowed?
    true
  end

  # GET /tag_prompts/view
  def show
    @popup = false
    if params.key?(:popup) && params[:popup].to_s.casecmp('true').zero?
      @popup = true
      render layout: false
    end
  end

  def index
    @tagprompts = TagPrompt.all.order('prompt asc')
    @tagprompts.where!('prompt LIKE ?', "%#{params[:prompt]}%") if params.key?(:prompt) && (!params[:prompt] == '')
    @tagprompts.where!('desc LIKE ?', "%#{params[:desc]}%") if params.key?(:desc) && (!params[:desc] == '')
    @tagprompts.where!('control_type LIKE ?', "%#{params[:control_type]}%") if params.key?(:control_type) && (!params[:control_type] == '')
    render json: @tagprompts
  end

  def create
    @tagprompt = TagPrompt.new(tag_prompts_params)
    @tagprompt.save
    render json: @tagprompts
  end

  def update
    @tagprompt = TagPrompt.find(params[:id])
    @tagprompt.update(prompt: params[:prompt], desc: params[:desc], control_type: params[:control_type])
    render json: @tagprompts
  end

  def destroy
    @tagprompt = TagPrompt.find(params[:id])
    @tagprompt.destroy
    render nothing: true, status: 200
  end

  private

  def tag_prompts_params
    params.permit(:prompt, :desc, :control_type)
  end
end
