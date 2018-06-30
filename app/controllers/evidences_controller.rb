class EvidencesController < ApplicationController
  before_action :set_evidence, only: [:show, :edit, :update, :destroy]

  # GET /evidences
  def index
    @evidences = Evidence.all
  end

  # GET /evidences/1
  def show
  end

  # GET /evidences/new
  def new
    @evidence = Evidence.new
  end

  # GET /evidences/1/edit
  def edit
  end

  # POST /evidences
  def create
    @evidence = Evidence.new(evidence_params)

    if @evidence.save
      redirect_to @evidence, notice: 'Evidence was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /evidences/1
  def update
    if @evidence.update(evidence_params)
      redirect_to @evidence, notice: 'Evidence was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /evidences/1
  def destroy
    @evidence.destroy
    redirect_to evidences_url, notice: 'Evidence was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_evidence
      @evidence = Evidence.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def evidence_params
      params.require(:evidence).permit(:awarded_badge_id, :file_name)
    end
end
