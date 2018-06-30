class FileInstructionsController < ApplicationController
  before_action :set_file_instruction, only: [:show, :edit, :update, :destroy]

  # GET /file_instructions
  def index
    @file_instructions = FileInstruction.all
  end

  # GET /file_instructions/1
  def show
  end

  # GET /file_instructions/new
  def new
    @file_instruction = FileInstruction.new
  end

  # GET /file_instructions/1/edit
  def edit
  end

  # POST /file_instructions
  def create
    @file_instruction = FileInstruction.new(file_instruction_params)

    if @file_instruction.save
      redirect_to @file_instruction, notice: 'File instruction was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /file_instructions/1
  def update
    if @file_instruction.update(file_instruction_params)
      redirect_to @file_instruction, notice: 'File instruction was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /file_instructions/1
  def destroy
    @file_instruction.destroy
    redirect_to file_instructions_url, notice: 'File instruction was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_file_instruction
      @file_instruction = FileInstruction.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def file_instruction_params
      params.require(:file_instruction).permit(:host_url, :file_type, :instructions)
    end
end
