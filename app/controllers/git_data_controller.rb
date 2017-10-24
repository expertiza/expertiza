class GitDataController < ApplicationController
  before_action :set_git_datum, only: [:show, :edit, :update, :destroy]
  include GitDataHelper

  # GET /git_data
  def index
    @git_data = GitDatum.all

  end

  # GET /git_data/1
  def show
  end

  # GET /git_data/new
  def new
    @git_datum = GitDatum.new
  end

  # GET /git_data/1/edit
  def edit
  end

  # POST /git_data
  def create
    @git_datum = GitDatum.new(git_datum_params)

    if @git_datum.save
      redirect_to @git_datum, notice: 'Git datum was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /git_data/1
  def update
    if @git_datum.update(git_datum_params)
      redirect_to @git_datum, notice: 'Git datum was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /git_data/1
  def destroy
    @git_datum.destroy
    redirect_to git_data_url, notice: 'Git datum was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_git_datum
      @git_datum = GitDatum.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def git_datum_params
      params.require(:git_datum).permit(:pull_request, :author, :commits, :files, :additions, :deletions, :date)
    end

  end
