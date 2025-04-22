class TeamsParticipantsController < ApplicationController
  before_action :set_team,   only: %i[index new create delete_selected]
  before_action :set_member, only: %i[destroy]

  # GET /teams/:team_id/teams_participants
  def index
    @assignment         = @team.parent
    @teams_participants = @team.teams_participants.includes(participant: :user)
  end

  # GET /teams/:team_id/teams_participants/new
  def new
    # renders only the form
  end

  # POST /teams/:team_id/teams_participants
  def create
    user = User.find_by(name: join_params[:user_name])
    unless user
      flash.now[:error] = "No user found with name #{join_params[:user_name].inspect}"
      return render :new, status: :unprocessable_entity
    end

    participant = Participant.find_by(user_id: user.id, parent_id: @team.parent_id)
    unless participant
      flash.now[:error] = "#{user.name} isn’t registered on this assignment yet"
      return render :new, status: :unprocessable_entity
    end

    tp = TeamsParticipant.new(team: @team, participant: participant)
    if tp.save
      flash[:notice] = "#{user.name} was added to “#{@team.name}”"
      redirect_to team_teams_participants_path(@team)
    else
      flash.now[:error] = tp.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /teams_participants/:id
  def destroy
    if @member.destroy
      flash[:notice] = "Member removed"
    else
      flash[:error] = "Couldn’t remove that member"
    end
    redirect_to team_teams_participants_path(@member.team)
  end

  # DELETE /teams/:team_id/teams_participants/delete_selected?selected[]=1&selected[]=2
  def delete_selected
    ids     = Array(params[:selected]).map(&:to_i).uniq
    deleted = TeamsParticipant.where(id: ids, team_id: @team.id).destroy_all
    flash[:notice] = "Removed #{deleted.size} #{'member'.pluralize(deleted.size)}."
    redirect_to team_teams_participants_path(@team)
  end

  private

  def set_team
    @team = Team.find(params[:team_id])
  end

  def set_member
    @member = TeamsParticipant.find(params[:id])
  end

  def join_params
    params.require(:teams_participant).permit(:user_name)
  end
end
