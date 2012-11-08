class LatePoliciesController < ApplicationController
  # GET /late_policies
  # GET /late_policies.xml
  def index
    @penalty_policies = LatePolicy.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @penalty_policies }
    end
  end

  # GET /late_policies/1
  # GET /late_policies/1.xml
  def show
    @penalty_policy = LatePolicy.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @penalty_policy }
    end
  end

  # GET /late_policies/new
  # GET /late_policies/new.xml
  def new
    @late_policy = LatePolicy.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @late_policy }
    end
  end

  # GET /late_policies/1/edit
  def edit
    @penalty_policy = LatePolicy.find(params[:id])
  end

  # POST /late_policies
  # POST /late_policies.xml
  def create
    @penalty_policy = LatePolicy.new(params[:penalty_policy])

    respond_to do |format|
      if @penalty_policy.save
        format.html { redirect_to(@penalty_policy, :notice => 'PenaltyPolicy was successfully created.') }
        format.xml  { render :xml => @penalty_policy, :status => :created, :location => @penalty_policy }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @penalty_policy.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /late_policies/1
  # PUT /late_policies/1.xml
  def update
    @penalty_policy = LatePolicy.find(params[:id])

    respond_to do |format|
      if @penalty_policy.update_attributes(params[:penalty_policy])
        format.html { redirect_to(@penalty_policy, :notice => 'PenaltyPolicy was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @penalty_policy.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /late_policies/1
  # DELETE /late_policies/1.xml
  def destroy
    @penalty_policy = LatePolicy.find(params[:id])
    @penalty_policy.destroy

    respond_to do |format|
      format.html { redirect_to(penalty_policies_url) }
      format.xml  { head :ok }
    end
  end
end
