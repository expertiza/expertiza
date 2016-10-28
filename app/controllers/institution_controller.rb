class InstitutionController < ApplicationController
  def action_allowed?
    ['Super-Administrator',
     'Administrator',
     'Instructor'].include? current_role_name
  end

  def index
    list
    render action: 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: [:destroy, :create, :update],
         redirect_to: {action: :list}

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
    @institution = Institution.new(name: params[:institution][:name])
    if @institution.save
      flash[:success] = 'The institution was successfully created.'
      redirect_to action: 'list'
    else
      flash[:error] = 'The creation of the institution failed.'
      render action: 'new'
    end
  end

  def edit
    @institution = Institution.find(params[:id])
  end

  def update
    @institution = Institution.find(params[:id])
    if @institution.update_attribute(:name, params[:institution][:name])

      flash[:success] = 'The institution was successfully updated.'
      redirect_to action: 'list'
    else
      render action: 'edit'
    end
  end

  def delete
    Institution.find(params[:id]).destroy
    redirect_to action: 'list'
  end
end
