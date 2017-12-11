class PaperWriterMappingsController < ApplicationController
  before_action :set_paper_writer_mapping, only: [:show, :edit, :update, :destroy]

  # GET /paper_writer_mappings
  def index
    @paper_writer_mappings = PaperWriterMapping.all
  end

  # GET /paper_writer_mappings/1
  def show
  end

  # GET /paper_writer_mappings/new
  def new
    @paper_writer_mapping = PaperWriterMapping.new
  end

  # GET /paper_writer_mappings/1/edit
  def edit
  end

  # POST /paper_writer_mappings
  def create
    @paper_writer_mapping = PaperWriterMapping.new(paper_writer_mapping_params)

    if @paper_writer_mapping.save
      redirect_to @paper_writer_mapping, notice: 'Paper writer mapping was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /paper_writer_mappings/1
  def update
    if @paper_writer_mapping.update(paper_writer_mapping_params)
      redirect_to @paper_writer_mapping, notice: 'Paper writer mapping was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /paper_writer_mappings/1
  def destroy
    @paper_writer_mapping.destroy
    redirect_to paper_writer_mappings_url, notice: 'Paper writer mapping was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_paper_writer_mapping
      @paper_writer_mapping = PaperWriterMapping.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def paper_writer_mapping_params
      params.require(:paper_writer_mapping).permit(:writer_id, :paper_id)
    end
end
