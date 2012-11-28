class LatePoliciesController < ApplicationController
  helper :penalty
  include PenaltyHelper
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

    is_number = true

    if session[:user].role.name == "Teaching Assistant"
      user_id = TA.get_my_instructor(session[:user]).id
    else
      user_id = session[:user].id
    end

    #if(!is_numeric?(params[:late_policy][:penalty_per_unit]))
    #  flash[:error] = "Penalty points per unit should be a numeric value"
    #  is_number = false
    #elsif (params[:late_policy][:penalty_per_unit].to_i < 0)
    #  flash[:error] = "Penalty points per unit cannot be negative"
    #  is_number = false
    #elsif(!is_numeric?(params[:late_policy][:max_penalty]))
    #    flash[:error] = "Maximum penalty points should be a numeric value"
    #    is_number = false
    #end

    if (params[:late_policy][:max_penalty].to_i < params[:late_policy][:penalty_per_unit].to_i)
      flash[:error] = "Max penalty cannot be less than penalty per unit."
      is_number = false
    end

    if (is_number)
      @late_policy = LatePolicy.new(params[:late_policy])
      @late_policy.instructor_id = user_id

      begin
        @late_policy.save!
        flash[:notice] = "Penalty policy was successfully created."
        redirect_to :action => 'index'
      rescue
        flash[:error] = "The following error occurred while saving the penalty policy: "+$!
        redirect_to :action => 'new'
      end
    else
      redirect_to :action => 'new'
    end
  end

  # PUT /late_policies/1
  # PUT /late_policies/1.xml
  def update
    @penalty_policy = LatePolicy.find(params[:id])

    begin
      @penalty_policy.update_attributes(params[:late_policy])
      @penaltyObjs = CalculatedPenalty.all
      @penaltyObjs.each do |pen|
        @participant = AssignmentParticipant.find(pen.participant_id)
        @assignment = @participant.assignment
        if @assignment.late_policy_id == @penalty_policy.id
          @penalties = calculate_penalty(pen.participant_id)
          @total_penalty = (@penalties[:submission] + @penalties[:review] + @penalties[:meta_review])
          if pen.deadline_type_id.to_i == 1
            penalty_attr1 = {:penalty_points => @penalties[:submission]}
            pen.update_attribute(:penalty_points, @penalties[:submission])
          elsif pen.deadline_type_id.to_i == 2
            penalty_attr2 = {:penalty_points => @penalties[:review]}
            pen.update_attribute(:penalty_points, @penalties[:review])
          elsif pen.deadline_type_id.to_i == 5
            penalty_attr3 = {:penalty_points => @penalties[:meta_review]}
            pen.update_attribute(:penalty_points, @penalties[:meta_review])
          end
        end
      end


        flash[:notice] = "Late policy was successfully updated."
        redirect_to :action => 'index'
      rescue
        flash[:error] = "The following error occurred while updating the penalty policy: "+$!
        redirect_to :action => 'edit'
      end

  end

  # DELETE /late_policies/1
  # DELETE /late_policies/1.xml
  def destroy
    @penalty_policy = LatePolicy.find(params[:id])
    begin
      @penalty_policy.destroy
    rescue
      flash[:error] = $!
    end
    redirect_to :action => 'index'
  end

  :private
  def is_numeric?(obj)
    obj.to_s.match(/\A[+-]?\d*?(\.\d+)?\Z/) == nil ? false : true
  end
end