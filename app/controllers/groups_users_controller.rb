class GroupsUsersController < ApplicationController
  before_action :set_groups_user, only: [:show, :edit, :update, :destroy]

  # GET /groups_users
  def index
    @groups_users = GroupsUser.all
  end

  # GET /groups_users/1
  def show
  end

  # GET /groups_users/new
  def new
    @groups_user = GroupsUser.new
  end

  # GET /groups_users/1/edit
  def edit
  end

  # POST /groups_users
  def create
    @groups_user = GroupsUser.new(groups_user_params)

    if @groups_user.save
      redirect_to @groups_user, notice: 'Groups user was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /groups_users/1
  def update
    if @groups_user.update(groups_user_params)
      redirect_to @groups_user, notice: 'Groups user was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /groups_users/1
  def destroy
    @groups_user.destroy
    redirect_to groups_users_url, notice: 'Groups user was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_groups_user
      @groups_user = GroupsUser.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def groups_user_params
      params.require(:groups_user).permit(:group_id, :user_id)
    end
end
