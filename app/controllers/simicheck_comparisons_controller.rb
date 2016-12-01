class SimicheckComparisonsController < ApplicationController
  before_action :set_simicheck_comparison, only: [:show, :edit, :update, :destroy]

  # GET /simicheck_comparisons
  def index
    @simicheck_comparisons = SimicheckComparison.all
  end

  # GET /simicheck_comparisons/1
  def show
  end

  # GET /simicheck_comparisons/new
  def new
    @simicheck_comparison = SimicheckComparison.new
  end

  # GET /simicheck_comparisons/1/edit
  def edit
  end

  # POST /simicheck_comparisons
  def create
    @simicheck_comparison = SimicheckComparison.new(simicheck_comparison_params)

    if @simicheck_comparison.save
      redirect_to @simicheck_comparison, notice: 'Simicheck comparison was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /simicheck_comparisons/1
  def update
    if @simicheck_comparison.update(simicheck_comparison_params)
      redirect_to @simicheck_comparison, notice: 'Simicheck comparison was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /simicheck_comparisons/1
  def destroy
    @simicheck_comparison.destroy
    redirect_to simicheck_comparisons_url, notice: 'Simicheck comparison was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_simicheck_comparison
      @simicheck_comparison = SimicheckComparison.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def simicheck_comparison_params
      params.require(:simicheck_comparison).permit(:comparison_key, :file_type)
    end
end
