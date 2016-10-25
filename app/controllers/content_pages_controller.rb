class ContentPagesController < ApplicationController
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: [:destroy, :create, :update],
         redirect_to: {action: :list}

  def action_allowed?
    case params[:action]
    when 'view', 'view_default'
      true
    else
      current_role_name.eql?('Super-Administrator')
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
    @content_page = ContentPage.find_by_name(params[:page_name])
    unless @content_page
      @content_page = if @settings
                        ContentPage.find(@settings.not_found_page_id)
                      else
                        ContentPage.new(id: nil,
                                        content: '(no such page)')
                      end
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
    @content_page = ContentPage.new(params[:content_page])
    begin
      @content_page.save!
      flash[:notice] = 'The content page was successfully created.'
      Role.rebuild_cache
      redirect_to action: 'list'
    rescue
      foreign

      render action: 'new'
    end
  end

  def edit
    @content_page = ContentPage.find(params[:id])
    foreign
  end

  def update
    @content_page = ContentPage.find(params[:id])
    if @content_page.update_attributes(params[:content_page])
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

    if @menu_items.empty? and !@system_pages
      @content_page.destroy
      Role.rebuild_cache
      redirect_to action: 'list'
    else
      flash.now[:error] = "You cannot delete this content page as it has dependants. (See below)"
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
                    .where(['content_page_id=?', @content_page.id])
      @system_pages = @settings.system_pages @content_page.id
    end
  end
end
