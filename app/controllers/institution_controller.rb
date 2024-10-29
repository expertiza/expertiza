class InstitutionController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    current_user_has_instructor_privileges?
  end

  def index
    list
    render action: 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: %i[destroy create update],
         redirect_to: { action: :list }

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
    @institution = Institution.new(institution_params)
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

  private

  def institution_params
    params.require(:institution).permit(:name)
  end
end
