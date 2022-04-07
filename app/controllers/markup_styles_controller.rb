class MarkupStylesController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    current_user_has_super_admin_privileges?
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: %i[destroy create update],
         redirect_to: { action: :list }

  def index
    list
    render action: 'list'
  end

  def list
    @markup_styles = MarkupStyle.paginate(page: params[:page], per_page: 10)
  end

  def show
    @markup_style = MarkupStyle.find(params[:id])
  end

  def new
    @markup_style = MarkupStyle.new
  end

  def create
    @markup_style = MarkupStyle.new(markup_styles_params[:markup_style])
    begin
      @markup_style.save!
      flash[:notice] = 'The markup style was successfully created.'
      redirect_to action: 'list'
    rescue StandardError
      render action: 'new'
    end
  end

  def edit
    @markup_style = MarkupStyle.find(params[:id])
  end

  def update
    @markup_style = MarkupStyle.find(params[:id])
    if @markup_style.update_attributes(markup_styles_params)
      redirect_to action: 'show', id: @markup_style
      flash[:notice] = 'The markup style was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    MarkupStyle.find(params[:id]).destroy
    redirect_to action: 'list'
  end

  private

  def markup_styles_params
    params.permit(:id, :markup_style)
  end
end
