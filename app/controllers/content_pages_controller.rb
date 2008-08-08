class ContentPagesController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    list
    render :action => 'list'
  end

  def list
    @content_pages = ContentPage.find(:all,
                                      :order => 'name')
  end

  def show
    @content_page = ContentPage.find(params[:id])
    foreign
  end

  def view
    @content_page = ContentPage.find_by_name(params[:page_name])
    if not @content_page
      if @settings
        @content_page = ContentPage.find(@settings.not_found_page_id)
      else
        @content_page = ContentPage.new(:id => nil, 
                                        :content => '(no such page)')
      end
    end
  end

  def view_default
    if @settings
      @content_page = ContentPage.find(@settings.site_default_page_id)
    else
      @content_page = ContentPage.new(:id => nil, 
                                        :content => '(Site not configured)')
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
      flash[:notice] = 'ContentPage was successfully created.'
      Role.rebuild_cache
      redirect_to :action => 'list'
    rescue
      foreign
      
      render :action => 'new'
    end
  end

  def edit
    @content_page = ContentPage.find(params[:id])
    foreign()
  end

  def update
    @content_page = ContentPage.find(params[:id])
    if @content_page.update_attributes(params[:content_page])
      flash[:notice] = 'ContentPage was successfully updated.'
      Role.rebuild_cache
      redirect_to :action => 'show', :id => @content_page
    else
      foreign
      render :action => 'edit'
    end
  end

  def destroy
    @content_page = ContentPage.find(params[:id])
    foreign
    
    if @menu_items.length == 0 and not @system_pages
      @content_page.destroy
      Role.rebuild_cache
      redirect_to :action => 'list'
    else
      flash.now[:error] = "Cannot delete this Content Page as it has dependants (see below)"
      render :action => 'show'
    end
  end


  protected

  def foreign
    @markup_styles = MarkupStyle.find(:all, :order => 'name')
    @permissions = Permission.find(:all, :order => 'name')
    if @content_page.id
      @menu_items = MenuItem.find(:all,
                                  :order => 'label',
                                  :conditions => ['content_page_id=?', 
                                                  @content_page.id])
      @system_pages = @settings.system_pages @content_page.id
    end
  end


end
