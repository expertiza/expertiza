class DutiesController < ApplicationController
  before_action :set_duty, only: [:show, :edit, :update, :destroy]

  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

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
  end

  # GET /duties/1/edit
  def edit
  end

  # POST /duties
  def create
    @duty = Duty.new(duty_params)

    if @duty.save
      redirect_to edit_assignment_path(@duty.assignment_id), notice: 'Duty was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /duties/1
  def update
    if @duty.update(duty_params)
      redirect_to @duty, notice: 'Duty was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /duties/1
  def destroy
    @duty.destroy
    redirect_to duties_url, notice: 'Duty was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_duty
      @duty = Duty.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def duty_params
      params.require(:duty).permit(:name, :instructor_id, :assignment_id)
    end
end
