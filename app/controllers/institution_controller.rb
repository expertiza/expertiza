class InstitutionController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @institutions = Institution.paginate(:page => params[:page],:per_page => 10)
  end

  def show
    @institution = Institution.find(params[:id])
  end

  def new
    @institution = Institution.new
  end

  def create
    @institution = Institution.new(params[:institution])
    if @institution.save
      flash[:notice] = 'Institution was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @institution = Institution.find(params[:id])
  end

  def update
    @institution = Institution.find(params[:id])
    if @institution.update_attributes(params[:institution])
      flash[:notice] = 'Institution was successfully updated.'
      redirect_to :action => 'show', :id => @institution
    else
      render :action => 'edit'
    end
  end

  def destroy
    Institution.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
