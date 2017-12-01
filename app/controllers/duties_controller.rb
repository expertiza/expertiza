class DutiesController < ApplicationController
  before_action :set_duty, only: [:show, :edit, :update, :destroy]

  # Give permission to manage notifications to appropriate roles
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


  # GET for duties that are not mapped to any questionnaire
  def unmapped_duties
    duties = Duty.get_unmapped_duties
  end

  # POST /duties
  def create
    @duty = Duty.new(duty_params)

    if @duty.save
      flash[:note] = 'The Duty was successfully created.'
      redirect_to @duty
    else
      flash[:note] = 'The Duty was not created.'
      render :new
    end
  end

  # PATCH/PUT /duties/1
  def update
    if @duty.update(duty_params)
      flash[:note] = 'The Duty was successfully saved.'
      redirect_to @duty
    else
      render :edit
    end
  end

  # DELETE /duties/1
  def destroy
    @duty.destroy
    flash[:note] = 'The Duty was successfully destroyed.'

    redirect_to duties_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_duty
      @duty = Duty.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def duty_params
      params.require(:duty).permit(:duty_name, :multiple_duty)
    end
end
