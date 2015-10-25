class LatePoliciesController < ApplicationController
  helper :penalty
  include PenaltyHelper

  def action_allowed?
    case params[:action]
    when 'new', 'create', 'index'
      ['Super-Administrator',
       'Administrator',
       'Instructor',
       'Teaching Assistant'].include? current_role_name
    when 'edit', 'update', 'destroy'
      [
        'Super-Administrator',
        'Administrator',
        'Instructor',
        'Teaching Assistant'
      ].include?(current_role_name) &&
      current_user.instructor_id == instructor_id
    end
  end

  private def instructor_id
    late_policy.try(:instructor_id) ||
    current_user.instructor_id
  end

  private def late_policy
    @penalty_policy ||= @late_policy || LatePolicy.find(params[:id]) if params[:id]
  end

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

    @late_policy = LatePolicy.where(policy_name: params[:late_policy][:policy_name])
    if(@late_policy != nil && !@late_policy.empty?)
      @late_policy.each do |p|
        if p.instructor_id == instructor_id
          flash[:error] = "A policy with same name already exists"
          is_number = false
          break
        end
      end
    end
    if (is_number)
      @late_policy = LatePolicy.new(params[:late_policy])
      @late_policy.instructor_id = instructor_id

      begin
        @late_policy.save!
        flash[:notice] = "Penalty policy was successfully created."
        redirect_to :action => 'index'
      rescue
        flash[:error] = "The following error occurred while saving the penalty policy: "
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
  issue_number = false
  if (params[:late_policy][:max_penalty].to_i < params[:late_policy][:penalty_per_unit].to_i)
    flash[:error] = "Max penalty cannot be less than penalty per unit."
    issue_number = true
  end
  issue_name = false
  #if name has changed then only check for this
  if params[:late_policy][:policy_name] != @penalty_policy.policy_name
    @policy = LatePolicy.where(policy_name: params[:late_policy][:policy_name])
    if(@policy != nil && !@policy.empty?)
      @policy.each do |p|
        if p.instructor_id == instructor_id
          flash[:error] = "Cannot edit the policy. A policy with same name already exists"
          issue_name = true
          break
        end
      end
    end
  end
  if (issue_name == false && issue_number == false)
    @penalty_policy.update_attributes(params[:late_policy])
    @penalty_policy.save!
    @penaltyObjs = CalculatedPenalty.all
    @penaltyObjs.each do |pen|
      @participant = AssignmentParticipant.find(pen.participant_id)
      @assignment = @participant.assignment
      if @assignment.late_policy_id == @penalty_policy.id
        @penalties = calculate_penalty(pen.participant_id)
        @total_penalty = (@penalties[:submission] + @penalties[:review] + @penalties[:meta_review])
        if pen.deadline_type_id.to_i == 1
          {:penalty_points => @penalties[:submission]}
          pen.update_attribute(:penalty_points, @penalties[:submission])
        elsif pen.deadline_type_id.to_i == 2
          {:penalty_points => @penalties[:review]}
          pen.update_attribute(:penalty_points, @penalties[:review])
        elsif pen.deadline_type_id.to_i == 5
          {:penalty_points => @penalties[:meta_review]}
          pen.update_attribute(:penalty_points, @penalties[:meta_review])
        end
      end
    end
    flash[:notice] = "Late policy was successfully updated."
    redirect_to :action => 'index'
  elsif issue_number == true
    flash[:error] = "Cannot edit the policy. Maximum penalty cannot be less than penalty per unit."
    redirect_to :action => 'edit', :id => params[:id]
  elsif issue_name == true
    flash[:error] = "Cannot edit the policy. A policy with same name " + params[:late_policy][:policy_name] + " already exists"
    redirect_to :action => 'edit', :id => params[:id]
  end
end

# DELETE /late_policies/1
# DELETE /late_policies/1.xml
def destroy
  @penalty_policy = LatePolicy.find(params[:id])
  begin
    @penalty_policy.destroy
  rescue
    flash[:error] = "This policy is in use and hence cannot be deleted."
  end
  redirect_to :controller => 'late_policies', :action => 'index'
end

:private
def is_numeric?(obj)
  obj.to_s.match(/\A[+-]?\d*?(\.\d+)?\Z/) == nil ? false : true
end
end
