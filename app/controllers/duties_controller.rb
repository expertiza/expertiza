
class DutiesController < ApplicationController
  include AuthorizationHelper

  # duties can be created/modified by Teaching Assistants, Instructor, Admin, Super Admin
  def action_allowed?
    current_user_has_ta_privileges?
  end

  before_action :set_duty, only: [:show, :edit, :update, :destroy]

  # GET /duties
  def index
    @duties = Duty.all
  end

  # GET /duties/1
  def show
  end

  # GET /duties/new
  def new
    @duty = Duty.new
    @id = params[:id]
  end

  # GET /duties/1/edit
  def edit
  end

  # POST /duties
  def create
    @duty = Duty.new

    @duty.assignment_id = params[:duty][:assignment_id]
    @duty.max_members_for_duty = params[:duty][:max_members_for_duty]
    @duty.name = params[:duty][:name]

    if @duty.save
      # When the duty (role) is created successfully we return back to the assignment edit page
      redirect_to edit_assignment_path(params[:duty][:assignment_id]), notice: 'Role was successfully created.'
    else
      redirect_to_create_page_and_show_error
    end
  end

  # PATCH/PUT /duties/1
  def update
    @duty = Duty.find(params[:id])

    @duty.assignment_id = params[:duty][:assignment_id]
    @duty.max_members_for_duty = params[:duty][:max_members_for_duty]
    @duty.name = params[:duty][:name]

    if @duty.save
      redirect_to edit_assignment_path(params[:duty][:assignment_id]), notice: 'Role was successfully updated.'
    else
      redirect_to_create_page_and_show_error
    end
  end

  # DELETE /duties/1
  def destroy
    @duty = Duty.find(params[:id])
    @duty.destroy
    redirect_to edit_assignment_path(params[:assignment_id]), notice: 'Role was successfully destroyed.'
  end

  def delete_duty
    @duty = Duty.find(params[:id])
    @duty.destroy
    redirect_to edit_assignment_path(params[:assignment_id]), notice: 'Role was successfully deleted.'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_duty
    @duty = Duty.find(params[:id])
  end

  def redirect_to_create_page_and_show_error
    # TODO @john @nicholas is there any better way to handle error messages ?
  error_message = ""
    @duty.errors.each do |field, error| error_message << error end

    flash[:error] = error_message
    redirect_to :action => :new, :id=> params[:duty][:assignment_id]
  end
end