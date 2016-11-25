class JoinGroupRequestsController < ApplicationController
  before_action :set_join_group_request, only: [:show, :edit, :update, :destroy]
  def action_allowed?
    current_role_name.eql?("Student")
  end
  def index
    @join_group_requests = JoinGroupRequest.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @join_group_requests }
    end
  end

  def show
    @join_group_request = JoinGroupRequest.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @join_group_request }
    end
  end

  def new
    @join_group_request = JoinGroupRequest.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @join_group_request }
    end
  end

  def edit
    @join_group_request = JoinGroupRequest.find(params[:id])
  end

  # create a new join group request entry for join_group_request table and add it to the table
  def create
    # check if the advertisement is from a group member and if so disallow requesting invitations
    group_member = GroupsUser.where(['group_id =? and user_id =?', params[:group_id], session[:user][:id]])
    group = Group.find(params[:group_id])
    if group.full?
      flash[:note] = "This group is full."
    else
      if !group_member.empty?
        flash[:note] = "You are already a member of this group."
      else

        @join_group_request = JoinGroupRequest.new
        @join_group_request.comments = params[:comments]
        @join_group_request.status = 'P'
        @join_group_request.group_id = params[:group_id]

        participant = Participant.where(user_id: session[:user][:id], parent_id: params[:assignment_id]).first
        @join_group_request.participant_id = participant.id
        respond_to do |format|
          if @join_group_request.save
            format.html { redirect_to(@join_group_request, notice: 'JoinGroupRequest was successfully created.') }
            format.xml  { render xml: @join_group_request, status: :created, location: @join_group_request }
          else
            format.html { render action: "new" }
            format.xml  { render xml: @join_group_request.errors, status: :unprocessable_entity }
          end
        end
      end
    end
  end

  # update join group request entry for join_group_request table and add it to the table
  def update
    @join_group_request = JoinGroupRequest.find(params[:id])
    respond_to do |format|
      if @join_group_request.update_attribute(:comments, params[:join_group_request][:comments])
        format.html { redirect_to(@join_group_request, notice: 'JoinGroupRequest was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @join_group_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @join_group_request = JoinGroupRequest.find(params[:id])
    @join_group_request.destroy

    respond_to do |format|
      format.html { redirect_to(join_group_requests_url) }
      format.xml  { head :ok }
    end
  end

  # decline request to join the group...
  def decline
    @join_group_request = JoinGroupRequest.find(params[:id])
    @join_group_request.status = 'D'
    @join_group_request.save
    redirect_to view_student_groups_path student_id: params[:groups_user_id]
  end
end
