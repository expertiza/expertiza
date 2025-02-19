# frozen_string_literal: true

class UserPastebinsController < ApplicationController
  include AuthorizationHelper

  before_action :set_user_pastebin, only: %i[show edit update destroy]

  def action_allowed?
    case params[:action]
    when 'index', 'create'
      current_user_has_student_privileges?
    end
  end

  # GET /user_pastebins
  def index
    json = UserPastebin.get_current_user_pastebin_json current_user
    render json: json
  rescue StandardError => e
    flash[:error] = e.message
  end

  # GET /user_pastebins/1
  def show; end

  # GET /user_pastebins/new
  def new
    @user_pastebin = UserPastebin.new
  end

  # GET /user_pastebins/1/edit
  def edit; end

  # POST /user_pastebins
  def create
    @user_pastebin = UserPastebin.new(user_pastebin_params)
    @user_pastebin.user_id = current_user.id
    if @user_pastebin.save
      data = UserPastebin.get_current_user_pastebin_json current_user
      render json: data, status: 200
    else
      data = { message: 'Short Form or Long Form in the Text Macro is not valid' }
      render json: data, status: 422
    end
  end

  # PATCH/PUT /user_pastebins/1
  def update
    if @user_pastebin.update(user_pastebin_params)
      redirect_to @user_pastebin, notice: 'User pastebin was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /user_pastebins/1
  def destroy
    @user_pastebin.destroy
    redirect_to user_pastebins_url, notice: 'User pastebin was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user_pastebin
    @user_pastebin = UserPastebin.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_pastebin_params
    params.permit(:short_form, :long_form)
  end
end
