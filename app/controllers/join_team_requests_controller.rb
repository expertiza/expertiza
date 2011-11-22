class JoinTeamRequestsController < ApplicationController
  # GET /join_team_requests
  # GET /join_team_requests.xml
  def index
    @join_team_requests = JoinTeamRequest.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @join_team_requests }
    end
  end

  # GET /join_team_requests/1
  # GET /join_team_requests/1.xml
  def show
    @join_team_request = JoinTeamRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @join_team_request }
    end
  end

  # GET /join_team_requests/new
  # GET /join_team_requests/new.xml
  def new
    @join_team_request = JoinTeamRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @join_team_request }
    end
  end

  # GET /join_team_requests/1/edit
  def edit
    @join_team_request = JoinTeamRequest.find(params[:id])
  end

  # POST /join_team_requests
  # POST /join_team_requests.xml
  def create
    @join_team_request = JoinTeamRequest.new(params[:join_team_request])

    respond_to do |format|
      if @join_team_request.save
        format.html { redirect_to(@join_team_request, :notice => 'JoinTeamRequest was successfully created.') }
        format.xml  { render :xml => @join_team_request, :status => :created, :location => @join_team_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @join_team_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /join_team_requests/1
  # PUT /join_team_requests/1.xml
  def update
    @join_team_request = JoinTeamRequest.find(params[:id])

    respond_to do |format|
      if @join_team_request.update_attributes(params[:join_team_request])
        format.html { redirect_to(@join_team_request, :notice => 'JoinTeamRequest was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @join_team_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /join_team_requests/1
  # DELETE /join_team_requests/1.xml
  def destroy
    @join_team_request = JoinTeamRequest.find(params[:id])
    @join_team_request.destroy

    respond_to do |format|
      format.html { redirect_to(join_team_requests_url) }
      format.xml  { head :ok }
    end
  end
end
