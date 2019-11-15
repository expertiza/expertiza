class ResponseTrialsController < ApplicationController
  before_action :set_response_trial, only: [:show, :edit, :update, :destroy]

  # GET /response_trials
  def index
    @response_trials = ResponseTrial.all
  end

  # GET /response_trials/1
  def show
  end

  # GET /response_trials/new
  def new
    @response_trial = ResponseTrial.new
  end

  # GET /response_trials/1/edit
  def edit
  end

  # POST /response_trials
  def create
    @response_trial = ResponseTrial.new(response_trial_params)

    if @response_trial.save
      redirect_to @response_trial, notice: 'Response trial was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /response_trials/1
  def update
    if @response_trial.update(response_trial_params)
      redirect_to @response_trial, notice: 'Response trial was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /response_trials/1
  def destroy
    @response_trial.destroy
    redirect_to response_trials_url, notice: 'Response trial was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_response_trial
      @response_trial = ResponseTrial.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def response_trial_params
      params[:response_trial]
    end
end
