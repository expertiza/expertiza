class BookmarkTagsController < ApplicationController
  # GET /bookmark_tags
  # GET /bookmark_tags.xml
  def index
    @bookmark_tags = BookmarkTag.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bookmark_tags }
    end
  end

  # GET /bookmark_tags/1
  # GET /bookmark_tags/1.xml
  def show
    @bookmark_tag = BookmarkTag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bookmark_tag }
    end
  end

  # GET /bookmark_tags/new
  # GET /bookmark_tags/new.xml
  def new
    @bookmark_tag = BookmarkTag.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bookmark_tag }
    end
  end

  # GET /bookmark_tags/1/edit


  # POST /bookmark_tags
  # POST /bookmark_tags.xml
  def create
    @bookmark_tag = BookmarkTag.new(params[:bookmark_tag])

    respond_to do |format|
      if @bookmark_tag.save
        format.html { redirect_to(@bookmark_tag, :notice => 'BookmarkTag was successfully created.') }
        format.xml  { render :xml => @bookmark_tag, :status => :created, :location => @bookmark_tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bookmark_tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bookmark_tags/1
  # PUT /bookmark_tags/1.xml


  # DELETE /bookmark_tags/1
  # DELETE /bookmark_tags/1.xml
  def destroy
    @bookmark_tag = BookmarkTag.find(params[:id])
    @bookmark_tag.destroy

    respond_to do |format|
      format.html { redirect_to(bookmark_tags_url) }
      format.xml  { head :ok }
    end
  end
end
