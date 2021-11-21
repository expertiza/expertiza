class RevisionPlanTeamMapsController < ApplicationController
  before_action :set_revision_plan_team_map, only: [:show, :edit, :update, :destroy]

  # GET /revision_plan_team_maps
  def index
    @revision_plan_team_maps = RevisionPlanTeamMap.all
  end

  # GET /revision_plan_team_maps/1
  def show
  end

  # GET /revision_plan_team_maps/new
  def new
    @revision_plan_team_map = RevisionPlanTeamMap.new
  end

  # GET /revision_plan_team_maps/1/edit
  def edit
  end

  # POST /revision_plan_team_maps
  def create
    @revision_plan_team_map = RevisionPlanTeamMap.new(revision_plan_team_map_params)

    if @revision_plan_team_map.save
      redirect_to @revision_plan_team_map, notice: 'Revision plan team map was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /revision_plan_team_maps/1
  def update
    if @revision_plan_team_map.update(revision_plan_team_map_params)
      redirect_to @revision_plan_team_map, notice: 'Revision plan team map was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /revision_plan_team_maps/1
  def destroy
    @revision_plan_team_map.destroy
    redirect_to revision_plan_team_maps_url, notice: 'Revision plan team map was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_revision_plan_team_map
      @revision_plan_team_map = RevisionPlanTeamMap.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def revision_plan_team_map_params
      params.require(:revision_plan_team_map).permit(:revision_plan_team_map_id, :team_id, :used_in_round)
    end
end
