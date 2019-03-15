class AccountRequestsController < ApplicationController
  before_action :set_account_request, only: [:show, :edit, :update, :destroy]

  # GET /account_requests
  def index
    @account_requests = AccountRequest.all
  end

  # GET /account_requests/1
  def show
  end

  # GET /account_requests/new
  def new
    @account_request = AccountRequest.new
  end

  # GET /account_requests/1/edit
  def edit
  end

  # POST /account_requests
  def create
    @account_request = AccountRequest.new(account_request_params)

    if @account_request.save
      redirect_to @account_request, notice: 'Account request was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /account_requests/1
  def update
    if @account_request.update(account_request_params)
      redirect_to @account_request, notice: 'Account request was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /account_requests/1
  def destroy
    @account_request.destroy
    redirect_to account_requests_url, notice: 'Account request was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account_request
      @account_request = AccountRequest.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def account_request_params
      params.require(:account_request).permit(:name, :role_id, :fullname, :institution_id, :email, :status, :self_introduction)
    end
end
