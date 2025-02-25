class ContentPagesController < ApplicationController
  include AuthorizationHelper

  # Currently, this controller is only used for managing pull-down menus.
  # Further development is currently paused on this controller, please consult before changing/using the code.
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: %i[destroy create update],
         redirect_to: { action: :list }

  def action_allowed?
    case params[:action]
    when 'view', 'view_default'
      true
    else
      current_user_has_super_admin_privileges?
    end
  end

  def index
    list
    render action: 'list'
  end

  def list
    @content_pages = ContentPage.order('name')
  end

  def show
    @content_page = ContentPage.find(params[:id])
    foreign
  end

  def view
    @content_page = ContentPage.find_by(name: params[:page_name])
    @content_page ||= if @settings
                        ContentPage.find(@settings.not_found_page_id)
                      else
                        ContentPage.new(id: nil,
                                        content: '(no such page)')
                      end
  end

  def view_default
    @content_page = if @settings
                      ContentPage.find(@settings.site_default_page_id)
                    else
                      ContentPage.new(id: nil,
                                      content: '(Site not configured)')
                    end
  end

  def new
    @content_page = ContentPage.new
    foreign
  end

  def create
    @content_page = ContentPage.new(content_pages_params[:content_page])
    begin
      @content_page.save!
      flash[:notice] = 'The content page was successfully created.'
      Role.rebuild_cache
      redirect_to action: 'list'
    rescue StandardError
      foreign

      render action: 'new'
    end
  end

  def edit
    @content_page = ContentPage.find(params[:id])
    foreign
  end

  def update
    @content_page = ContentPage.find(content_pages_params[:id])
    if @content_page.update_attributes(content_pages_params[:content_page])
      flash[:notice] = 'The content page was successfully updated.'
      Role.rebuild_cache
      redirect_to action: 'show', id: @content_page
    else
      foreign
      render action: 'edit'
    end
  end

  def destroy
    @content_page = ContentPage.find(params[:id])
    foreign

    if @menu_items.empty? && !@system_pages
      @content_page.destroy
      Role.rebuild_cache
      redirect_to action: 'list'
    else
      flash.now[:error] = 'You cannot delete this content page as it has dependants. (See below)'
      render action: 'show'
    end
  end

  protected

  def foreign
    @markup_styles = MarkupStyle.order('name')
    @permissions = Permission.order('name')
    if @content_page.id
      @menu_items = MenuItem
                    .order('label')
                    .where('content_page_id=?', @content_page.id)
      @system_pages = @settings.system_pages @content_page.id
    end
  end

  private

  def content_pages_params
    params.permit(:id, :content_page)
  end
end
