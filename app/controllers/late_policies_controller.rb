class LatePoliciesController < ApplicationController
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

  # GET /late_policies
  # GET /late_policies.xml
  def index
    @penalty_policies = LatePolicy.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @penalty_policies }
    end
  end

  # GET /late_policies/1
  # GET /late_policies/1.xml
  def show
    @penalty_policy = LatePolicy.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @penalty_policy }
    end
  end

  # GET /late_policies/new
  # GET /late_policies/new.xml
  def new
    @late_policy = LatePolicy.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @late_policy }
    end
  end

  # GET /late_policies/1/edit
  def edit
    @penalty_policy = LatePolicy.find(params[:id])
  end

  # POST /late_policies
  # POST /late_policies.xml
  def create
    invalid_penalty_per_unit = params[:late_policy][:max_penalty].to_i < params[:late_policy][:penalty_per_unit].to_i
    flash[:error] = "The maximum penalty cannot be less than penalty per unit." if invalid_penalty_per_unit
    same_policy_name = false
    if same_policy_name != LatePolicy.check_policy_with_same_name(params[:late_policy][:policy_name], instructor_id)
      flash[:error] = "A policy with the same name already exists."
      same_policy_name = true
    end
    if !invalid_penalty_per_unit && !same_policy_name
      @late_policy = LatePolicy.new(late_policy_params)
      @late_policy.instructor_id = instructor_id
      begin
        @late_policy.save!
        flash[:notice] = "The penalty policy was successfully created."
        redirect_to action: 'index'
      rescue StandardError
        flash[:error] = "The following error occurred while saving the penalty policy: "
        redirect_to action: 'new'
      end
    else
      redirect_to action: 'new'
    end
  end

  # PUT /late_policies/1
  # PUT /late_policies/1.xml
  def update
    @penalty_policy = LatePolicy.find(params[:id])
    invalid_penalty_per_unit = params[:late_policy][:max_penalty].to_i < params[:late_policy][:penalty_per_unit].to_i
    flash[:error] = "The maximum penalty cannot be less than penalty per unit." if invalid_penalty_per_unit
    same_policy_name = false
    # if name has changed then only check for this
    if params[:late_policy][:policy_name] != @penalty_policy.policy_name
      if same_policy_name == LatePolicy.check_policy_with_same_name(params[:late_policy][:policy_name], instructor_id)
        flash[:error] = "The policy could not be updated because a policy with the same name already exists."
      end
    end
    if !same_policy_name && !invalid_penalty_per_unit
      begin
        @penalty_policy.update_attributes(late_policy_params)
        @penalty_policy.save!
        LatePolicy.update_calculated_penalty_objects(@penalty_policy)
        flash[:notice] = "The late policy was successfully updated."
        redirect_to action: 'index'
      rescue StandardError
        flash[:error] = "The following error occurred while updating the penalty policy: "
        redirect_to action: 'edit', id: params[:id]
      end
    elsif invalid_penalty_per_unit
      flash[:error] = "Cannot edit the policy. The maximum penalty cannot be less than penalty per unit."
      redirect_to action: 'edit', id: params[:id]
    elsif same_policy_name
      flash[:error] = "Cannot edit the policy. A policy with the same name " + params[:late_policy][:policy_name] + " already exists."
      redirect_to action: 'edit', id: params[:id]
    end
  end

  # DELETE /late_policies/1
  # DELETE /late_policies/1.xml
  def destroy
    @penalty_policy = LatePolicy.find(params[:id])
    begin
      @penalty_policy.destroy
    rescue StandardError
      flash[:error] = "This policy is in use and hence cannot be deleted."
    end
    redirect_to controller: 'late_policies', action: 'index'
  end

  private

  def late_policy_params
    params.require(:late_policy).permit(:policy_name, :penalty_per_unit, :penalty_unit, :max_penalty)
  end

  def instructor_id
    late_policy.try(:instructor_id) ||
    current_user.instructor_id
  end

  def late_policy
    @penalty_policy ||= @late_policy || LatePolicy.find(params[:id]) if params[:id]
  end
end
