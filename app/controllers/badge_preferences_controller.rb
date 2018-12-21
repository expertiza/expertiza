class BadgePreferencesController < ApplicationController
  before_action :set_badge_preference,only: [:show, :edit, :update, :destroy]

  # GET /badge_preferences
  def index
    @badge_preferences = BadgePreference.all
  end

  # Check if disclaimer preference is true then don't show the warning again.
  def check_disclaimer_preference
    @badge_preferences = BadgePreference.find_by_instructor_id(params['instructor_id'])
    if !@badge_preferences.nil? and @badge_preferences.preference.equal?(true)
      return true
    else
      return false
    end
  end
  # GET /badge_preferences/1
  def show
  end

  # GET /badge_preferences/new
  def new
    @badge_preference = BadgePreference.new
  end

  # GET /badge_preferences/1/edit
  def edit
  end

  # POST /badge_preferences
  def create
    @badge_preference = BadgePreference.new(badge_preference_params)

    if params['disclaimer_preference'].equal?(true) and @badge_preference.save
      redirect_to @badge_preference, notice: 'Badge preference was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /badge_preferences/1
  def update
    if @badge_preference.update(badge_preference_params)
      redirect_to @badge_preference, notice: 'Badge preference was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /badge_preferences/1
  def destroy
    @badge_preference.destroy
    redirect_to badge_preferences_url, notice: 'Badge preference was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_badge_preference
      @badge_preference = BadgePreference.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def badge_preference_params
      params.require(:badge_preference).permit(:instructor_id, :preference)
    end
end
