class BadgeNominationsController < ApplicationController
  before_action :set_badge_nomination, only: [:show, :edit, :update, :destroy, :assign_badge]
  skip_before_action :authorize

  # GET /badge_nominations
  def index
    @badge_nominations = BadgeNomination.where(assignment_id: Assignment.find(params[:id]))
    @assignment_name = Assignment.find(params[:id]).name
  end

  # GET /badge_nominations/1
  def show
  end

  # GET /badge_nominations/new
  def new
    @badge_nomination = BadgeNomination.new
  end

  # GET /badge_nominations/1/edit
  def edit
  end

  # POST /badge_nominations
  def create
    @badge_nomination = BadgeNomination.new(badge_nomination_params)

    if @badge_nomination.save
      redirect_to @badge_nomination, notice: 'Badge nomination was successfully created.'
    else
      render :new
    end
  end

  def assign_badge
    @badge_nominations.each do |badge_nomination|
      AwardedBadge.create(participant_id:badge_nomination.participant_id, badge_id:badge_nomination.badge_id)
      redirect_to root_path #TODO: This has to be updated to the assigned badges view once E17A2 has added the view
    end
  end

  # PATCH/PUT /badge_nominations/1
  def update
    if @badge_nomination.update(badge_nomination_params)
      redirect_to @badge_nomination, notice: 'Badge nomination was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /badge_nominations/1
  def destroy
    @badge_nomination.destroy
    redirect_to badge_nominations_url, notice: 'Badge nomination was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_badge_nomination
      @badge_nominations = BadgeNomination.where(assignment_id: Assignment.find(params[:id]))
    end

    # Only allow a trusted parameter "white list" through.
    def badge_nomination_params
      params.require(:badge_nomination).permit(:assignment_id, :participant_id, :badge_id)
    end
end
