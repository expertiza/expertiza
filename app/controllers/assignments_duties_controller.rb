class AssignmentsDutiesController < ApplicationController
  before_action :set_assignments_duty, only: [:show, :edit, :update, :destroy]

  # GET /assignments_duties
  def index
    @assignments_duties = AssignmentsDuty.all
  end

  # GET /assignments_duties/1
  def show
  end

  # GET /assignments_duties/new
  def new
    @assignments_duty = AssignmentsDuty.new
  end

  # GET /assignments_duties/1/edit
  def edit
  end

  # POST /assignments_duties
  def create
    @assignments_duty = AssignmentsDuty.new(assignments_duty_params)

    if @assignments_duty.save
      redirect_to @assignments_duty, notice: 'Assignments duty was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /assignments_duties/1
  def update
    if @assignments_duty.update(assignments_duty_params)
      redirect_to @assignments_duty, notice: 'Assignments duty was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /assignments_duties/1
  def destroy
    @assignments_duty.destroy
    redirect_to assignments_duties_url, notice: 'Assignments duty was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignments_duty
      @assignments_duty = AssignmentsDuty.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def assignments_duty_params
      params.require(:assignments_duty).permit(:duty_id => [], :assignment_id => [])
    end
end
