class JoinGroupRequestsController < ApplicationController
  before_action :set_join_group_request, only: [:show, :edit, :update, :destroy]

  # GET /join_group_requests
  def index
    @join_group_requests = JoinGroupRequest.all
  end

  # GET /join_group_requests/1
  def show
  end

  # GET /join_group_requests/new
  def new
    @join_group_request = JoinGroupRequest.new
  end

  # GET /join_group_requests/1/edit
  def edit
  end

  # POST /join_group_requests
  def create
    @join_group_request = JoinGroupRequest.new(join_group_request_params)

    if @join_group_request.save
      redirect_to @join_group_request, notice: 'Join group request was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /join_group_requests/1
  def update
    if @join_group_request.update(join_group_request_params)
      redirect_to @join_group_request, notice: 'Join group request was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /join_group_requests/1
  def destroy
    @join_group_request.destroy
    redirect_to join_group_requests_url, notice: 'Join group request was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_join_group_request
      @join_group_request = JoinGroupRequest.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def join_group_request_params
      params.require(:join_group_request).permit(:participant_id, :group_id, :comments, :status)
    end
end
