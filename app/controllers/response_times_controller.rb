class ResponseTimesController < ApplicationController
  before_action :set_response_time, only: [:show, :edit, :update, :destroy]

  # GET /response_times
  def index
    @response_times = ResponseTime.all
  end

  # GET /response_times/1
  def show
  end

  # GET /response_times/new
  def new
    @response_time = ResponseTime.new
  end

  # GET /response_times/1/edit
  def edit
  end

  # POST /response_times
  def create
    @response_time = ResponseTime.new(response_time_params)

    if @response_time.save
      redirect_to @response_time, notice: 'Response time was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /response_times/1
  def update
    if @response_time.update(response_time_params)
      redirect_to @response_time, notice: 'Response time was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /response_times/1
  def destroy
    @response_time.destroy
    redirect_to response_times_url, notice: 'Response time was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_response_time
      @response_time = ResponseTime.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def response_time_params
      params[:response_time]
    end
end
