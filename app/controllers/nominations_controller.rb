class NominationsController < ApplicationController
  before_action :set_nomination, only: [:show, :edit, :update, :destroy]

  # GET /nominations
  def index
    @nominations = Nomination.all
  end

  # GET /nominations/1
  def show
  end

  # GET /nominations/new
  def new
    @nomination = Nomination.new
  end

  # GET /nominations/1/edit
  def edit
  end

  # POST /nominations
  def create
    @nomination = Nomination.new(nomination_params)

    if @nomination.save
      redirect_to @nomination, notice: 'Nomination was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /nominations/1
  def update
    if @nomination.update(nomination_params)
      redirect_to @nomination, notice: 'Nomination was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /nominations/1
  def destroy
    @nomination.destroy
    redirect_to nominations_url, notice: 'Nomination was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nomination
      @nomination = Nomination.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def nomination_params
      params.require(:nomination).permit(:assignment_badge_id, :recipient_id, :nominator_id)
    end
end
