class InstitutionController < ApplicationController
  def action_allowed?
    ['Super-Administrator',
     'Administrator',
     'Instructor'].include? current_role_name
  end

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :list }

  def list
    @institutions = Institution.all
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
      flash[:success] = 'Institution was successfully created.'
      redirect_to :action => 'list'
    else
      flash[:error] = 'Institution was not successfully created.'
      render :action => 'new'
    end
  end

  def edit
    @institution = Institution.find(params[:id])
  end

  def update
    @institution = Institution.find(params[:id])
    if @institution.update_attributes(params[:institution])

      flash[:success] = 'Institution was successfully updated.'
      redirect_to :action => 'show', :id => @institution
    else
      render :action => 'edit'
    end
  end

  def delete
    Institution.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
